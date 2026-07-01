library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../models/family_contact_model.dart';
import '../models/player_document_model.dart';
import '../models/player_model.dart';
import '../models/player_note_model.dart';
import 'player_providers.dart';

part 'player_profile_provider.g.dart';

@riverpod
Stream<PlayerModel?> playerProfile(PlayerProfileRef ref, String playerId) {
  final repo = ref.watch(playerRepositoryProvider);
  return repo.watchPlayer(playerId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

@riverpod
Stream<List<FamilyContactModel>> familyContacts(
    FamilyContactsRef ref, String playerId) {
  final repo = ref.watch(playerRepositoryProvider);
  return repo.watchFamilyContacts(playerId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

@riverpod
Stream<List<PlayerDocumentModel>> playerDocuments(
    PlayerDocumentsRef ref, String playerId) {
  final repo = ref.watch(playerRepositoryProvider);
  return repo.watchDocuments(playerId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

@riverpod
Stream<List<PlayerNoteModel>> playerNotes(
    PlayerNotesRef ref, String playerId) {
  final repo = ref.watch(playerRepositoryProvider);
  return repo.watchNotes(playerId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}
