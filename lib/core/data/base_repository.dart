/// Abstract base repository defining the CRUD + watch + query contract.
///
/// All feature repositories expose this interface. No Firebase or
/// persistence-specific imports belong here — this is a pure contract.
library;

import 'paginated_result.dart';
import 'query_options.dart';
import 'result.dart';

/// Generic repository contract for a single document type [T].
abstract class BaseRepository<T> {
  Future<Result<T>> create(T model);

  Future<Result<T>> read(String id);

  Future<Result<T>> update(String id, T model);

  Future<Result<void>> delete(String id);

  Stream<Result<T>> watchStream(String id);

  /// Returns a paginated list of documents matching [options].
  ///
  /// Pass `cursor: null` in [options] for the first page. For subsequent
  /// pages, pass the [PaginatedResult.cursor] from the previous response
  /// via [QueryOptions.copyWith].
  ///
  /// Returns [Failure] with [InvalidQueryException] if [options.pageSize]
  /// is zero or negative.
  Future<Result<PaginatedResult<T>>> queryList(QueryOptions options);
}
