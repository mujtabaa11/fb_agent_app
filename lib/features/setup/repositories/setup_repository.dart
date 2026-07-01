library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../auth/models/user_model.dart';

abstract class SetupRepository {
  Future<Result<void>> saveAgentProfile(UserModel user);
}

class FirestoreSetupRepository implements SetupRepository {
  FirestoreSetupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<void>> saveAgentProfile(UserModel user) async {
    try {
      final data = user.toJson();
      data['isProfileComplete'] = true;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.id).set(data);
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
