library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import 'conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'conversations';
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  @override
  Future<Result<String>> findOrCreateConversation(
    String currentAgentId,
    String otherAgentId,
  ) async {
    try {
      final querySnapshot = await _collection
          .where('participantIds', arrayContains: currentAgentId)
          .get();

      for (final doc in querySnapshot.docs) {
        final participantIds =
            (doc.data()['participantIds'] as List<dynamic>?) ?? [];
        if (participantIds.contains(otherAgentId)) {
          return Success(doc.id);
        }
      }

      final docRef = _collection.doc();
      await docRef.set({
        'participantIds': [currentAgentId, otherAgentId],
        'unreadCount': {
          currentAgentId: 0,
          otherAgentId: 0,
        },
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Success(docRef.id);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendOpeningMessage(
    String conversationId,
    String senderId,
    String otherAgentId,
    String text,
    String? postId,
  ) async {
    try {
      final conversationRef = _collection.doc(conversationId);
      final messageRef = conversationRef.collection('messages').doc();

      await messageRef.set({
        'senderId': senderId,
        'text': text,
        if (postId != null) 'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await conversationRef.update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount.$otherAgentId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  static AppException _mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'not-found' => const DocumentNotFoundException(),
      'permission-denied' => const PermissionException(),
      'unavailable' || 'cancelled' => const NetworkException(),
      _ => DataException(originalMessage: e.message),
    };
  }
}
