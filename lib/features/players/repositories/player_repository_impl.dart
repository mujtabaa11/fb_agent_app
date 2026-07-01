library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/player_model.dart';
import 'player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'players';
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  @override
  Future<Result<PlayerModel>> addPlayer(PlayerModel player) async {
    try {
      final data = player.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _collection.add(data);
      final snapshot = await docRef.get();
      final docData = snapshot.data()!;
      docData['id'] = snapshot.id;

      return Success(PlayerModel.fromJson(docData));
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<PlayerModel>> getPlayer(String playerId) async {
    try {
      final snapshot = await _collection.doc(playerId).get();

      if (!snapshot.exists) {
        return Failure(const DocumentNotFoundException());
      }

      final data = snapshot.data()!;
      data['id'] = snapshot.id;

      return Success(PlayerModel.fromJson(data));
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<PlayerModel>> updatePlayer(PlayerModel player) async {
    try {
      final data = player.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _collection.doc(player.id).update(data);

      return Success(player);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePlayer(String playerId) async {
    try {
      await _collection.doc(playerId).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Stream<Result<List<PlayerModel>>> watchPlayersByAgent(String agentId) {
    return _collection
        .where('agentId', isEqualTo: agentId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Result<List<PlayerModel>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final players = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return PlayerModel.fromJson(data);
          }).toList();
          sink.add(Success(players));
        },
        handleError: (error, stackTrace, sink) {
          if (error is FirebaseException) {
            sink.add(Failure(_mapFirebaseException(error)));
          } else if (error is SocketException) {
            sink.add(Failure(const NetworkException()));
          } else {
            sink.add(
                Failure(DataException(originalMessage: error.toString())));
          }
        },
      ),
    );
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
