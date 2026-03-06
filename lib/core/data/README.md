# core/data/ — Base Data Layer

This directory contains the data layer abstractions used across the entire app.
Feature code never imports `cloud_firestore` directly — all Firestore access
flows through these files.

## Files

| File | Role |
|---|---|
| `result.dart` | Sealed `Result<T>` type with `Success<T>` and `Failure` subtypes. Every data operation returns `Result<T>` instead of throwing. `Failure` wraps the existing `AppException` hierarchy — no parallel exception system. |
| `base_repository.dart` | Abstract `BaseRepository<T>` defining the CRUD + watch + query contract (`create`, `read`, `update`, `delete`, `watchStream`, `queryList`). Contains zero persistence-specific imports. |
| `firestore_repository.dart` | Concrete `FirestoreRepository<T>` implementing `BaseRepository<T>`. This is the **only** file in the codebase that imports `cloud_firestore`. |
| `query_options.dart` | `QueryOptions`, `QueryFilter`, and `FilterOperator` — plain Dart types describing what to query (filters, sort order, page size, cursor) without exposing any backend-specific types. Zero Firebase imports. |
| `paginated_result.dart` | `PaginatedResult<T>` — a page of results with an opaque cursor and `hasMore` flag. Zero Firebase imports. |

## Adding a New Feature Repository

1. **Create your model** with `fromJson` / `toJson`:

   ```dart
   class UserProfileModel {
     UserProfileModel({required this.displayName, required this.email});

     factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
         UserProfileModel(
           displayName: json['displayName'] as String,
           email: json['email'] as String,
         );

     final String displayName;
     final String email;

     Map<String, dynamic> toJson() => {
           'displayName': displayName,
           'email': email,
         };
   }
   ```

2. **Register in DI** (Riverpod provider file):

   ```dart
   @Riverpod(keepAlive: true)
   BaseRepository<UserProfileModel> userProfileRepository(
     UserProfileRepositoryRef ref,
   ) =>
       FirestoreRepository<UserProfileModel>(
         collectionPath: 'userProfiles',
         fromJson: UserProfileModel.fromJson,
         toJson: (model) => model.toJson(),
       );
   ```

3. **Inject in your ViewModel** — depend on `BaseRepository<UserProfileModel>`,
   never on `FirestoreRepository` directly:

   ```dart
   @riverpod
   class UserProfileNotifier extends _$UserProfileNotifier {
     @override
     Future<UserProfileModel?> build() async {
       final repo = ref.watch(userProfileRepositoryProvider);
       final result = await repo.read(userId);
       return switch (result) {
         Success(:final value) => value,
         Failure(:final exception) => throw exception,
       };
     }
   }
   ```

Zero Firestore imports outside `core/data/`.

## Nested Subcollections

`collectionPath` supports subcollection paths such as
`users/{userId}/posts`. The caller is responsible for substituting dynamic
path segments before constructing the `FirestoreRepository` instance:

```dart
FirestoreRepository<PostModel>(
  collectionPath: 'users/$userId/posts',
  fromJson: PostModel.fromJson,
  toJson: (model) => model.toJson(),
);
```

## Paginated List Queries

### The `queryList` Contract

`BaseRepository<T>` exposes a `queryList` method for paginated list operations:

```dart
Future<Result<PaginatedResult<T>>> queryList(QueryOptions options);
```

### `QueryOptions`

An immutable, plain Dart class describing what to query:

| Field | Type | Description |
|---|---|---|
| `pageSize` | `int` (required) | Number of items per page. Must be > 0 — zero or negative returns `Failure(InvalidQueryException)`. |
| `orderBy` | `String` (required) | The document field name to sort by. The caller is responsible for matching this to the model's actual field name. |
| `descending` | `bool` (default `false`) | Sort direction. |
| `filters` | `List<QueryFilter>` (default `[]`) | Optional filters to narrow results. Multiple filters create a compound query. |
| `cursor` | `Object?` (default `null`) | Opaque pagination cursor. Pass `null` for the first page. For subsequent pages, pass `PaginatedResult.cursor` from the previous response. |

Use `copyWith` to create the next-page request:

```dart
final options = QueryOptions(pageSize: 20, orderBy: 'createdAt', descending: true);
final result = await repo.queryList(options);

if (result case Success(:final value)) {
  if (value.hasMore) {
    final nextOptions = options.copyWith(cursor: value.cursor);
    final nextPage = await repo.queryList(nextOptions);
  }
}
```

