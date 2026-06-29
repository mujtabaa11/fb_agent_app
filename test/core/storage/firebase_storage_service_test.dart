/// Tests for [FirebaseStorageService].
///
/// Uses mockito to mock [FirebaseStorage] and its reference chain.
/// Tests verify the contract boundary — does each method return the correct
/// [Result<T>] for each scenario? — not Firebase Storage SDK internals.
///
/// Every [FirebaseException] code that the service explicitly handles in
/// [_mapFirebaseException] has a corresponding test.
///
/// Note: [uploadFile] happy-path testing is limited because [UploadTask]
/// implements [Future<TaskSnapshot>] which is difficult to mock reliably.
/// Error-path tests for upload exercise the same [_mapFirebaseException]
/// logic by throwing from [ref.putData()].
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:football_agent_mate/core/data/result.dart';
import 'package:football_agent_mate/core/errors/app_exceptions.dart';
import 'package:football_agent_mate/core/storage/firebase_storage_service.dart';

@GenerateMocks([FirebaseStorage, Reference])
import 'firebase_storage_service_test.mocks.dart';

void main() {
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late FirebaseStorageService service;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    service = FirebaseStorageService(storage: mockStorage);

    // Default: storage.ref(path) → mockRef
    when(mockStorage.ref(any)).thenReturn(mockRef);
  });

  // ---------------------------------------------------------------------------
  // downloadUrl
  // ---------------------------------------------------------------------------

  group('downloadUrl', () {
    test('returns Success with download URL for existing file', () async {
      when(mockRef.getDownloadURL())
          .thenAnswer((_) async => 'https://storage.example.com/photo.jpg');

      final result = await service.downloadUrl('photos/photo.jpg');

      expect(result, isA<Success<String>>());
      expect(
        (result as Success<String>).value,
        'https://storage.example.com/photo.jpg',
      );
    });

    test('returns Failure with FileNotFoundException for non-existent file',
        () async {
      when(mockRef.getDownloadURL()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
      ));

      final result = await service.downloadUrl('missing/file.png');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<FileNotFoundException>());
    });

    test('returns Failure with PermissionException for unauthorized access',
        () async {
      when(mockRef.getDownloadURL()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'unauthorized',
      ));

      final result = await service.downloadUrl('restricted/file.png');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<PermissionException>());
    });

    test('returns Failure with CancelledException for canceled operation',
        () async {
      when(mockRef.getDownloadURL()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'canceled',
      ));

      final result = await service.downloadUrl('photos/photo.jpg');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<CancelledException>());
    });

    test('returns Failure with NetworkException on retry-limit-exceeded',
        () async {
      when(mockRef.getDownloadURL()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'retry-limit-exceeded',
      ));

      final result = await service.downloadUrl('photos/photo.jpg');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('returns Failure with NetworkException on SocketException', () async {
      when(mockRef.getDownloadURL())
          .thenThrow(const SocketException('no connection'));

      final result = await service.downloadUrl('photos/photo.jpg');

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test(
        'unknown Firebase error code returns Failure with DataException containing original message',
        () async {
      when(mockRef.getDownloadURL()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'quota-exceeded',
        message: 'storage quota exceeded',
      ));

      final result = await service.downloadUrl('photos/photo.jpg');

      expect(result, isA<Failure<String>>());
      final failure = result as Failure<String>;
      expect(failure.exception, isA<DataException>());
      expect(
        (failure.exception as DataException).originalMessage,
        'storage quota exceeded',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteFile
  // ---------------------------------------------------------------------------

  group('deleteFile', () {
    test('returns Success for existing file', () async {
      when(mockRef.delete()).thenAnswer((_) async {});

      final result = await service.deleteFile('photos/photo.jpg');

      expect(result, isA<Success<void>>());
    });

    test('returns Failure with FileNotFoundException for non-existent file',
        () async {
      when(mockRef.delete()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
      ));

      final result = await service.deleteFile('missing/file.png');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<FileNotFoundException>());
    });

    test('returns Failure with PermissionException for unauthorized access',
        () async {
      when(mockRef.delete()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'unauthorized',
      ));

      final result = await service.deleteFile('restricted/file.png');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<PermissionException>());
    });

    test('returns Failure with CancelledException for canceled operation',
        () async {
      when(mockRef.delete()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'canceled',
      ));

      final result = await service.deleteFile('photos/photo.jpg');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<CancelledException>());
    });

    test('returns Failure with NetworkException on retry-limit-exceeded',
        () async {
      when(mockRef.delete()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'retry-limit-exceeded',
      ));

      final result = await service.deleteFile('photos/photo.jpg');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('returns Failure with NetworkException on SocketException', () async {
      when(mockRef.delete())
          .thenThrow(const SocketException('no connection'));

      final result = await service.deleteFile('photos/photo.jpg');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test(
        'unknown Firebase error code returns Failure with DataException containing original message',
        () async {
      when(mockRef.delete()).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'quota-exceeded',
        message: 'storage quota exceeded',
      ));

      final result = await service.deleteFile('photos/photo.jpg');

      expect(result, isA<Failure<void>>());
      final failure = result as Failure<void>;
      expect(failure.exception, isA<DataException>());
      expect(
        (failure.exception as DataException).originalMessage,
        'storage quota exceeded',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // uploadFile — error paths
  //
  // The uploadFile happy-path requires mocking UploadTask which implements
  // Future<TaskSnapshot>. This is not reliably mockable with mockito because
  // the mock's then()/catchError() methods don't behave like real Futures.
  // Error paths are testable because ref.putData() throws before the Future
  // chain is reached.
  // ---------------------------------------------------------------------------

  group('uploadFile', () {
    test(
        'object-not-found error returns Failure with FileNotFoundException',
        () async {
      when(mockRef.putData(any)).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
      ));

      final result =
          await service.uploadFile('missing/path.png', Uint8List(10));

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<FileNotFoundException>());
    });

    test('unauthorized error returns Failure with PermissionException',
        () async {
      when(mockRef.putData(any)).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'unauthorized',
      ));

      final result =
          await service.uploadFile('restricted/file.png', Uint8List(10));

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<PermissionException>());
    });

    test('retry-limit-exceeded error returns Failure with NetworkException',
        () async {
      when(mockRef.putData(any)).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'retry-limit-exceeded',
      ));

      final result =
          await service.uploadFile('avatars/user1.png', Uint8List(10));

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('SocketException returns Failure with NetworkException', () async {
      when(mockRef.putData(any))
          .thenThrow(const SocketException('no connection'));

      final result =
          await service.uploadFile('avatars/user1.png', Uint8List(10));

      expect(result, isA<Failure<String>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test(
        'unknown Firebase error code returns Failure with DataException',
        () async {
      when(mockRef.putData(any)).thenThrow(FirebaseException(
        plugin: 'firebase_storage',
        code: 'unknown-code',
        message: 'something unexpected',
      ));

      final result =
          await service.uploadFile('avatars/user1.png', Uint8List(10));

      expect(result, isA<Failure<String>>());
      final failure = result as Failure<String>;
      expect(failure.exception, isA<DataException>());
      expect(
        (failure.exception as DataException).originalMessage,
        'something unexpected',
      );
    });
  });
}
