/// Concrete Firestore-backed repository.
///
/// This is the **only** file in the codebase that imports `cloud_firestore`.
/// Feature code never touches Firestore directly — it depends on
/// [BaseRepository<T>] via DI.
library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/app_exceptions.dart';
import 'base_repository.dart';
import 'paginated_result.dart';
import 'query_options.dart';
import 'result.dart';

/// Firestore implementation of [BaseRepository].
///
/// [collectionPath] — Firestore collection path. Supports nested
/// subcollections (e.g. `users/{userId}/posts`). The caller is responsible
/// for substituting dynamic path segments before constructing the instance.
///
/// [fromJson] — Deserialises a Firestore document map into [T].
///
/// [toJson] — Serialises a [T] instance into a Firestore-compatible map.
class FirestoreRepository<T> implements BaseRepository<T> {
  FirestoreRepository({
    required this.collectionPath,
    required this.fromJson,
    required this.toJson,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _collection = (firestore ?? FirebaseFirestore.instance)
            .collection(collectionPath)
            .withConverter<T>(
              fromFirestore: (snapshot, _) =>
                  fromJson(snapshot.data()!),
              toFirestore: (model, _) => toJson(model),
            );

  final String collectionPath;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T model) toJson;
  final FirebaseFirestore _firestore;
  final CollectionReference<T> _collection;

  @override
  Future<Result<T>> create(T model) async {
    try {
      final data = toJson(model);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(collectionPath)
          .add(data);

      final snapshot = await _collection.doc(docRef.id).get();
      return Success(snapshot.data() as T);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<T>> read(String id) async {
    try {
      final snapshot = await _collection.doc(id).get();

      if (!snapshot.exists) {
        return Failure(const DocumentNotFoundException());
      }

      return Success(snapshot.data() as T);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<T>> update(String id, T model) async {
    try {
      final data = toJson(model);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(collectionPath)
          .doc(id)
          .update(data);

      return Success(model);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  @override
  Stream<Result<T>> watchStream(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .transform(StreamTransformer<DocumentSnapshot<T>, Result<T>>.fromHandlers(
          handleData: (snapshot, sink) {
            if (!snapshot.exists) {
              sink.add(Failure<T>(const DocumentNotFoundException()));
            } else {
              sink.add(Success<T>(snapshot.data() as T));
            }
          },
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseException) {
              sink.add(Failure<T>(_mapFirebaseException(error)));
            } else if (error is SocketException) {
              sink.add(Failure<T>(const NetworkException()));
            } else {
              sink.add(Failure<T>(DataException(originalMessage: error.toString())));
            }
          },
        ));
  }

  @override
  Future<Result<PaginatedResult<T>>> queryList(QueryOptions options) async {
    // ── Input validation ──────────────────────────────────────────────
    if (options.pageSize <= 0) {
      return Failure(
        const InvalidQueryException('pageSize must be greater than zero.'),
      );
    }

    int arrayContainsCount = 0;
    for (final filter in options.filters) {
      if (filter.operator == FilterOperator.whereIn) {
        final values = filter.value as List;
        if (values.length > 30) {
          return Failure(
            InvalidQueryException(
              'whereIn filter on "${filter.field}" has ${values.length} values '
              '(maximum is 30).',
            ),
          );
        }
      }
      if (filter.operator == FilterOperator.arrayContains) {
        arrayContainsCount++;
        if (arrayContainsCount > 1) {
          return Failure(
            const InvalidQueryException(
              'Only one arrayContains filter is allowed per query.',
            ),
          );
        }
      }
    }

    // ── Build the Firestore query ─────────────────────────────────────
    try {
      Query<T> query = _collection;

      for (final filter in options.filters) {
        query = switch (filter.operator) {
          FilterOperator.isEqualTo =>
            query.where(filter.field, isEqualTo: filter.value),
          FilterOperator.isNotEqualTo =>
            query.where(filter.field, isNotEqualTo: filter.value),
          FilterOperator.isLessThan =>
            query.where(filter.field, isLessThan: filter.value),
          FilterOperator.isLessThanOrEqualTo =>
            query.where(filter.field, isLessThanOrEqualTo: filter.value),
          FilterOperator.isGreaterThan =>
            query.where(filter.field, isGreaterThan: filter.value),
          FilterOperator.isGreaterThanOrEqualTo =>
            query.where(filter.field, isGreaterThanOrEqualTo: filter.value),
          FilterOperator.arrayContains =>
            query.where(filter.field, arrayContains: filter.value),
          FilterOperator.whereIn =>
            query.where(filter.field, whereIn: filter.value as List),
        };
      }

      query = query.orderBy(options.orderBy, descending: options.descending);

      if (options.cursor != null) {
        query = query.startAfterDocument(
          options.cursor! as DocumentSnapshot<Object?>,
        );
      }

      query = query.limit(options.pageSize + 1);

      // ── Execute and process results using the +1 strategy ───────────
      final snapshot = await query.get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        return const Success(
          PaginatedResult(items: [], cursor: null, hasMore: false),
        );
      }

      final bool hasMore = docs.length > options.pageSize;
      final pageDocs = hasMore ? docs.sublist(0, options.pageSize) : docs;
      final items = pageDocs.map((doc) => doc.data()).toList();
      final cursor = pageDocs.last;

      return Success(
        PaginatedResult(items: items, cursor: cursor, hasMore: hasMore),
      );
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseQueryException(e));
    } on SocketException {
      return Failure(const NetworkException());
    } on Exception catch (e) {
      return Failure(DataException(originalMessage: e.toString()));
    }
  }

  /// Maps a [FirebaseException] from a query to a typed [AppException].
  ///
  /// Extends the standard CRUD mapping with detection of missing composite
  /// index errors, preserving the index-creation URL for developer debugging.
  static AppException _mapFirebaseQueryException(FirebaseException e) {
    final message = e.message ?? '';

    // Firestore "requires an index" errors contain the index-creation URL.
    if (message.contains('requires an index')) {
      final urlMatch = RegExp(r'https://\S+').firstMatch(message);
      final url = urlMatch?.group(0) ?? '';
      return DataException(
        message: 'This query requires a composite index.',
        originalMessage: url.isNotEmpty
            ? 'Create the index: $url'
            : message,
      );
    }

    return _mapFirebaseException(e);
  }

  /// Maps a [FirebaseException] to a typed [AppException].
  static AppException _mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'not-found' => const DocumentNotFoundException(),
      'permission-denied' => const PermissionException(),
      'unavailable' || 'cancelled' => const NetworkException(),
      _ => DataException(originalMessage: e.message),
    };
  }
}
