library;

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/agent_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../repositories/setup_repository.dart';

part 'setup_provider.g.dart';

class AccountSetupState {
  const AccountSetupState({
    this.photoUrl,
    this.fullName = '',
    this.country = '',
    this.isFifaRegistered,
    this.licenceNumber = '',
    this.bio = '',
    this.agencyName = '',
    this.yearsOfExperience,
    this.phoneNumber = '',
    this.isPhoneOnWhatsApp = false,
    this.isUploading = false,
    this.uploadError,
    this.isSaving = false,
    this.saveError,
    this.selectedPhotoBytes,
  });

  final String? photoUrl;
  final String fullName;
  final String country;
  final bool? isFifaRegistered;
  final String licenceNumber;
  final String bio;
  final String agencyName;
  final int? yearsOfExperience;
  final String phoneNumber;
  final bool isPhoneOnWhatsApp;
  final bool isUploading;
  final String? uploadError;
  final bool isSaving;
  final String? saveError;
  final Uint8List? selectedPhotoBytes;

  bool get isStep1Valid => photoUrl != null;

  bool get isStep2Valid => fullName.trim().isNotEmpty && country.isNotEmpty;

  bool get isStep3Valid =>
      isFifaRegistered != null &&
      (isFifaRegistered == false || licenceNumber.trim().isNotEmpty);

  bool get isStep4Valid => true;

  AccountSetupState copyWith({
    String? photoUrl,
    String? fullName,
    String? country,
    bool? isFifaRegistered,
    String? licenceNumber,
    String? bio,
    String? agencyName,
    int? yearsOfExperience,
    String? phoneNumber,
    bool? isPhoneOnWhatsApp,
    bool? isUploading,
    String? uploadError,
    bool? isSaving,
    String? saveError,
    Uint8List? selectedPhotoBytes,
    bool clearPhotoUrl = false,
    bool clearUploadError = false,
    bool clearSaveError = false,
    bool clearIsFifaRegistered = false,
    bool clearYearsOfExperience = false,
    bool clearSelectedPhotoBytes = false,
  }) {
    return AccountSetupState(
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      fullName: fullName ?? this.fullName,
      country: country ?? this.country,
      isFifaRegistered: clearIsFifaRegistered
          ? null
          : (isFifaRegistered ?? this.isFifaRegistered),
      licenceNumber: licenceNumber ?? this.licenceNumber,
      bio: bio ?? this.bio,
      agencyName: agencyName ?? this.agencyName,
      yearsOfExperience: clearYearsOfExperience
          ? null
          : (yearsOfExperience ?? this.yearsOfExperience),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneOnWhatsApp: isPhoneOnWhatsApp ?? this.isPhoneOnWhatsApp,
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      selectedPhotoBytes: clearSelectedPhotoBytes
          ? null
          : (selectedPhotoBytes ?? this.selectedPhotoBytes),
    );
  }
}

@Riverpod(keepAlive: true)
SetupRepository setupRepository(SetupRepositoryRef ref) {
  return FirestoreSetupRepository();
}

@riverpod
class AccountSetupNotifier extends _$AccountSetupNotifier {
  @override
  AccountSetupState build() => const AccountSetupState();

  void setFullName(String value) {
    state = state.copyWith(fullName: value);
  }

  void setCountry(String value) {
    state = state.copyWith(country: value);
  }

  void setIsFifaRegistered(bool value) {
    state = state.copyWith(
      isFifaRegistered: value,
      licenceNumber: value ? state.licenceNumber : '',
    );
  }

  void setLicenceNumber(String value) {
    state = state.copyWith(licenceNumber: value);
  }

  void setBio(String value) {
    state = state.copyWith(bio: value);
  }

  void setAgencyName(String value) {
    state = state.copyWith(agencyName: value);
  }

  void setYearsOfExperience(int? value) {
    if (value == null) {
      state = state.copyWith(clearYearsOfExperience: true);
    } else {
      state = state.copyWith(yearsOfExperience: value);
    }
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      isPhoneOnWhatsApp: value.isEmpty ? false : state.isPhoneOnWhatsApp,
    );
  }

  void setIsPhoneOnWhatsApp(bool value) {
    state = state.copyWith(isPhoneOnWhatsApp: value);
  }

  Future<Result<void>> uploadPhoto(XFile file) async {
    state = state.copyWith(isUploading: true, clearUploadError: true);

    final bytes = await file.readAsBytes();
    state = state.copyWith(selectedPhotoBytes: bytes);

    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) {
      state = state.copyWith(isUploading: false);
      return const Failure(AuthException());
    }

    final storagePath = 'avatars/${authUser.uid}/profile.jpg';
    final storage = ref.read(cloudStorageProvider);
    final result = await storage.uploadFile(storagePath, bytes);

    return switch (result) {
      Success(:final value) => () {
          state = state.copyWith(photoUrl: value, isUploading: false);
          return const Success<void>(null);
        }(),
      Failure(:final exception) => () {
          state = state.copyWith(
            isUploading: false,
            uploadError: exception.message,
            clearSelectedPhotoBytes: true,
          );
          return Failure<void>(exception);
        }(),
    };
  }

  Future<Result<void>> saveProfile() async {
    state = state.copyWith(isSaving: true, clearSaveError: true);

    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) {
      state = state.copyWith(isSaving: false);
      return const Failure(AuthException());
    }

    final user = UserModel(
      id: authUser.uid,
      fullName: state.fullName.trim(),
      country: state.country,
      isProfileComplete: true,
      avatarUrl: state.photoUrl,
      isFifaRegistered: state.isFifaRegistered,
      licenceNumber: state.licenceNumber.trim().isNotEmpty
          ? state.licenceNumber.trim()
          : null,
      bio: state.bio.trim().isNotEmpty ? state.bio.trim() : null,
      agencyName:
          state.agencyName.trim().isNotEmpty ? state.agencyName.trim() : null,
      yearsOfExperience: state.yearsOfExperience,
      phoneNumber:
          state.phoneNumber.trim().isNotEmpty ? state.phoneNumber.trim() : null,
      isPhoneOnWhatsApp:
          state.phoneNumber.trim().isNotEmpty ? state.isPhoneOnWhatsApp : null,
      email: authUser.email.isNotEmpty ? authUser.email : null,
    );

    final repo = ref.read(setupRepositoryProvider);
    final result = await repo.saveAgentProfile(user);

    return switch (result) {
      Success() => () {
          state = state.copyWith(isSaving: false);
          ref.invalidate(currentAgentProvider);
          return const Success<void>(null);
        }(),
      Failure(:final exception) => () {
          state = state.copyWith(
            isSaving: false,
            saveError: exception.message,
          );
          return Failure<void>(exception);
        }(),
    };
  }
}
