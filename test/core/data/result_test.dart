/// Tests for the [Result<T>] sealed type.
///
/// Verifies that [Success] and [Failure] carry the correct payloads and
/// that pattern matching (switch expressions) works correctly on both states.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:template_app/core/data/result.dart';
import 'package:template_app/core/errors/app_exceptions.dart';

void main() {
  group('Success', () {
    test('carries the correct value', () {
      const result = Success(42);
      expect(result.value, 42);
    });

    test('carries a null value when T is nullable', () {
      const result = Success<String?>(null);
      expect(result.value, isNull);
    });

    test('carries complex objects', () {
      final list = [1, 2, 3];
      final result = Success(list);
      expect(result.value, same(list));
    });

    test('is a Result<T>', () {
      const Result<int> result = Success(1);
      expect(result, isA<Result<int>>());
      expect(result, isA<Success<int>>());
    });
  });

  group('Failure', () {
    test('carries a typed AppException', () {
      const result = Failure<String>(NetworkException());
      expect(result.exception, isA<NetworkException>());
    });

    test('carries DocumentNotFoundException', () {
      const result = Failure<int>(DocumentNotFoundException());
      expect(result.exception, isA<DocumentNotFoundException>());
      expect(result.exception.message, 'Document not found.');
    });

    test('carries AuthException with error code', () {
      const exception = AuthException.coded(
        'Email already in use',
        code: 'email-already-in-use',
      );
      const result = Failure<void>(exception);
      final failure = result.exception as AuthException;
      expect(failure.code, 'email-already-in-use');
      expect(failure.message, 'Email already in use');
    });

    test('carries PermissionException', () {
      const result = Failure<void>(PermissionException());
      expect(result.exception, isA<PermissionException>());
    });

    test('is a Result<T>', () {
      const Result<int> result = Failure(NetworkException());
      expect(result, isA<Result<int>>());
      expect(result, isA<Failure<int>>());
    });
  });

  group('pattern matching', () {
    test('matches Success branch and extracts value', () {
      const Result<String> result = Success('hello');

      final output = switch (result) {
        Success(:final value) => 'got: $value',
        Failure(:final exception) => 'error: ${exception.message}',
      };

      expect(output, 'got: hello');
    });

    test('matches Failure branch and extracts exception', () {
      const Result<String> result = Failure(NetworkException());

      final output = switch (result) {
        Success(:final value) => 'got: $value',
        Failure(:final exception) => 'error: ${exception.runtimeType}',
      };

      expect(output, 'error: NetworkException');
    });

    test('exhaustive matching covers both states without default', () {
      // This test verifies that the sealed class enforces exhaustive matching
      // at compile time. If it compiles, the contract is satisfied.
      String describe(Result<int> result) {
        return switch (result) {
          Success(:final value) => 'success: $value',
          Failure(:final exception) => 'failure: ${exception.message}',
        };
      }

      expect(describe(const Success(1)), 'success: 1');
      expect(
        describe(const Failure(NetworkException())),
        'failure: No internet connection. Please try again.',
      );
    });

    test('can be used with is-checks', () {
      const Result<int> success = Success(1);
      const Result<int> failure = Failure(NetworkException());

      expect(success is Success<int>, isTrue);
      expect(success is Failure<int>, isFalse);
      expect(failure is Failure<int>, isTrue);
      expect(failure is Success<int>, isFalse);
    });
  });
}
