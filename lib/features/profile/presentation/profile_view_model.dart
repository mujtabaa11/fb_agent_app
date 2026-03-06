/// ViewModel for the Profile screen.
///
/// Loads the current user's [UserProfileModel] from Firestore via
/// [BaseRepository] and handles avatar uploads via [BaseStorageService].
/// Depends only on abstract interfaces — never references
/// [FirestoreRepository], [FirebaseStorageService], or any Firebase class.
library;

import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/base_repository.dart';
import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/storage/base_storage_service.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/user_profile_model.dart';
import 'profile_state.dart';

part 'profile_view_model.g.dart';

/// Maximum avatar file size in bytes after compression (500 KB).
const int _kMaxAvatarBytes = 500 * 1024;

/// Manages the profile screen state including avatar uploads.
///
/// Reads the authenticated user's profile document from the `users`
/// collection. Returns [ProfileState] on success, or throws on
/// failure so that Riverpod's [AsyncValue] captures the error state.
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<ProfileState> build() async {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    final BaseRepository<UserProfileModel> repository =
        ref.watch(userProfileRepositoryProvider);

    final result = await repository.read(user.uid);

    return switch (result) {
      Success(:final value) => ProfileState(profile: value),
      Failure(:final exception) => throw exception,
    };
  }

  /// Opens the photo library, compresses the selected image, uploads it
  /// to Cloud Storage at `avatars/{userId}`, then persists the download
  /// URL to the user's profile document.
  ///
  /// Does nothing if the user cancels the picker. Surfaces a
  /// [ProfileState.uploadError] key on failure.
  Future<void> uploadAvatar() async {
    // Bail out if the profile hasn't loaded yet.
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // -----------------------------------------------------------------------
    // 1. Verify authenticated user — abort if unauthenticated.
    // -----------------------------------------------------------------------
    final authState = ref.read(authStateChangesProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      // Invalidate so the auth-guard redirect fires on next build.
      ref.invalidateSelf();
      return;
    }

    // -----------------------------------------------------------------------
    // 2. Pick image from gallery.
    // -----------------------------------------------------------------------
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } on Exception {
      // Permission denied or platform error.
      state = AsyncData(
        currentState.copyWith(
          uploadError: () => 'photoLibraryPermissionDenied',
        ),
      );
      return;
    }

    // User cancelled — return silently.
    if (picked == null) return;

    // -----------------------------------------------------------------------
    // 3. Compress the selected image.
    // -----------------------------------------------------------------------
    final Uint8List compressed;
    try {
      final rawBytes = await picked.readAsBytes();
      compressed = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 512,
        minHeight: 512,
        quality: 80,
      );
    } on Exception {
      state = AsyncData(
        currentState.copyWith(
          uploadError: () => 'avatarImageTooLargeError',
        ),
      );
      return;
    }

    if (compressed.lengthInBytes > _kMaxAvatarBytes) {
      state = AsyncData(
        currentState.copyWith(
          uploadError: () => 'avatarImageTooLargeError',
        ),
      );
      return;
    }

    // -----------------------------------------------------------------------
    // 4. Upload to Cloud Storage.
    // -----------------------------------------------------------------------
    // Clear any previous error and set initial progress.
    state = AsyncData(
      currentState.copyWith(
        uploadProgress: () => 0.0,
        uploadError: () => null,
      ),
    );

    final storagePath = 'avatars/${user.uid}';
    final BaseStorageService storage = ref.read(cloudStorageProvider);

    final uploadResult = await storage.uploadFile(
      storagePath,
      compressed,
      onProgress: (progress) {
        final s = state.valueOrNull;
        if (s != null) {
          state = AsyncData(s.copyWith(uploadProgress: () => progress));
        }
      },
    );

    switch (uploadResult) {
      case Failure():
        state = AsyncData(
          currentState.copyWith(
            uploadProgress: () => null,
            uploadError: () => 'avatarUploadErrorBody',
          ),
        );
        return;
      case Success(:final value):
        // ---------------------------------------------------------------
        // 5. Persist the download URL to the user's profile.
        // ---------------------------------------------------------------
        final BaseRepository<UserProfileModel> repository =
            ref.read(userProfileRepositoryProvider);

        final updatedProfile =
            currentState.profile.copyWith(avatarUrl: value);
        final updateResult =
            await repository.update(user.uid, updatedProfile);

        switch (updateResult) {
          case Success():
            // Check if the device is offline — Firestore queued the write.
            final connectivity = ref.read(connectivityServiceProvider);
            final status = await connectivity.currentStatus;
            state = AsyncData(
              ProfileState(
                profile: updatedProfile,
                savedOffline: status == ConnectivityStatus.offline,
              ),
            );
          case Failure():
            state = AsyncData(
              currentState.copyWith(
                uploadProgress: () => null,
                uploadError: () => 'avatarUploadErrorBody',
              ),
            );
        }
    }
  }
}
