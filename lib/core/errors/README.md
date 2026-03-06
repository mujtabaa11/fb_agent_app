# core/errors/

Custom exception and failure types used across the entire app. Centralising error definitions here ensures consistent error handling and makes it easy to map backend errors to user-facing messages.

## What belongs here

- Custom exception classes (e.g. `ServerException`, `CacheException`).
- Failure classes for typed error propagation (e.g. `NetworkFailure`, `AuthFailure`).
- A shared error-handling utility that maps exceptions to failures.

## What does NOT belong here

- Feature-specific error types that are only relevant within a single feature — keep those inside the feature module.
- UI widgets that display errors (those belong in `core/widgets/` or the feature's own screens).
- Logging or crash-reporting setup — that belongs in `core/utils/`.

## Example file

`app_exception.dart` — defines a sealed `AppException` class with variants like `AppException.network(message)` and `AppException.unauthorized()`.
