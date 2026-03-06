/// Abstract base class for cloud file storage operations.
///
/// All feature code depends on this interface via DI — never on
/// a concrete implementation. This is a pure Dart contract with
/// zero Firebase or platform-specific imports.
library;

import 'dart:typed_data';

import '../data/result.dart';

/// Cloud file storage contract.
///
/// Implementations handle uploading, downloading URLs, and deleting files
/// in a remote storage bucket. Callers construct the [storagePath] — the
/// service does not enforce any path convention.
abstract class BaseStorageService {
  /// Uploads [bytes] to [storagePath] and returns the download URL.
  ///
  /// [onProgress] receives a value between 0.0 and 1.0 indicating upload
  /// progress. It is optional — callers that don't need progress tracking
  /// simply omit it.
  Future<Result<String>> uploadFile(
    String storagePath,
    Uint8List bytes, {
    void Function(double progress)? onProgress,
  });

  /// Returns the publicly accessible download URL for the file at
  /// [storagePath].
  Future<Result<String>> downloadUrl(String storagePath);

  /// Deletes the file at [storagePath].
  Future<Result<void>> deleteFile(String storagePath);

  /// Cancels the currently active upload, if any.
  ///
  /// After cancellation, partially uploaded bytes are deleted on a
  /// best-effort basis. This method is a no-op when no upload is in
  /// progress and never throws.
  void cancelUpload() {}
}
