/// Immutable state for the Explore screen's paginated user list.
library;

import '../../profile/data/user_profile_model.dart';

/// Explore screen state.
class ExploreState {
  const ExploreState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingFirstPage = false,
    this.isLoadingNextPage = false,
    this.firstPageError,
    this.nextPageError,
    this.cursor,
  });

  /// Accumulated user profiles across all loaded pages.
  final List<UserProfileModel> items;

  /// Whether more pages are available beyond the currently loaded data.
  final bool hasMore;

  /// `true` while the first page is being fetched.
  final bool isLoadingFirstPage;

  /// `true` while a subsequent page is being fetched.
  final bool isLoadingNextPage;

  /// Non-null when the first page fetch failed.
  final String? firstPageError;

  /// Non-null when a subsequent page fetch failed (items remain visible).
  final String? nextPageError;

  /// Opaque pagination cursor from the last successful page.
  final Object? cursor;

  /// Whether any fetch is currently in progress.
  bool get isLoading => isLoadingFirstPage || isLoadingNextPage;

  ExploreState copyWith({
    List<UserProfileModel>? items,
    bool? hasMore,
    bool? isLoadingFirstPage,
    bool? isLoadingNextPage,
    String? Function()? firstPageError,
    String? Function()? nextPageError,
    Object? Function()? cursor,
  }) {
    return ExploreState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      firstPageError:
          firstPageError != null ? firstPageError() : this.firstPageError,
      nextPageError:
          nextPageError != null ? nextPageError() : this.nextPageError,
      cursor: cursor != null ? cursor() : this.cursor,
    );
  }
}
