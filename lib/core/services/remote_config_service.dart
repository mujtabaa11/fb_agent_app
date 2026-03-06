/// Remote Config abstraction for fetching and reading feature flags and
/// remote parameters from Firebase Remote Config.
///
/// Ships with a [NoOpRemoteConfigService] stub for testing and a
/// [FirebaseRemoteConfigService] for production use.
library;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/remote_config_defaults.dart';

part 'remote_config_service.g.dart';

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

/// Contract for remote configuration and feature flags.
abstract class RemoteConfigService {
  /// Set defaults, configure fetch interval, and fetch + activate the
  /// latest config from Firebase.
  ///
  /// Call once during app bootstrap, after [Firebase.initializeApp].
  /// If the fetch fails (e.g. no internet), cached or default values
  /// are used — the app continues without error.
  Future<void> initialise();

  /// Return the [String] value for the given Remote Config [key].
  ///
  /// If the key does not exist, the registered default value is returned.
  String getString(String key);

  /// Return the [bool] value for the given Remote Config [key].
  ///
  /// If the key does not exist, the registered default value is returned.
  bool getBool(String key);

  /// Return the [int] value for the given Remote Config [key].
  ///
  /// If the key does not exist, the registered default value is returned.
  int getInt(String key);

  /// Return the [double] value for the given Remote Config [key].
  ///
  /// If the key does not exist, the registered default value is returned.
  double getDouble(String key);
}

// ---------------------------------------------------------------------------
// No-op stub (for testing)
// ---------------------------------------------------------------------------

/// A no-op implementation that only prints in debug mode.
class NoOpRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> initialise() async {
    assert(() {
      debugPrint('[RemoteConfig] initialise (no-op)');
      return true;
    }());
  }

  @override
  String getString(String key) {
    assert(() {
      debugPrint('[RemoteConfig] getString($key) (no-op)');
      return true;
    }());
    return '';
  }

  @override
  bool getBool(String key) {
    assert(() {
      debugPrint('[RemoteConfig] getBool($key) (no-op)');
      return true;
    }());
    return false;
  }

  @override
  int getInt(String key) {
    assert(() {
      debugPrint('[RemoteConfig] getInt($key) (no-op)');
      return true;
    }());
    return 0;
  }

  @override
  double getDouble(String key) {
    assert(() {
      debugPrint('[RemoteConfig] getDouble($key) (no-op)');
      return true;
    }());
    return 0.0;
  }
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

/// Firebase Remote Config implementation.
///
/// Handles:
/// - Setting default values from [RemoteConfigDefaults]
/// - Configuring fetch interval ([Duration.zero] in debug, 1 hour in
///   production to avoid Firebase throttling)
/// - Fetching and activating the latest config on app launch
/// - Typed getters for [String], [bool], [int], and [double] values
///
/// If [fetchAndActivate] fails (e.g. no internet), the last cached values
/// are used and the app continues without error.
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  late final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> initialise() async {
    // Set the fetch interval: zero in debug for instant updates during
    // development; minimum 1 hour in production to avoid Firebase throttling.
    final fetchInterval = kDebugMode
        ? Duration.zero
        : const Duration(hours: 1);

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: fetchInterval,
      ),
    );

    // Register default values so that every key has a fallback — even
    // when offline or before the first successful fetch.
    await _remoteConfig.setDefaults(RemoteConfigDefaults.defaults);

    // Fetch the latest config from Firebase and activate it. If this
    // fails (no internet, timeout, etc.), cached or default values are
    // used — the app continues without error.
    try {
      final activated = await _remoteConfig.fetchAndActivate();

      if (kDebugMode) {
        debugPrint('[RemoteConfig] fetchAndActivate completed — '
            'activated: $activated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RemoteConfig] fetchAndActivate failed — '
            'using cached/default values: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[RemoteConfig] Initialised with '
          'fetchInterval: $fetchInterval');
    }
  }

  @override
  String getString(String key) {
    final value = _remoteConfig.getString(key);

    if (kDebugMode) {
      debugPrint('[RemoteConfig] getString($key) → $value');
    }

    return value;
  }

  @override
  bool getBool(String key) {
    final value = _remoteConfig.getBool(key);

    if (kDebugMode) {
      debugPrint('[RemoteConfig] getBool($key) → $value');
    }

    return value;
  }

  @override
  int getInt(String key) {
    final value = _remoteConfig.getInt(key);

    if (kDebugMode) {
      debugPrint('[RemoteConfig] getInt($key) → $value');
    }

    return value;
  }

  @override
  double getDouble(String key) {
    final value = _remoteConfig.getDouble(key);

    if (kDebugMode) {
      debugPrint('[RemoteConfig] getDouble($key) → $value');
    }

    return value;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) =>
    FirebaseRemoteConfigService();
