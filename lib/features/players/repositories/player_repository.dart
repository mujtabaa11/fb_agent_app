library;

import '../../../core/data/result.dart';
import '../models/family_contact_model.dart';
import '../models/player_document_model.dart';
import '../models/player_model.dart';
import '../models/player_note_model.dart';

abstract class PlayerRepository {
  Future<Result<PlayerModel>> addPlayer(PlayerModel player);
  Future<Result<PlayerModel>> getPlayer(String playerId);
  Future<Result<PlayerModel>> updatePlayer(PlayerModel player);
  Future<Result<void>> deletePlayer(String playerId);
  Stream<Result<List<PlayerModel>>> watchPlayersByAgent(String agentId);
  Stream<Result<PlayerModel?>> watchPlayer(String playerId);
  Stream<Result<List<FamilyContactModel>>> watchFamilyContacts(String playerId);
  Stream<Result<List<PlayerDocumentModel>>> watchDocuments(String playerId);
  Stream<Result<List<PlayerNoteModel>>> watchNotes(String playerId);
  Future<Result<PlayerDocumentModel>> addDocument(
    String playerId,
    PlayerDocumentModel document,
  );
  Future<Result<void>> deleteDocument(String playerId, String documentId);
  Future<Result<PlayerNoteModel>> addNote(String playerId, PlayerNoteModel note);
  Future<Result<PlayerNoteModel>> updateNote(
    String playerId,
    PlayerNoteModel note,
  );
  Future<Result<void>> deleteNote(String playerId, String noteId);
  Future<Result<FamilyContactModel>> addFamilyContact(
    String playerId,
    FamilyContactModel contact,
  );
  Future<Result<FamilyContactModel>> updateFamilyContact(
    String playerId,
    FamilyContactModel contact,
  );
  Future<Result<void>> deleteFamilyContact(String playerId, String contactId);
}
