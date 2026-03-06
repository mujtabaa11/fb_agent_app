/// Tests for [FirestoreRepository].
///
/// Uses `fake_cloud_firestore` for CRUD happy-path and watchStream tests.
/// Uses mockito for error mapping tests — fake_cloud_firestore cannot
/// simulate FirebaseExceptions for permission-denied, unavailable, etc.
///
/// Tests verify the contract boundary — does each method return the correct
/// [Result<T>] for each scenario? — not Firestore SDK internals.
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:template_app/core/data/firestore_repository.dart';
import 'package:template_app/core/data/result.dart';
import 'package:template_app/core/errors/app_exceptions.dart';
import 'package:template_app/features/profile/data/user_profile_model.dart';

@GenerateMocks([], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockRawCollection,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
    as: #MockRawDocRef,
  ),
  MockSpec<CollectionReference<UserProfileModel>>(
    as: #MockTypedCollection,
  ),
  MockSpec<DocumentReference<UserProfileModel>>(
    as: #MockTypedDocRef,
  ),
  MockSpec<DocumentSnapshot<UserProfileModel>>(
    as: #MockTypedSnapshot,
  ),
  MockSpec<FirebaseFirestore>(
    as: #MockFirestore,
  ),
])
import 'firestore_repository_test.mocks.dart';

