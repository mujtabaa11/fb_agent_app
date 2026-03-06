/// A single page of query results with pagination metadata.
///
/// Returned by [BaseRepository.queryList]. The caller uses [hasMore] to
/// decide whether to request another page and passes [cursor] into the
/// next [QueryOptions] via [QueryOptions.copyWith]:
///
/// ```dart
/// final result = await repo.queryList(options);
/// if (result case Success(:final value)) {
///   addItems(value.items);
///   if (value.hasMore) {
///     nextOptions = options.copyWith(cursor: value.cursor);
///   }
/// }
/// ```
///
/// This class contains zero Firebase imports — it is a pure Dart type usable
/// with any backend.
library;

/// A page of results from a paginated list query.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.cursor,
  });

  /// The items in this page.
  final List<T> items;

  /// Opaque cursor to pass into the next [QueryOptions] for the next page.
  ///
  /// May be `null` on the last page. The caller should check [hasMore]
  /// rather than inspecting this value.
  final Object? cursor;

  /// Whether more results exist beyond this page.
  ///
  /// When `false`, this is the last page — do not request another.
  final bool hasMore;
}
