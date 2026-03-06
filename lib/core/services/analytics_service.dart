/// Analytics abstraction for error logging, event tracking, and screen views.
///
/// Ships with a [NoOpAnalyticsService] stub for testing and a
/// [FirebaseAnalyticsService] for production use.
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Contract for analytics and error reporting.
abstract class AnalyticsService {
  /// Log an error with its associated stack trace.
  void logError(Object error, StackTrace stackTrace);

  /// Log a named event with optional parameters.
  void logEvent(String name, {Map<String, dynamic>? parameters});

  /// Log a screen view with the given [screenName].
  Future<void> logScreenView(String screenName);

  /// Enable or disable analytics collection (e.g. for GDPR opt-out).
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Set the current user ID for analytics. Pass `null` to clear.
  Future<void> setUserId(String? userId);

  /// A [NavigatorObserver] for automatic screen tracking via GoRouter.
  NavigatorObserver get navigatorObserver;
}

/// A no-op implementation that only prints in debug mode.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  void logError(Object error, StackTrace stackTrace) {
    assert(() {
      debugPrint('[Analytics] logError: $error');
      debugPrint('[Analytics] stackTrace: $stackTrace');
      return true;
    }());
  }

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    assert(() {
      debugPrint('[Analytics] logEvent: $name, parameters: $parameters');
      return true;
    }());
  }

  @override
  Future<void> logScreenView(String screenName) async {
    assert(() {
      debugPrint('[Analytics] logScreenView: $screenName');
      return true;
    }());
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    assert(() {
      debugPrint('[Analytics] setAnalyticsCollectionEnabled: $enabled');
      return true;
    }());
  }

  @override
  Future<void> setUserId(String? userId) async {
    assert(() {
      debugPrint('[Analytics] setUserId: $userId');
      return true;
    }());
  }

  @override
  NavigatorObserver get navigatorObserver => NavigatorObserver();
}

/// Firebase Analytics implementation.
///
/// Disables collection in debug mode by default so development traffic
/// does not pollute production dashboards. All calls are logged to the
/// console via [debugPrint] in debug mode for easy verification.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);

    if (kDebugMode) {
      _analytics.setAnalyticsCollectionEnabled(false);
      debugPrint('[Analytics] Debug mode — collection disabled');
    }
  }

  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  @override
  void logError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[Analytics] logError: $error');
      return;
    }
    _analytics.logEvent(
      name: 'app_error',
      parameters: {'error': error.toString()},
    );
  }

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      debugPrint('[Analytics] logEvent: $name, parameters: $parameters');
      return;
    }
    _analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('[Analytics] logScreenView: $screenName');
      return;
    }
    await _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (kDebugMode) {
      debugPrint('[Analytics] setAnalyticsCollectionEnabled: $enabled');
    }
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] setUserId: $userId');
    }
    await _analytics.setUserId(id: userId);
  }

  @override
  NavigatorObserver get navigatorObserver => _observer;
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(AnalyticsServiceRef ref) =>
    FirebaseAnalyticsService();
