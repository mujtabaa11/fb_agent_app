library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../models/player_note_model.dart';
import 'player_profile_provider.dart';
import 'player_providers.dart';

part 'notes_provider.g.dart';

class NotesState {
  const NotesState({
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final bool saveSuccess;

  NotesState copyWith({
    bool? isSaving,
    bool? isDeleting,
    String? Function()? errorMessage,
    bool? saveSuccess,
  }) {
    return NotesState(
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  NotesState build(String playerId) => const NotesState();

  Future<void> addNote({
    required String playerId,
    required String content,
  }) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
      saveSuccess: false,
    );

    final noteId = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .collection('notes')
        .doc()
        .id;

    final now = DateTime.now();
    final note = PlayerNoteModel(
      id: noteId,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.addNote(playerId, note);

    switch (result) {
      case Success():
        state = state.copyWith(isSaving: false, saveSuccess: true);
        ref.invalidate(playerNotesProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isSaving: false,
          errorMessage: () => exception.message,
        );
    }
  }

  Future<void> updateNote({
    required String playerId,
    required PlayerNoteModel existingNote,
    required String newContent,
  }) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
      saveSuccess: false,
    );

    final updatedNote = existingNote.copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.updateNote(playerId, updatedNote);

    switch (result) {
      case Success():
        state = state.copyWith(isSaving: false, saveSuccess: true);
        ref.invalidate(playerNotesProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isSaving: false,
          errorMessage: () => exception.message,
        );
    }
  }

  Future<void> deleteNote({
    required String playerId,
    required String noteId,
  }) async {
    state = state.copyWith(isDeleting: true, errorMessage: () => null);

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.deleteNote(playerId, noteId);

    switch (result) {
      case Success():
        state = state.copyWith(isDeleting: false);
        ref.invalidate(playerNotesProvider(playerId));
      case Failure(:final exception):
        state = state.copyWith(
          isDeleting: false,
          errorMessage: () => exception.message,
        );
    }
  }
}
