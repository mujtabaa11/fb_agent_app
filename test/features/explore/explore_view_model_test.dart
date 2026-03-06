/// Tests for [ExploreViewModel].
///
/// Mocks [BaseRepository<UserProfileModel>] via a custom fake returning
/// pre-built [PaginatedResult] objects — no Firestore needed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template_app/core/data/base_repository.dart';
import 'package:template_app/core/data/paginated_result.dart';
import 'package:template_app/core/data/query_options.dart';
import 'package:template_app/core/data/repository_providers.dart';
import 'package:template_app/core/data/result.dart';
import 'package:template_app/core/errors/app_exceptions.dart';
import 'package:template_app/features/explore/presentation/explore_view_model.dart';
import 'package:template_app/features/profile/data/user_profile_model.dart';

import '../../helpers/mock_providers.dart';

/// Extended fake that supports configurable paginated query responses.
class _PaginatedFakeRepo extends FakeUserProfileRepository {
  final List<Result<PaginatedResult<UserProfileModel>>> queryResults = [];
  int _queryCallCount = 0;

  int get queryCallCount => _queryCallCount;

  @override
  Future<Result<PaginatedResult<UserProfileModel>>> queryList(
    QueryOptions options,
  ) async {
    _queryCallCount++;
    if (queryResults.isNotEmpty) {
      return queryResults.removeAt(0);
    }
    return const Success(PaginatedResult(items: [], hasMore: false));
  }
}

List<UserProfileModel> _generateUsers(int count, {int startIndex = 1}) {
  return List.generate(
    count,
    (i) => UserProfileModel(
      id: 'user-${startIndex + i}',
      displayName: 'User ${startIndex + i}',
      email: 'user${startIndex + i}@example.com',
    ),
  );
}

void main() {
  group('ExploreViewModel', () {
    late _PaginatedFakeRepo fakeRepo;

    setUp(() {
      fakeRepo = _PaginatedFakeRepo();
    });

    ProviderContainer createContainer() {
      final c = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider
              .overrideWithValue(fakeRepo as BaseRepository<UserProfileModel>),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    /// Waits for the auto-triggered loadInitialPage in build() to complete.
    Future<void> waitForInitialLoad(ProviderContainer container) async {
      // Subscribe to trigger the Riverpod provider's build.
      container.listen(exploreViewModelProvider, (_, __) {});
      // Let microtask + async operations settle.
      for (int i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('initial load fetches first page and populates items', () async {
      final users = _generateUsers(3);
      fakeRepo.queryResults.add(
        Success(PaginatedResult(items: users, hasMore: true, cursor: 'c1')),
      );

      final container = createContainer();
      await waitForInitialLoad(container);

      final state = container.read(exploreViewModelProvider);
      expect(state.items, hasLength(3));
      expect(state.hasMore, isTrue);
      expect(state.isLoadingFirstPage, isFalse);
      expect(state.firstPageError, isNull);
    });

    test('loadNextPage appends items without duplicates', () async {
      final page1Users = _generateUsers(3, startIndex: 1);
      final page2Users = _generateUsers(2, startIndex: 4);

      fakeRepo.queryResults.addAll([
        Success(
            PaginatedResult(items: page1Users, hasMore: true, cursor: 'c1')),
        Success(
            PaginatedResult(items: page2Users, hasMore: false, cursor: 'c2')),
      ]);

      final container = createContainer();
      await waitForInitialLoad(container);

      await container
          .read(exploreViewModelProvider.notifier)
          .loadNextPage();

      final state = container.read(exploreViewModelProvider);
      expect(state.items, hasLength(5));
      expect(state.hasMore, isFalse);

      final ids = state.items.map((i) => i.id).toSet();
      expect(ids, hasLength(5));
    });

    test('hasMore false stops further fetches', () async {
      final users = _generateUsers(2);
      fakeRepo.queryResults.add(
        Success(PaginatedResult(items: users, hasMore: false)),
      );

      final container = createContainer();
      await waitForInitialLoad(container);

      final callsBefore = fakeRepo.queryCallCount;

      await container
          .read(exploreViewModelProvider.notifier)
          .loadNextPage();

      // No additional calls.
      expect(fakeRepo.queryCallCount, callsBefore);
    });

    test('pull-to-refresh resets cursor and reloads from page 1', () async {
      final page1Users = _generateUsers(3);
      final refreshUsers = _generateUsers(2, startIndex: 10);

      fakeRepo.queryResults.addAll([
        Success(
            PaginatedResult(items: page1Users, hasMore: true, cursor: 'c1')),
        Success(PaginatedResult(
            items: refreshUsers, hasMore: false, cursor: 'c2')),
      ]);

      final container = createContainer();
      await waitForInitialLoad(container);

      expect(container.read(exploreViewModelProvider).items, hasLength(3));

      await container.read(exploreViewModelProvider.notifier).refresh();

      final state = container.read(exploreViewModelProvider);
      expect(state.items, hasLength(2));
      expect(state.items.first.id, 'user-10');
    });

    test('error on first page sets firstPageError', () async {
      fakeRepo.queryResults.add(
        const Failure(NetworkException('Network error')),
      );

      final container = createContainer();
      await waitForInitialLoad(container);

      final state = container.read(exploreViewModelProvider);
      expect(state.firstPageError, isNotNull);
      expect(state.items, isEmpty);
      expect(state.isLoadingFirstPage, isFalse);
    });

    test('error on subsequent page preserves items and shows nextPageError',
        () async {
      final page1Users = _generateUsers(3);

      fakeRepo.queryResults.addAll([
        Success(
            PaginatedResult(items: page1Users, hasMore: true, cursor: 'c1')),
        const Failure(PermissionException()),
      ]);

      final container = createContainer();
      await waitForInitialLoad(container);

      await container
          .read(exploreViewModelProvider.notifier)
          .loadNextPage();

      final state = container.read(exploreViewModelProvider);
      expect(state.items, hasLength(3));
      expect(state.nextPageError, isNotNull);
      expect(state.isLoadingNextPage, isFalse);
    });

    test('concurrent loadNextPage calls are guarded', () async {
      final page1Users = _generateUsers(3);
      final page2Users = _generateUsers(2, startIndex: 4);

      fakeRepo.queryResults.addAll([
        Success(
            PaginatedResult(items: page1Users, hasMore: true, cursor: 'c1')),
        Success(
            PaginatedResult(items: page2Users, hasMore: false, cursor: 'c2')),
      ]);

      final container = createContainer();
      await waitForInitialLoad(container);

      final callsBefore = fakeRepo.queryCallCount;

      final f1 = container
          .read(exploreViewModelProvider.notifier)
          .loadNextPage();
      final f2 = container
          .read(exploreViewModelProvider.notifier)
          .loadNextPage();

      await Future.wait([f1, f2]);

      expect(fakeRepo.queryCallCount, callsBefore + 1);
    });
  });
}
