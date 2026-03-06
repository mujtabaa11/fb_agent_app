// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_preference_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$biometricPreferenceNotifierHash() =>
    r'4db08e159d4b779971577a8f4304c6b6d24a557a';

/// Notifier that manages the biometric lock preference for the current user.
///
/// The preference is stored in [FlutterSecureStorage] under a user-scoped key
/// (`biometric_enabled_{userId}`) so that each user on a shared device has
/// their own setting. The preference survives sign-out (device-scoped).
///
/// Copied from [BiometricPreferenceNotifier].
@ProviderFor(BiometricPreferenceNotifier)
final biometricPreferenceNotifierProvider =
    AsyncNotifierProvider<BiometricPreferenceNotifier, bool>.internal(
  BiometricPreferenceNotifier.new,
  name: r'biometricPreferenceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricPreferenceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricPreferenceNotifier = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
