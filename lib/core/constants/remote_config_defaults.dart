/// Central registry of Remote Config default values.
///
/// Every feature flag or remote parameter used in the app must have its
/// default value defined here. This ensures a single source of truth and
/// guarantees that the app always has a fallback value — even when the
/// device is offline or a key has not yet been published in the Firebase
/// Console.
///
/// ## Adding a new flag
///
/// 1. Add an entry to [defaults] with the key name and its default value.
/// 2. Create the matching key in the Firebase Console → Remote Config.
/// 3. Read the value via [RemoteConfigService] (e.g.
///    `remoteConfigService.getBool('my_flag')`).
///
/// Supported value types: `bool`, `int`, `double`, `String`.
library;

/// Default values for Firebase Remote Config parameters.
///
/// In V1.1 this map is intentionally empty — it exists to establish the
/// pattern. Downstream projects add their own flag keys here as they
/// define new remote parameters.
abstract final class RemoteConfigDefaults {
  /// Map of all default values keyed by their Remote Config parameter name.
  ///
  /// Example:
  /// ```dart
  /// static const Map<String, dynamic> defaults = {
  ///   'enable_new_onboarding': false,
  ///   'max_retry_count': 3,
  ///   'api_timeout_seconds': 30.0,
  ///   'welcome_message': 'Hello!',
  /// };
  /// ```
  static const Map<String, dynamic> defaults = {
    'phone_auth_enabled': false,
  };
}
