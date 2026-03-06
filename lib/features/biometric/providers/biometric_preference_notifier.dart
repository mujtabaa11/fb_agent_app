/// Manages the biometric lock preference with user-scoped secure storage.
///
/// Reads and writes the `biometric_enabled_{userId}` key in
/// [FlutterSecureStorage]. The enable flow requires the user to pass a
/// biometric verification check before the preference is persisted.
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/storage/storage_providers.dart';
import '../../auth/providers/auth_providers.dart';
import 'biometric_providers.dart';

part 'biometric_preference_notifier.g.dart';

/// Result of the [BiometricPreferenceNotifier.enable] operation.
enum BiometricEnableResult {
  /// Biometric is not available on this device.
  notAvailable,

  /// User cancelled or failed the verify-to-enable biometric check.
  verificationFailed,

  /// Biometric was successfully enabled and persisted.
  success,
}

/// Notifier that manages the biometric lock preference for the current user.
///
/// The preference is stored in [FlutterSecureStorage] under a user-scoped key
/// (`biometric_enabled_{userId}`) so that each user on a shared device has
/// their own setting. The preference survives sign-out (device-scoped).
@Riverpod(keepAlive: true)
class BiometricPreferenceNotifier extends _$BiometricPreferenceNotifier {
  @override
  Future<bool> build() async {
    // Use ref.watch so the notifier rebuilds when the auth state changes
    // (e.g. loading → authenticated, or sign-out). A one-shot ref.read would
    // miss auth state transitions and return null userId if the stream hasn't
    // emitted yet.
    final authState = ref.watch(authStateChangesProvider);
    final userId = authState.valueOrNull?.uid;
    if (userId == null) return false;

    final storage = ref.read(secureStorageProvider);
    final value =
        await storage.read(StorageKeys.biometricEnabledForUser(userId));
    return value == 'true';
  }

  /// Enables biometric lock after verifying biometric availability and
  /// authenticating the user.
  ///
  /// Returns a [BiometricEnableResult] indicating the outcome.
  Future<BiometricEnableResult> enable(String localizedReason) async {
    final userId = _currentUserId;
    if (userId == null) return BiometricEnableResult.notAvailable;

    final service = ref.read(biometricServiceProvider);

    final available = await service.isAvailable();
    if (!available) return BiometricEnableResult.notAvailable;

    final authenticated =
        await service.authenticate(localizedReason: localizedReason);
    if (!authenticated) return BiometricEnableResult.verificationFailed;

    final storage = ref.read(secureStorageProvider);
    await storage.write(
      StorageKeys.biometricEnabledForUser(userId),
      'true',
    );
    state = const AsyncData(true);
    return BiometricEnableResult.success;
  }

  /// Disables biometric lock immediately. No verification required.
  Future<void> disable() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final storage = ref.read(secureStorageProvider);
    await storage.delete(StorageKeys.biometricEnabledForUser(userId));
    state = const AsyncData(false);
  }

  /// Deletes the biometric preference for a specific user.
  ///
  /// Called during account deletion to clean up user-scoped data.
  Future<void> clearForUser(String userId) async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(StorageKeys.biometricEnabledForUser(userId));
    // If the cleared user is the current user, update state.
    if (userId == _currentUserId) {
      state = const AsyncData(false);
    }
  }

  /// Auto-clears the preference if biometrics are no longer available on the
  /// device (e.g. user removed all fingerprints/faces from device settings).
  ///
  /// Logs the event as a non-fatal to Crashlytics for debugging.
  Future<void> checkDeviceEnrollment() async {
    final isEnabled = state.valueOrNull ?? false;
    if (!isEnabled) return;

    final service = ref.read(biometricServiceProvider);
    final available = await service.isAvailable();
    if (!available) {
      if (kDebugMode) {
        debugPrint(
          'BiometricPreference: device biometrics no longer available, '
          'auto-clearing preference.',
        );
      }
      ref.read(crashlyticsServiceProvider).recordError(
            StateError(
              'Biometric preference auto-cleared: device biometrics '
              'no longer available.',
            ),
            StackTrace.current,
          );
      await disable();
    }
  }

  String? get _currentUserId {
    final authState = ref.read(authStateChangesProvider);
    return authState.valueOrNull?.uid;
  }
}
