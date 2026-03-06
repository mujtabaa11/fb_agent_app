/// Typed application exceptions.
///
/// All raw platform exceptions (Firebase, Dio, etc.) must be caught in the
/// repository layer and rethrown as one of these typed exceptions. No raw
/// exceptions should ever reach the UI.
library;

/// Abstract base class for all application exceptions.
abstract class AppException implements Exception {
  const AppException(this.message);

  /// Human-readable description of the error.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails due to connectivity issues.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Thrown when an authentication operation fails.
class AuthException extends AppException {
  const AuthException([
    super.message = 'Authentication failed. Please log in again.',
  ]) : code = null;

  /// Creates an [AuthException] with a provider error [code].
  const AuthException.coded(super.message, {required this.code});

  /// The original error code from the auth provider (e.g. Firebase).
  final String? code;
}

/// Thrown when SSO sign-in fails because the email is already registered under
/// a different provider. Carries the conflicting [email] so the UI can display
/// a linking dialog.
class AccountLinkException extends AuthException {
  const AccountLinkException({
    required this.email,
    String message = 'An account already exists with a different sign-in method.',
  }) : super.coded(message, code: 'account-exists-with-different-credential');

  /// The email address associated with the existing account.
  final String email;
}

/// Thrown when a server returns an unexpected status code.
class ServerException extends AppException {
  const ServerException({
    String message = 'Server error. Please try again later.',
    required this.statusCode,
  }) : super(message);

  /// The HTTP status code returned by the server.
  final int statusCode;
}

/// Thrown when an operation exceeds its time limit.
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Request timed out. Please try again.',
  ]);
}

/// Thrown when Firebase App Check activation or token retrieval fails.
class AppCheckException extends AppException {
  const AppCheckException([
    super.message = 'App Check verification failed. Please try again.',
  ]);
}

/// Thrown when a Firestore document does not exist.
class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException([
    super.message = 'Document not found.',
  ]);
}

/// Thrown when Firestore returns a permission-denied error.
class PermissionException extends AppException {
  const PermissionException([
    super.message = 'You do not have permission to perform this action.',
  ]);
}

/// Thrown when a file does not exist in Cloud Storage.
class FileNotFoundException extends AppException {
  const FileNotFoundException([
    super.message = 'File not found.',
  ]);
}

/// Thrown when an operation is cancelled by the user.
class CancelledException extends AppException {
  const CancelledException([
    super.message = 'Operation was cancelled.',
  ]);
}

/// Thrown when a query has invalid parameters (e.g. `pageSize <= 0`,
/// `whereIn` with more than 30 values).
class InvalidQueryException extends AppException {
  const InvalidQueryException([
    super.message = 'Invalid query parameters.',
  ]);
}

/// Thrown for any [FirebaseException] not covered by a more specific subclass.
///
/// Carries the [originalMessage] from the underlying Firebase error for
/// logging and debugging purposes.
class DataException extends AppException {
  const DataException({
    String message = 'A data error occurred.',
    this.originalMessage,
  }) : super(message);

  /// The error message from the original [FirebaseException].
  final String? originalMessage;
}
