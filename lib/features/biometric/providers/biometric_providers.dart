/// Riverpod providers for biometric authentication.
///
/// [biometricServiceProvider] exposes the abstract [BiometricService] for
/// testability. The biometric preference is managed by
/// [BiometricPreferenceNotifier] in `biometric_preference_notifier.dart`.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/biometric_service.dart';

part 'biometric_providers.g.dart';

/// Provides the [BiometricService] singleton.
///
/// Registered as the abstract interface so tests can override with a fake.
@Riverpod(keepAlive: true)
BiometricService biometricService(BiometricServiceRef ref) {
  return LocalAuthBiometricService();
}
