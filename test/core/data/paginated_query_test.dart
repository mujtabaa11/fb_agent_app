/// Tests for [FirestoreRepository.queryList] — the paginated query implementation.
///
/// Uses `fake_cloud_firestore` for happy-path pagination tests (orderBy + limit
/// + startAfterDocument verified to work in spike test). Uses mockito for error
/// mapping tests where FirebaseExceptions need specific codes.
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:template_app/core/data/firestore_repository.dart';
import 'package:template_app/core/data/paginated_result.dart';
import 'package:template_app/core/data/query_options.dart';
import 'package:template_app/core/data/result.dart';
import 'package:template_app/core/errors/app_exceptions.dart';
import 'package:template_app/features/profile/data/user_profile_model.dart';

@GenerateMocks([], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockRawCollection,
  ),
  MockSpec<CollectionReference<UserProfileModel>>(
    as: #MockTypedCollection,
  ),
  MockSpec<Query<UserProfileModel>>(
    as: #MockTypedQuery,
  ),
  MockSpec<QuerySnapshot<UserProfileModel>>(
    as: #MockTypedQuerySnapshot,
  ),
  MockSpec<FirebaseFirestore>(
    as: #MockFirestore,
  ),
])
import 'paginated_query_test.mocks.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Happy-path pagination tests using fake_cloud_firestore
  // ---------------------------------------------------------------------------

  group('queryList with fake Firestore', () {
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

    Future<void> seedUsers(int count) async {
      for (int i = 1; i <= count; i++) {
        await fakeFirestore.collection('users').add({
          'displayName': 'User$i',
          'email': 'user$i@example.com',
          'avatarUrl': null,
          'createdAt': Timestamp.fromDate(
            DateTime(2024, 1, i),
          ),
        });
      }
    }

    test('first page returns up to pageSize items with hasMore true', () async {
      await seedUsers(5);

      const options = QueryOptions(
        pageSize: 3,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Success<PaginatedResult<UserProfileModel>>>());
      final page = (result as Success<PaginatedResult<UserProfileModel>>).value;
      expect(page.items, hasLength(3));
      expect(page.hasMore, isTrue);
      expect(page.cursor, isNotNull);
    });

    test('last page returns remaining items with hasMore false', () async {
      await seedUsers(5);

      // Fetch first page.
      const firstOptions = QueryOptions(
        pageSize: 3,
        orderBy: 'createdAt',
      );
      final firstResult = await repo.queryList(firstOptions);
      final firstPage =
          (firstResult as Success<PaginatedResult<UserProfileModel>>).value;

      // Fetch second (last) page.
      final nextOptions = firstOptions.copyWith(cursor: firstPage.cursor);
      final secondResult = await repo.queryList(nextOptions);

      expect(secondResult,
          isA<Success<PaginatedResult<UserProfileModel>>>());
      final secondPage =
          (secondResult as Success<PaginatedResult<UserProfileModel>>).value;
      expect(secondPage.items, hasLength(2));
      expect(secondPage.hasMore, isFalse);
    });

    test('successive pages do not duplicate items', () async {
      await seedUsers(5);

      const options = QueryOptions(
        pageSize: 3,
        orderBy: 'createdAt',
      );

      // Page 1
      final result1 = await repo.queryList(options);
      final page1 =
          (result1 as Success<PaginatedResult<UserProfileModel>>).value;

      // Page 2
      final options2 = options.copyWith(cursor: page1.cursor);
      final result2 = await repo.queryList(options2);
      final page2 =
          (result2 as Success<PaginatedResult<UserProfileModel>>).value;

      final allEmails = [
        ...page1.items.map((i) => i.email),
        ...page2.items.map((i) => i.email),
      ];

      // All 5 unique users, no duplicates.
      expect(allEmails.toSet().length, 5);
      expect(allEmails, hasLength(5));
    });

    test('empty collection returns Success with empty items and hasMore false',
        () async {
      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Success<PaginatedResult<UserProfileModel>>>());
      final page =
          (result as Success<PaginatedResult<UserProfileModel>>).value;
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.cursor, isNull);
    });

    test('single page (fewer items than pageSize) ends naturally', () async {
      await seedUsers(3);

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Success<PaginatedResult<UserProfileModel>>>());
      final page =
          (result as Success<PaginatedResult<UserProfileModel>>).value;
      expect(page.items, hasLength(3));
      expect(page.hasMore, isFalse);
    });

    test('equality filter produces correct subset', () async {
      await seedUsers(5);

      final options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
        filters: [
          const QueryFilter(
            field: 'email',
            operator: FilterOperator.isEqualTo,
            value: 'user3@example.com',
          ),
        ],
      );

      final result = await repo.queryList(options);

      expect(result, isA<Success<PaginatedResult<UserProfileModel>>>());
      final page =
          (result as Success<PaginatedResult<UserProfileModel>>).value;
      expect(page.items, hasLength(1));
      expect(page.items.first.email, 'user3@example.com');
      expect(page.hasMore, isFalse);
    });

    test('descending order returns items in reverse', () async {
      await seedUsers(3);

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
        descending: true,
      );

      final result = await repo.queryList(options);

      final page =
          (result as Success<PaginatedResult<UserProfileModel>>).value;
      // With descending, createdAt Jan 3 should come first.
      expect(page.items.first.email, 'user3@example.com');
      expect(page.items.last.email, 'user1@example.com');
    });
  });

  // ---------------------------------------------------------------------------
  // Input validation tests
  // ---------------------------------------------------------------------------

  group('queryList input validation', () {
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

    test('pageSize 0 returns Failure with InvalidQueryException', () async {
      const options = QueryOptions(
        pageSize: 0,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      final failure =
          result as Failure<PaginatedResult<UserProfileModel>>;
      expect(failure.exception, isA<InvalidQueryException>());
    });

    test('negative pageSize returns Failure with InvalidQueryException',
        () async {
      const options = QueryOptions(
        pageSize: -5,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      expect(
        (result as Failure).exception,
        isA<InvalidQueryException>(),
      );
    });

    test('whereIn with more than 30 values returns Failure', () async {
      final options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
        filters: [
          QueryFilter(
            field: 'status',
            operator: FilterOperator.whereIn,
            value: List.generate(31, (i) => 'val$i'),
          ),
        ],
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      final failure =
          result as Failure<PaginatedResult<UserProfileModel>>;
      expect(failure.exception, isA<InvalidQueryException>());
      expect(failure.exception.message, contains('30'));
    });

    test('multiple arrayContains filters returns Failure', () async {
      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
        filters: [
          QueryFilter(
            field: 'tags',
            operator: FilterOperator.arrayContains,
            value: 'a',
          ),
          QueryFilter(
            field: 'categories',
            operator: FilterOperator.arrayContains,
            value: 'b',
          ),
        ],
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      expect(
        (result as Failure).exception,
        isA<InvalidQueryException>(),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Error mapping tests using mockito
  // ---------------------------------------------------------------------------

  group('queryList error mapping', () {
    late MockFirestore mockFirestore;
    late MockRawCollection mockRawCollection;
    late MockTypedCollection mockTypedCollection;
    late MockTypedQuery mockTypedQuery;

    FirestoreRepository<UserProfileModel> buildRepoWithMock() {
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
      mockTypedCollection = MockTypedCollection();
      mockTypedQuery = MockTypedQuery();

      // Stub the query chain: collection → where → orderBy → limit → get
      when(mockTypedCollection.orderBy(any, descending: anyNamed('descending')))
          .thenReturn(mockTypedQuery);
      when(mockTypedQuery.limit(any)).thenReturn(mockTypedQuery);
    });

    test('permission-denied returns Failure with PermissionException',
        () async {
      final repo = buildRepoWithMock();
      when(mockTypedQuery.get()).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      ));

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      expect((result as Failure).exception, isA<PermissionException>());
    });

    test('SocketException returns Failure with NetworkException', () async {
      final repo = buildRepoWithMock();
      when(mockTypedQuery.get())
          .thenThrow(const SocketException('no connection'));

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('requires-an-index error returns DataException with index URL',
        () async {
      final repo = buildRepoWithMock();
      when(mockTypedQuery.get()).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'failed-precondition',
        message:
            'The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/test/firestore/indexes?create_composite=abc',
      ));

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      final failure =
          result as Failure<PaginatedResult<UserProfileModel>>;
      expect(failure.exception, isA<DataException>());
      final dataException = failure.exception as DataException;
      expect(dataException.message, contains('composite index'));
      expect(dataException.originalMessage, contains('https://'));
    });

    test('unknown Firestore error returns DataException with original message',
        () async {
      final repo = buildRepoWithMock();
      when(mockTypedQuery.get()).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'internal',
        message: 'internal server error',
      ));

      const options = QueryOptions(
        pageSize: 20,
        orderBy: 'createdAt',
      );

      final result = await repo.queryList(options);

      expect(result, isA<Failure<PaginatedResult<UserProfileModel>>>());
      final failure =
          result as Failure<PaginatedResult<UserProfileModel>>;
      expect(failure.exception, isA<DataException>());
      expect(
        (failure.exception as DataException).originalMessage,
        'internal server error',
      );
    });
  });
}
