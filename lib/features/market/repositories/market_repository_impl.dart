library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/market_post_model.dart';
import 'market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionPath = 'market_posts';
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

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

  static AppException _mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'not-found' => const DocumentNotFoundException(),
      'permission-denied' => const PermissionException(),
      'unavailable' || 'cancelled' => const NetworkException(),
      _ => DataException(originalMessage: e.message),
    };
  }
}
