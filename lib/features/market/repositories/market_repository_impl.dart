library;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/storage/base_storage_service.dart';
import '../models/market_post_model.dart';
import 'market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    FirebaseFirestore? firestore,
    required BaseStorageService storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService;

  static const String _collectionPath = 'market_posts';
  final FirebaseFirestore _firestore;
  final BaseStorageService _storageService;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  @override
  String generatePostId() => _collection.doc().id;

  @override
  Future<Result<MarketPostModel>> createPost(MarketPostModel post) async {
    try {
      final data = post.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = post.id.isNotEmpty ? _collection.doc(post.id) : _collection.doc();
      await docRef.set(data);
      final snapshot = await docRef.get();
      final docData = snapshot.data()!;
      docData['id'] = snapshot.id;

      return Success(MarketPostModel.fromJson(docData));
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Stream<Result<List<MarketPostModel>>> watchMarketFeed() {
    return _collection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Result<List<MarketPostModel>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final posts = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return MarketPostModel.fromJson(data);
          }).toList();
          sink.add(Success(posts));
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

  @override
  Stream<Result<MarketPostModel?>> watchPost(String postId) {
    return _collection.doc(postId).snapshots().transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          Result<MarketPostModel?>>.fromHandlers(
        handleData: (snapshot, sink) {
          if (!snapshot.exists) {
            sink.add(const Success(null));
            return;
          }
          final data = snapshot.data()!;
          data['id'] = snapshot.id;
          sink.add(Success(MarketPostModel.fromJson(data)));
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

  @override
  Stream<Result<List<MarketPostModel>>> watchMyPosts(String agentId) {
    return _collection
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
          Result<List<MarketPostModel>>>.fromHandlers(
        handleData: (snapshot, sink) {
          final posts = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return MarketPostModel.fromJson(data);
          }).toList();
          sink.add(Success(posts));
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

  @override
  Future<Result<void>> closePost(String postId) async {
    try {
      await _collection.doc(postId).update({
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return const Failure(NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await _collection.doc(postId).delete();
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return const Failure(NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }

    final storageResult =
        await _storageService.deleteFile('market_posts/$postId/photo.jpg');
    switch (storageResult) {
      case Success():
        break;
      case Failure(:final exception):
        developer.log(
          'Failed to delete photo for market post $postId: '
          '${exception.message}',
          name: 'MarketRepositoryImpl',
        );
    }

    return const Success(null);
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
