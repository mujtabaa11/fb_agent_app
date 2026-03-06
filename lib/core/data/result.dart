/// Sealed result type for all data operations.
///
/// Every repository and data-access service method that returns a value to a
/// ViewModel or widget uses [Result<T>] instead of throwing. The only
/// exceptions are fire-and-forget services (analytics, crashlytics,
/// notifications, local storage) where callers don't act on failure.
/// Consumers pattern-match on [Success] or [Failure].
library;

import '../errors/app_exceptions.dart';

/// The single error-handling contract for all data operations.
sealed class Result<T> {
  const Result();
}

/// A successful result carrying a [value].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// A failed result carrying an [exception].
final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  final AppException exception;
}
