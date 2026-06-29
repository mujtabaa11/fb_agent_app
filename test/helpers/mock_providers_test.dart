/// Sanity tests for the test infrastructure itself.
///
/// These verify that fakes and helpers compile and behave correctly.
/// Feature tests belong in their respective directories.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/data/result.dart';

import 'mock_providers.dart';

void main() {
  group('FakeUserProfileRepository', () {
    late FakeUserProfileRepository repo;

    setUp(() {
      repo = FakeUserProfileRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('create and read round-trip succeeds', () async {
      final profile = createTestUserProfile();
      final createResult = await repo.create(profile);
      expect(createResult, isA<Success>());

      final readResult = await repo.read(profile.id);
      expect(readResult, isA<Success<dynamic>>());
    });

    test('read returns Failure for missing document', () async {
      final result = await repo.read('nonexistent');
      expect(result, isA<Failure>());
    });

    test('shouldFail flag causes all operations to fail', () async {
      repo.shouldFail = true;
      final result = await repo.create(createTestUserProfile());
      expect(result, isA<Failure>());
    });
  });

  group('FakeStorageService', () {
    late FakeStorageService storage;

    setUp(() {
      storage = FakeStorageService();
    });

    test('write and read round-trip succeeds', () async {
      await storage.write('key', 'value');
      final result = await storage.read('key');
      expect(result, 'value');
    });

    test('read returns null for missing key', () async {
      final result = await storage.read('missing');
      expect(result, isNull);
    });

    test('clear removes all entries', () async {
      await storage.write('a', '1');
      await storage.write('b', '2');
      await storage.clear();
      expect(await storage.read('a'), isNull);
      expect(await storage.read('b'), isNull);
    });
  });

  group('FakeAuthRepository', () {
    late FakeAuthRepository auth;

    setUp(() {
      auth = FakeAuthRepository();
    });

    tearDown(() {
      auth.dispose();
    });

    test('currentUser is null initially', () {
      expect(auth.currentUser, isNull);
    });

    test('setUser updates currentUser', () {
      final user = createTestAuthUser();
      auth.setUser(user);
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.uid, 'test-uid');
    });

    test('signInWithEmail returns Success', () async {
      final result = await auth.signInWithEmail('a@b.com', 'pass');
      expect(result, isA<Success>());
      expect(auth.currentUser, isNotNull);
    });

    test('signOut clears currentUser', () async {
      auth.setUser(createTestAuthUser());
      await auth.signOut();
      expect(auth.currentUser, isNull);
    });
  });

  group('FakeBaseStorageService', () {
    test('uploadFile returns fake download URL', () async {
      final service = FakeBaseStorageService();
      final result = await service.uploadFile('path', Uint8List(0));
      expect(result, isA<Success<String>>());
    });
  });

  group('Test fixtures', () {
    test('createTestAuthUser returns valid AuthUser', () {
      final user = createTestAuthUser();
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('createTestUserProfile returns valid UserProfileModel', () {
      final profile = createTestUserProfile();
      expect(profile.id, 'test-uid');
      expect(profile.email, 'test@example.com');
    });
  });
}
