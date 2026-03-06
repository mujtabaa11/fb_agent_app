/// Biometric authentication abstraction.
///
/// [BiometricService] defines the contract. [LocalAuthBiometricService] is the
/// production implementation backed by `local_auth`.
///
/// All `local_auth` imports are confined to the concrete implementation —
/// nothing outside this file imports `local_auth` directly.
library;

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Abstract contract for biometric authentication.
///
/// Consumers depend on this interface — never on the concrete implementation.
abstract class BiometricService {
  /// Whether biometric authentication is available on this device.
  ///
  /// Returns `true` only when the device both supports biometrics and has at
  /// least one enrolled biometric credential.
  Future<bool> isAvailable();

  /// Triggers the platform biometric prompt.
  ///
  /// Returns `true` on successful authentication, `false` on failure or
  /// cancellation. Never throws.
  Future<bool> authenticate({required String localizedReason});

  /// Triggers the platform biometric prompt with device credential fallback.
  ///
  /// Unlike [authenticate], this allows the user to fall back to device
  /// passcode/PIN/pattern when biometrics fail.
  Future<bool> authenticateWithPasscode({required String localizedReason});
}

/// Production implementation backed by `local_auth`.
class LocalAuthBiometricService implements BiometricService {
  LocalAuthBiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('BiometricService error [isAvailable]: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('BiometricService error [authenticate]: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticateWithPasscode({
    required String localizedReason,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('BiometricService error [authenticateWithPasscode]: $e');
      return false;
    }
  }
}
