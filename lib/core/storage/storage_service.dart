// Storage abstraction for the app.
//
// Two concrete implementations exist:
//   • SecureStorageService — backed by flutter_secure_storage.
//     Use for sensitive data: auth tokens, credentials, personal identifiers.
//   • PrefsStorageService  — backed by SharedPreferences.
//     Use for non-sensitive data: theme preference, locale, UI settings.

/// Key-value storage contract.
///
/// All implementations guarantee:
///   • [read] returns `null` for non-existent keys — never throws.
///   • Internal errors are caught and logged via `debugPrint` — callers
///     never see uncaught exceptions.
abstract class StorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
