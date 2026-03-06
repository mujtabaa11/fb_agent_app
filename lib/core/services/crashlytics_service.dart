/// Crashlytics abstraction for crash reporting and non-fatal error logging.
///
/// Ships with a [NoOpCrashlyticsService] stub for testing and a
/// [FirebaseCrashlyticsService] for production use.
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crashlytics_service.g.dart';

/// Contract for crash reporting and error logging.
abstract class CrashlyticsService {
  /// Log a fatal error (unhandled crash).
  Future<void> logError(Object exception, StackTrace stackTrace);

  /// Record a non-fatal error (caught exception).
  Future<void> recordError(Object exception, StackTrace stackTrace);

  /// Set a non-sensitive user identifier for crash reports.
  Future<void> setUserIdentifier(String identifier);

  /// Set a non-sensitive custom key-value pair for crash reports.
  Future<void> setCustomKey(String key, Object value);

  /// Enable or disable Crashlytics collection (e.g. for GDPR opt-out).
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}

/// A no-op implementation that only prints in debug mode.
class NoOpCrashlyticsService implements CrashlyticsService {
  @override
  Future<void> logError(Object exception, StackTrace stackTrace) async {
    assert(() {
      debugPrint('[Crashlytics] logError: $exception');
      debugPrint('[Crashlytics] stackTrace: $stackTrace');
      return true;
    }());
  }

  @override
  Future<void> recordError(Object exception, StackTrace stackTrace) async {
    assert(() {
      debugPrint('[Crashlytics] recordError: $exception');
      debugPrint('[Crashlytics] stackTrace: $stackTrace');
      return true;
    }());
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    assert(() {
      debugPrint('[Crashlytics] setUserIdentifier: $identifier');
      return true;
    }());
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    assert(() {
      debugPrint('[Crashlytics] setCustomKey: $key = $value');
      return true;
    }());
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    assert(() {
      debugPrint('[Crashlytics] setCrashlyticsCollectionEnabled: $enabled');
      return true;
    }());
  }
}

/// Firebase Crashlytics implementation.
///
/// Disables collection in debug mode by default so development crashes
/// do not pollute production dashboards. All calls are logged to the
/// console via [debugPrint] in debug mode for easy verification.
class FirebaseCrashlyticsService implements CrashlyticsService {
  FirebaseCrashlyticsService() {
    _crashlytics = FirebaseCrashlytics.instance;

    if (kDebugMode) {
      _crashlytics.setCrashlyticsCollectionEnabled(false);
      debugPrint('[Crashlytics] Debug mode — collection disabled');
    }
  }

  late final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> logError(Object exception, StackTrace stackTrace) async {
    if (kDebugMode) {
      debugPrint('[Crashlytics] logError (fatal): $exception');
      return;
    }
    await _crashlytics.recordError(exception, stackTrace, fatal: true);
  }

  @override
  Future<void> recordError(Object exception, StackTrace stackTrace) async {
    if (kDebugMode) {
      debugPrint('[Crashlytics] recordError (non-fatal): $exception');
      return;
    }
    await _crashlytics.recordError(exception, stackTrace, fatal: false);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    if (kDebugMode) {
      debugPrint('[Crashlytics] setUserIdentifier: $identifier');
    }
    await _crashlytics.setUserIdentifier(identifier);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    if (kDebugMode) {
      debugPrint('[Crashlytics] setCustomKey: $key = $value');
    }
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (kDebugMode) {
      debugPrint('[Crashlytics] setCrashlyticsCollectionEnabled: $enabled');
    }
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }
}

@Riverpod(keepAlive: true)
CrashlyticsService crashlyticsService(CrashlyticsServiceRef ref) =>
    FirebaseCrashlyticsService();
