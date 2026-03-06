/// Backend-agnostic query options for paginated list operations.
///
/// [QueryOptions] describes *what* to query (filters, sort order, page size,
/// cursor) without exposing any persistence-specific types. The concrete
/// repository implementation (Firestore, REST, GraphQL, etc.) translates
/// these options into backend-native calls internally.
///
/// The [cursor] is intentionally typed as [Object?] — it is opaque to the
/// caller. The caller receives it from [PaginatedResult.cursor] and passes
/// it back into the next [QueryOptions] via [copyWith]. Only the concrete
/// repository knows how to interpret it.
library;

/// Sentinel used by [QueryOptions.copyWith] to distinguish "cursor not
/// provided" from "cursor explicitly set to null".
class _CursorSentinel {
  const _CursorSentinel();
}

const Object _cursorSentinel = _CursorSentinel();

/// Operators available for filtering query results.
///
/// Each value maps to a comparison supported by most backends. The concrete
/// repository translates these to the native filter syntax.
enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  whereIn,
}

/// A single filter clause applied to a query.
///
/// Multiple [QueryFilter]s can be combined in [QueryOptions.filters] to create
/// compound queries. Note that some backends impose restrictions on filter
/// combinations (e.g. Firestore requires composite indexes for certain
/// multi-field queries).
class QueryFilter {
  const QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// The document field name to filter on.
  final String field;

  /// The comparison operator.
  final FilterOperator operator;

  /// The value to compare against.
  ///
  /// For [FilterOperator.whereIn], this should be a `List`.
  /// For all other operators, this is typically a single value.
  final dynamic value;
}

/// Immutable query descriptor for paginated list operations.
///
/// Create an initial request with [cursor] as `null` for the first page.
/// For subsequent pages, use [copyWith] to carry the cursor forward:
///
/// ```dart
/// final firstPage = await repo.queryList(
///   QueryOptions(pageSize: 20, orderBy: 'createdAt'),
/// );
///
/// // Fetch the next page:
/// final nextPage = await repo.queryList(
///   options.copyWith(cursor: firstPage.cursor),
/// );
/// ```
class QueryOptions {
  const QueryOptions({
    required this.pageSize,
    required this.orderBy,
    this.descending = false,
    this.filters = const [],
    this.cursor,
  });

  /// Number of items to return per page.
  ///
  /// Must be greater than zero — passing `0` or a negative value causes
  /// `queryList` to return `Failure(InvalidQueryException)`.
  final int pageSize;

  /// The document field name to sort results by.
  final String orderBy;

  /// Whether to sort in descending order. Defaults to `false` (ascending).
  final bool descending;

  /// Optional list of filters to narrow results.
  ///
  /// Multiple filters create a compound query. Backend-specific constraints
  /// apply (e.g. Firestore requires composite indexes for some combinations).
  final List<QueryFilter> filters;

  /// Opaque pagination cursor.
  ///
  /// Pass `null` for the first page. For subsequent pages, pass the [cursor]
  /// from the previous [PaginatedResult]. Never inspect, cast, or serialise
  /// this value — only the concrete repository knows its type.
  final Object? cursor;

  /// Creates a copy of this [QueryOptions] with the given fields replaced.
  ///
  /// To explicitly reset [cursor] to `null` (e.g. for pull-to-refresh),
  /// pass `cursor: null`. Omitting the parameter preserves the current value.
  ///
  /// ```dart
  /// final nextPageOptions = options.copyWith(cursor: result.cursor);
  /// final refreshOptions = options.copyWith(cursor: null);
  /// ```
  QueryOptions copyWith({
    int? pageSize,
    String? orderBy,
    bool? descending,
    List<QueryFilter>? filters,
    Object? cursor = _cursorSentinel,
  }) =>
      QueryOptions(
        pageSize: pageSize ?? this.pageSize,
        orderBy: orderBy ?? this.orderBy,
        descending: descending ?? this.descending,
        filters: filters ?? this.filters,
        cursor: identical(cursor, _cursorSentinel) ? this.cursor : cursor,
      );
}