To reset pagination (e.g. pull-to-refresh), pass `cursor: null` explicitly:

```dart
final refreshOptions = options.copyWith(cursor: null);
```

### `QueryFilter`

A single filter clause with three fields:

| Field | Type | Description |
|---|---|---|
| `field` | `String` | The document field name to filter on. |
| `operator` | `FilterOperator` | The comparison operator (see enum values below). |
| `value` | `dynamic` | The value to compare against. For `whereIn`, pass a `List`. |

**`FilterOperator` values:** `isEqualTo`, `isNotEqualTo`, `isLessThan`,
`isLessThanOrEqualTo`, `isGreaterThan`, `isGreaterThanOrEqualTo`,
`arrayContains`, `whereIn`.

Example with filters:

```dart
final options = QueryOptions(
  pageSize: 20,
  orderBy: 'createdAt',
  descending: true,
  filters: [
    QueryFilter(field: 'status', operator: FilterOperator.isEqualTo, value: 'active'),
    QueryFilter(field: 'age', operator: FilterOperator.isGreaterThan, value: 18),
  ],
);
```

### `PaginatedResult<T>`

Returned inside `Result<PaginatedResult<T>>`:

| Field | Type | Description |
|---|---|---|
| `items` | `List<T>` | The items in this page. |
| `cursor` | `Object?` | Opaque cursor for the next page. |
| `hasMore` | `bool` | `true` if more results exist beyond this page. |

The caller checks `hasMore` to decide whether to request another page — never
inspect the `cursor` value directly.

### The Opaque Cursor Pattern

The `cursor` field in both `QueryOptions` and `PaginatedResult` is typed as
`Object?`. This is intentional:

- **Firestore** stores a `DocumentSnapshot` inside the cursor.
- **REST APIs** might store a page token string.
- **Offset-based APIs** might store an `int`.

Feature code never knows or cares what the cursor contains. It receives the
cursor from `PaginatedResult.cursor` and passes it back into
`QueryOptions.cursor` — that's it. Only the concrete repository implementation
knows how to interpret the cursor internally.

### The `+1` Fetch Strategy

`FirestoreRepository` determines `hasMore` by fetching `pageSize + 1`
documents. If `pageSize + 1` items are returned, `hasMore` is `true` and the
extra item is excluded from `items`. If `pageSize` or fewer items are returned,
`hasMore` is `false`. This avoids a separate count query.

### Firestore Composite Indexes

Firestore requires composite indexes for queries that combine:

- `orderBy` on one field with `where` on a **different** field
- Range filters (`<`, `<=`, `>`, `>=`) on multiple fields

When Firestore throws a "requires an index" error, `FirestoreRepository`
catches it and includes the index-creation URL in the `DataException` message.
Click the URL in the error log to create the index in the Firebase Console.

**Firestore filter constraints:**

- `whereIn` is limited to **30 values** per query.
- Only **one** `arrayContains` filter is allowed per query.
- Range filters and inequality (`!=`) on different fields require a composite
  index.

### Migration Flexibility

The query interface is designed so that replacing Firestore with another backend
requires **zero changes to feature code**. To migrate:

1. Create a new repository class (e.g. `SupabaseRepository<T>`) implementing
   `BaseRepository<T>`.
2. Implement `queryList` by translating `QueryOptions` to your backend's native
   query syntax:
   - `orderBy` / `descending` → your backend's sort clause
   - `filters` → your backend's filter/where clause
   - `cursor` → your backend's pagination token (page token, offset, etc.)
   - `pageSize` → your backend's limit clause
3. Produce a `PaginatedResult<T>` with the appropriate cursor for the next page.
4. Update the DI provider to return your new repository instead of
   `FirestoreRepository`.

Feature code continues to call `queryList(QueryOptions(...))` unchanged.

## Out of Scope

The base layer intentionally does **not** cover:

- **Transactions** — use `FirebaseFirestore.instance.runTransaction()`
  directly in your repository or service layer.
- **Batch writes** — use `FirebaseFirestore.instance.batch()` directly.
- **Real-time paginated list updates** — the `queryList` pattern uses one-shot
  queries with pull-to-refresh. Real-time list updates via snapshot listeners
  require a different architecture and are project-specific.
- **Server-side pagination (REST page tokens, offset-based)** — the
  `BaseRepository<T>` contract supports it (the cursor is `Object?`), but the
  implementation is project-specific. See [Migration Flexibility](#migration-flexibility).

These are project-specific concerns that vary widely and should be implemented
directly where needed.
