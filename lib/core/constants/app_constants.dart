/// Centralised application constants.
///
/// Environment-dependent values are read from dotenv at runtime.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // Environment
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // App metadata
  // ---------------------------------------------------------------------------

  /// Application title used where a plain [String] is required (e.g.
  /// [MaterialApp.title]) and [AppLocalizations] is not available.
  static const String appTitle = 'Launchpad';

  // ---------------------------------------------------------------------------
  // Environment
  // ---------------------------------------------------------------------------

  // Used by ApiClient as the Dio base URL — set BASE_URL in your .env file.

  /// Base URL for the API, sourced from the `.env` file.
  static String get baseUrl {
    final value = dotenv.env['BASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'BASE_URL is not set. '
        'Ensure your .env file contains a BASE_URL entry.',
      );
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // Biometric
  // ---------------------------------------------------------------------------

  /// Grace period in seconds before requiring biometric re-authentication
  /// after the app returns from the background.
  static const int biometricGracePeriodSeconds = 30;
}
