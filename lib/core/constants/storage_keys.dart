// Add all SharedPreferences and SecureStorage keys here as constants —
// never use inline strings for storage keys.

/// Centralised storage key constants for [SharedPreferences] and
/// [FlutterSecureStorage].
abstract final class StorageKeys {
  /// Key for the persisted theme mode preference.
  static const String themeMode = 'theme_mode';

  /// Key for the persisted locale preference.
  static const String locale = 'locale';

  /// Key for the authenticated user's ID.
  static const String userId = 'user_id';

  /// Key for the onboarding completion flag.
  static const String hasCompletedOnboarding = 'has_completed_onboarding';

  /// Base key for the biometric lock preference (secure storage).
  static const String biometricEnabled = 'biometric_enabled';

  /// Returns the user-scoped biometric preference key.
  static String biometricEnabledForUser(String userId) =>
      '${biometricEnabled}_$userId';
}
