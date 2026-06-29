/// Tests for [QueryOptions] and [QueryFilter].
///
/// Validates construction, copyWith behavior (especially cursor sentinel
/// handling), and all [FilterOperator] enum values.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/data/query_options.dart';

void main() {
  group('QueryOptions', () {
    test('constructs with required parameters and defaults', () {
      const options = QueryOptions(pageSize: 20, orderBy: 'createdAt');

      expect(options.pageSize, 20);
      expect(options.orderBy, 'createdAt');
      expect(options.descending, isFalse);
      expect(options.filters, isEmpty);
      expect(options.cursor, isNull);
    });

    test('constructs with all parameters', () {
      final options = QueryOptions(
        pageSize: 10,
        orderBy: 'name',
        descending: true,
        filters: [
          const QueryFilter(
            field: 'status',
            operator: FilterOperator.isEqualTo,
            value: 'active',
          ),
        ],
        cursor: 'some-cursor',
      );

      expect(options.pageSize, 10);
      expect(options.orderBy, 'name');
      expect(options.descending, isTrue);
      expect(options.filters, hasLength(1));
      expect(options.cursor, 'some-cursor');
    });

    group('copyWith', () {
      test('updates cursor while preserving all other fields', () {
        const original = QueryOptions(
          pageSize: 15,
          orderBy: 'createdAt',
          descending: true,
        );

        final updated = original.copyWith(cursor: 'new-cursor');

        expect(updated.pageSize, 15);
        expect(updated.orderBy, 'createdAt');
        expect(updated.descending, isTrue);
        expect(updated.filters, isEmpty);
        expect(updated.cursor, 'new-cursor');
      });

      test('explicitly setting cursor to null resets it', () {
        final original = QueryOptions(
          pageSize: 20,
          orderBy: 'createdAt',
          cursor: 'existing-cursor',
        );

        final reset = original.copyWith(cursor: null);

        expect(reset.cursor, isNull);
        expect(reset.pageSize, 20);
        expect(reset.orderBy, 'createdAt');
      });

      test('omitting cursor preserves the current value', () {
        final original = QueryOptions(
          pageSize: 20,
          orderBy: 'createdAt',
          cursor: 'preserved-cursor',
        );

        final copy = original.copyWith(pageSize: 30);

        expect(copy.cursor, 'preserved-cursor');
        expect(copy.pageSize, 30);
      });

      test('updates multiple fields', () {
        const original = QueryOptions(
          pageSize: 20,
          orderBy: 'createdAt',
        );

        final updated = original.copyWith(
          pageSize: 50,
          orderBy: 'name',
          descending: true,
        );

        expect(updated.pageSize, 50);
        expect(updated.orderBy, 'name');
        expect(updated.descending, isTrue);
      });
    });
  });

  group('QueryFilter', () {
    test('constructs correctly for isEqualTo', () {
      const filter = QueryFilter(
        field: 'status',
        operator: FilterOperator.isEqualTo,
        value: 'active',
      );

      expect(filter.field, 'status');
      expect(filter.operator, FilterOperator.isEqualTo);
      expect(filter.value, 'active');
    });

    test('constructs correctly for isNotEqualTo', () {
      const filter = QueryFilter(
        field: 'role',
        operator: FilterOperator.isNotEqualTo,
        value: 'admin',
      );

      expect(filter.operator, FilterOperator.isNotEqualTo);
      expect(filter.value, 'admin');
    });

    test('constructs correctly for isLessThan', () {
      const filter = QueryFilter(
        field: 'age',
        operator: FilterOperator.isLessThan,
        value: 30,
      );

      expect(filter.operator, FilterOperator.isLessThan);
      expect(filter.value, 30);
    });

    test('constructs correctly for isLessThanOrEqualTo', () {
      const filter = QueryFilter(
        field: 'age',
        operator: FilterOperator.isLessThanOrEqualTo,
        value: 30,
      );

      expect(filter.operator, FilterOperator.isLessThanOrEqualTo);
    });

    test('constructs correctly for isGreaterThan', () {
      const filter = QueryFilter(
        field: 'score',
        operator: FilterOperator.isGreaterThan,
        value: 100,
      );

      expect(filter.operator, FilterOperator.isGreaterThan);
    });

    test('constructs correctly for isGreaterThanOrEqualTo', () {
      const filter = QueryFilter(
        field: 'score',
        operator: FilterOperator.isGreaterThanOrEqualTo,
        value: 100,
      );

      expect(filter.operator, FilterOperator.isGreaterThanOrEqualTo);
    });

    test('constructs correctly for arrayContains', () {
      const filter = QueryFilter(
        field: 'tags',
        operator: FilterOperator.arrayContains,
        value: 'flutter',
      );

      expect(filter.operator, FilterOperator.arrayContains);
      expect(filter.value, 'flutter');
    });

    test('constructs correctly for whereIn with list value', () {
      const filter = QueryFilter(
        field: 'status',
        operator: FilterOperator.whereIn,
        value: ['active', 'pending'],
      );

      expect(filter.operator, FilterOperator.whereIn);
      expect(filter.value, ['active', 'pending']);
    });
  });

  group('FilterOperator', () {
    test('has exactly 8 values', () {
      expect(FilterOperator.values, hasLength(8));
    });
  });
}
