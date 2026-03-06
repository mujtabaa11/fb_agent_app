/// ViewModel for the Explore screen's paginated user list.
///
/// Depends on [BaseRepository<UserProfileModel>] via DI — zero imports of
/// FirestoreRepository or cloud_firestore.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/base_repository.dart';
import '../../../core/data/query_options.dart';
import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../profile/data/user_profile_model.dart';
import 'explore_state.dart';

part 'explore_view_model.g.dart';

/// Default page size for the explore list.
const int _kPageSize = 20;

/// Manages paginated query state for the Explore screen.
@riverpod
class ExploreViewModel extends _$ExploreViewModel {
  @override
  ExploreState build() {
    // Trigger initial load on first build.
    Future.microtask(loadInitialPage);
    return const ExploreState(isLoadingFirstPage: true);
  }

  /// Fetches the first page, resetting all accumulated state.
  Future<void> loadInitialPage() async {
    if (state.isLoadingFirstPage && state.items.isNotEmpty) return;

    state = const ExploreState(isLoadingFirstPage: true);

    final BaseRepository<UserProfileModel> repository =
        ref.read(userProfileRepositoryProvider);

    const options = QueryOptions(
      pageSize: _kPageSize,
      orderBy: 'createdAt',
      descending: true,
    );

    final result = await repository.queryList(options);

    state = switch (result) {
      Success(:final value) => ExploreState(
          items: value.items,
          hasMore: value.hasMore,
          cursor: value.cursor,
        ),
      Failure(:final exception) => ExploreState(
          firstPageError: exception.message,
        ),
    };
  }

  /// Fetches the next page and appends items to the existing list.
  ///
  /// Guards against concurrent fetches — silently returns if a fetch
  /// is already in progress or there are no more pages.
  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(
      isLoadingNextPage: true,
      nextPageError: () => null,
    );

    final BaseRepository<UserProfileModel> repository =
        ref.read(userProfileRepositoryProvider);

    final options = QueryOptions(
      pageSize: _kPageSize,
      orderBy: 'createdAt',
      descending: true,
      cursor: state.cursor,
    );

    final result = await repository.queryList(options);

    state = switch (result) {
      Success(:final value) => state.copyWith(
          items: [...state.items, ...value.items],
          hasMore: value.hasMore,
          isLoadingNextPage: false,
          cursor: () => value.cursor,
        ),
      Failure(:final exception) => state.copyWith(
          isLoadingNextPage: false,
          nextPageError: () => exception.message,
        ),
    };
  }

  /// Resets the cursor and reloads from page 1 (pull-to-refresh).
  Future<void> refresh() async {
    state = const ExploreState(isLoadingFirstPage: true);

    final BaseRepository<UserProfileModel> repository =
        ref.read(userProfileRepositoryProvider);

    const options = QueryOptions(
      pageSize: _kPageSize,
      orderBy: 'createdAt',
      descending: true,
    );

    final result = await repository.queryList(options);

    state = switch (result) {
      Success(:final value) => ExploreState(
          items: value.items,
          hasMore: value.hasMore,
          cursor: value.cursor,
        ),
      Failure(:final exception) => ExploreState(
          firstPageError: exception.message,
        ),
    };
  }
}
