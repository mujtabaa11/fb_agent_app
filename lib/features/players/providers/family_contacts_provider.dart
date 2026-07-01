library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../models/family_contact_model.dart';
import '../providers/player_profile_provider.dart';
import 'player_providers.dart';

part 'family_contacts_provider.g.dart';

class FamilyContactsState {
  const FamilyContactsState({
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final bool saveSuccess;

  FamilyContactsState copyWith({
    bool? isSaving,
    bool? isDeleting,
    String? Function()? errorMessage,
    bool? saveSuccess,
  }) {
    return FamilyContactsState(
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

@riverpod
class FamilyContactsNotifier extends _$FamilyContactsNotifier {
  @override
  FamilyContactsState build(String playerId) => const FamilyContactsState();

  Future<void> addContact({
    required String playerId,
    required String name,
    required String relationship,
    required String phoneNumber,
    String? email,
  }) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
      saveSuccess: false,
    );

    final contactId = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .collection('familyContacts')
        .doc()
        .id;

    final contact = FamilyContactModel(
      id: contactId,
      name: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      email: email,
    );

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.addFamilyContact(playerId, contact);

    switch (result) {
      case Success():
        state = state.copyWith(isSaving: false, saveSuccess: true);
        ref.invalidate(familyContactsProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isSaving: false,
          errorMessage: () => exception.message,
        );
    }
  }

  Future<void> updateContact({
    required String playerId,
    required FamilyContactModel existingContact,
    required String name,
    required String relationship,
    required String phoneNumber,
    String? email,
  }) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
      saveSuccess: false,
    );

    final updatedContact = existingContact.copyWith(
      name: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      email: email,
    );

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.updateFamilyContact(playerId, updatedContact);

    switch (result) {
      case Success():
        state = state.copyWith(isSaving: false, saveSuccess: true);
        ref.invalidate(familyContactsProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isSaving: false,
          errorMessage: () => exception.message,
        );
    }
  }

  Future<void> deleteContact({
    required String playerId,
    required String contactId,
  }) async {
    state = state.copyWith(isDeleting: true, errorMessage: () => null);

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.deleteFamilyContact(playerId, contactId);

    switch (result) {
      case Success():
        state = state.copyWith(isDeleting: false);
        ref.invalidate(familyContactsProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isDeleting: false,
          errorMessage: () => exception.message,
        );
    }
  }
}