void main() {
  // ---------------------------------------------------------------------------
  // CRUD tests using fake_cloud_firestore
  // ---------------------------------------------------------------------------

  group('CRUD with fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreRepository<UserProfileModel> repo;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = FirestoreRepository<UserProfileModel>(
        collectionPath: 'users',
        fromJson: UserProfileModel.fromJson,
        toJson: (model) => model.toJson(),
        firestore: fakeFirestore,
      );
    });

    group('create', () {
      test('returns Success with model containing Firestore-assigned ID',
          () async {
        final model = UserProfileModel(
          id: '',
          displayName: 'Alice',
          email: 'alice@example.com',
        );

        final result = await repo.create(model);

        expect(result, isA<Success<UserProfileModel>>());
        final created = (result as Success<UserProfileModel>).value;
        expect(created.displayName, 'Alice');
        expect(created.email, 'alice@example.com');
      });

      test('writes document to the correct collection path', () async {
        final model = UserProfileModel(
          id: '',
          displayName: 'Bob',
          email: 'bob@example.com',
        );

        await repo.create(model);

        final snapshot = await fakeFirestore.collection('users').get();
        expect(snapshot.docs, hasLength(1));
        expect(snapshot.docs.first.data()['displayName'], 'Bob');
        expect(snapshot.docs.first.data()['email'], 'bob@example.com');
      });
    });

    group('read', () {
      test(
          'returns Success with correctly deserialized model for existing document',
          () async {
        final docRef = await fakeFirestore.collection('users').add({
          'displayName': 'Charlie',
          'email': 'charlie@example.com',
          'avatarUrl': null,
        });

        final result = await repo.read(docRef.id);

        expect(result, isA<Success<UserProfileModel>>());
        final profile = (result as Success<UserProfileModel>).value;
        expect(profile.displayName, 'Charlie');
        expect(profile.email, 'charlie@example.com');
      });

      test(
          'returns Failure with DocumentNotFoundException when document does not exist',
          () async {
        final result = await repo.read('nonexistent-id');

        expect(result, isA<Failure<UserProfileModel>>());
        final failure = result as Failure<UserProfileModel>;
        expect(failure.exception, isA<DocumentNotFoundException>());
      });
    });

    group('update', () {
      test('returns Success with updated model for existing document',
          () async {
        final docRef = await fakeFirestore.collection('users').add({
          'displayName': 'Dana',
          'email': 'dana@example.com',
          'avatarUrl': null,
        });

        final updatedModel = UserProfileModel(
          id: docRef.id,
          displayName: 'Dana Updated',
          email: 'dana@example.com',
        );

        final result = await repo.update(docRef.id, updatedModel);

        expect(result, isA<Success<UserProfileModel>>());
        final profile = (result as Success<UserProfileModel>).value;
        expect(profile.displayName, 'Dana Updated');

        // Verify the update persisted in Firestore.
        final snapshot =
            await fakeFirestore.collection('users').doc(docRef.id).get();
        expect(snapshot.data()!['displayName'], 'Dana Updated');
      });
    });

    group('delete', () {
      test('returns Success for existing document', () async {
        final docRef = await fakeFirestore.collection('users').add({
          'displayName': 'Eve',
          'email': 'eve@example.com',
          'avatarUrl': null,
        });

        final result = await repo.delete(docRef.id);

        expect(result, isA<Success<void>>());

        // Verify the document was removed.
        final snapshot =
            await fakeFirestore.collection('users').doc(docRef.id).get();
        expect(snapshot.exists, isFalse);
      });
    });

    group('watchStream', () {
      test('emits Success when document exists', () async {
        final docRef = await fakeFirestore.collection('users').add({
          'displayName': 'Frank',
          'email': 'frank@example.com',
          'avatarUrl': null,
        });

        final stream = repo.watchStream(docRef.id);
        final result = await stream.first;

        expect(result, isA<Success<UserProfileModel>>());
        final profile = (result as Success<UserProfileModel>).value;
        expect(profile.displayName, 'Frank');
      });

      test(
          'emits Failure with DocumentNotFoundException when document does not exist',
          () async {
        final stream = repo.watchStream('nonexistent-doc');
        final result = await stream.first;

        expect(result, isA<Failure<UserProfileModel>>());
        final failure = result as Failure<UserProfileModel>;
        expect(failure.exception, isA<DocumentNotFoundException>());
      });
    });
  });

  // ---------------------------------------------------------------------------
  // Error mapping tests using mockito
  //
  // These verify that every FirebaseException code the repository explicitly
  // handles in _mapFirebaseException produces the correct Failure type.
  // We mock the Firestore chain so read() throws a controlled exception.
  // ---------------------------------------------------------------------------

  group('error mapping', () {
    late MockFirestore mockFirestore;
    late MockRawCollection mockRawCollection;
    late MockRawDocRef mockRawDocRef;
    late MockTypedCollection mockTypedCollection;
    late MockTypedDocRef mockTypedDocRef;

    FirestoreRepository<UserProfileModel> buildRepoWithMock() {
      // Stub the chain: firestore.collection().withConverter() → typed collection
      // The constructor uses this chain to set _collection.
      when(mockFirestore.collection('users')).thenReturn(mockRawCollection);
      when(mockRawCollection.withConverter<UserProfileModel>(
        fromFirestore: anyNamed('fromFirestore'),
        toFirestore: anyNamed('toFirestore'),
      )).thenReturn(mockTypedCollection);

      return FirestoreRepository<UserProfileModel>(
        collectionPath: 'users',
        fromJson: UserProfileModel.fromJson,
        toJson: (model) => model.toJson(),
        firestore: mockFirestore,
      );
    }

    setUp(() {
      mockFirestore = MockFirestore();
      mockRawCollection = MockRawCollection();
      mockRawDocRef = MockRawDocRef();
      mockTypedCollection = MockTypedCollection();
      mockTypedDocRef = MockTypedDocRef();

      // Default: typed collection.doc() → typed doc ref
      when(mockTypedCollection.doc(any)).thenReturn(mockTypedDocRef);
      // Default: raw collection.doc() → raw doc ref
      when(mockRawCollection.doc(any)).thenReturn(mockRawDocRef);
    });

    group('read', () {
      test('Firestore not-found error returns Failure with DocumentNotFoundException',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
        ));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<DocumentNotFoundException>());
      });

      test('Firestore permission-denied error returns Failure with PermissionException',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<PermissionException>());
      });

      test('Firestore unavailable error returns Failure with NetworkException',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<NetworkException>());
      });

      test('Firestore cancelled error returns Failure with NetworkException',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'cancelled',
        ));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<NetworkException>());
      });

      test('unknown Firestore error code returns Failure with DataException containing original message',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'internal',
          message: 'internal server error',
        ));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        final failure = result as Failure<UserProfileModel>;
        expect(failure.exception, isA<DataException>());
        expect(
          (failure.exception as DataException).originalMessage,
          'internal server error',
        );
      });

      test('SocketException returns Failure with NetworkException', () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get())
            .thenThrow(const SocketException('no connection'));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<NetworkException>());
      });

      test('generic Exception returns Failure with DataException', () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.get())
            .thenThrow(const FormatException('bad data'));

        final result = await repo.read('any-id');

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<DataException>());
      });
    });

    group('create', () {
      test('Firestore permission-denied error returns Failure with PermissionException',
          () async {
        final repo = buildRepoWithMock();
        when(mockRawCollection.add(any)).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));

        final model = UserProfileModel(
          id: '',
          displayName: 'Test',
          email: 'test@example.com',
        );

        final result = await repo.create(model);

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<PermissionException>());
      });
    });

    group('update', () {
      test('Firestore permission-denied error returns Failure with PermissionException',
          () async {
        final repo = buildRepoWithMock();
        when(mockRawDocRef.update(any)).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));

        final model = UserProfileModel(
          id: 'id',
          displayName: 'Test',
          email: 'test@example.com',
        );

        final result = await repo.update('id', model);

        expect(result, isA<Failure<UserProfileModel>>());
        expect((result as Failure).exception, isA<PermissionException>());
      });
    });

    group('delete', () {
      test('Firestore permission-denied error returns Failure with PermissionException',
          () async {
        final repo = buildRepoWithMock();
        when(mockTypedDocRef.delete()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));

        final result = await repo.delete('any-id');

        expect(result, isA<Failure<void>>());
        expect((result as Failure).exception, isA<PermissionException>());
      });
    });
  });
}
