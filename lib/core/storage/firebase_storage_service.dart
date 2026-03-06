/// Concrete Firebase Cloud Storage implementation.
///
/// This is the **only** file in the codebase that imports
/// `firebase_storage`. Feature code never touches Firebase Storage
/// directly — it depends on [BaseStorageService] via DI.
library;

import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../errors/app_exceptions.dart';
import 'base_storage_service.dart';

/// Firebase-backed [BaseStorageService].
///
/// Requires [FirebaseApp] to be initialised before construction.
class FirebaseStorageService implements BaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// The currently active upload task, if any.
  UploadTask? _activeUploadTask;

  /// The storage path of the active upload — used for cleanup on cancel.
  String? _activeUploadPath;

  @override
  Future<Result<String>> uploadFile(
    String storagePath,
    Uint8List bytes, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(storagePath);
      final uploadTask = ref.putData(bytes);

      _activeUploadTask = uploadTask;
      _activeUploadPath = storagePath;

      var completed = false;

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen(
          (snapshot) {
            if (!completed && snapshot.totalBytes > 0) {
              onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
            }
          },
          // Errors and completion are handled via the await below.
          onError: (_) {},
        );
      }

      final snapshot = await uploadTask;
      completed = true;
      _activeUploadTask = null;
      _activeUploadPath = null;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return Success(downloadUrl);
    } on FirebaseException catch (e) {
      _activeUploadTask = null;
      final path = _activeUploadPath;
      _activeUploadPath = null;

      if (e.code == 'canceled' && path != null) {
        await _bestEffortDelete(path);
        return Failure(const CancelledException());
      }

      return Failure(_mapFirebaseException(e));
    } on SocketException {
      _activeUploadTask = null;
      _activeUploadPath = null;
      return Failure(const NetworkException());
    } on Exception catch (e) {
      _activeUploadTask = null;
      _activeUploadPath = null;
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  void cancelUpload() {
    final task = _activeUploadTask;
    final path = _activeUploadPath;

    if (task == null) return;

    task.cancel();
    _activeUploadTask = null;
    _activeUploadPath = null;

    // Best-effort cleanup of any partial upload.
    if (path != null) {
      _bestEffortDelete(path);
    }
  }

  @override
  Future<Result<String>> downloadUrl(String storagePath) async {
    try {
      final url = await _storage.ref(storagePath).getDownloadURL();
      return Success(url);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Maps a [FirebaseException] to a typed [AppException].
  static AppException _mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'object-not-found' => const FileNotFoundException(),
      'unauthorized' => const PermissionException(),
      'canceled' => const CancelledException(),
      'retry-limit-exceeded' => const NetworkException(),
      _ => DataException(originalMessage: e.message),
    };
  }

  /// Attempts to delete the file at [path]. Swallows any error in non-debug
  /// mode and logs it via [debugPrint] in debug mode.
  Future<void> _bestEffortDelete(String path) async {
    try {
      await _storage.ref(path).delete();
    } on Exception catch (e) {
      debugPrint('Best-effort delete of "$path" failed: $e');
    }
  }
}
