// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$phoneVerificationHash() => r'950bb7ece1f8d2c480798562fc9e9c8106523978';

/// Manages phone number verification state (sending SMS).
///
/// Copied from [PhoneVerification].
@ProviderFor(PhoneVerification)
final phoneVerificationProvider =
    AutoDisposeAsyncNotifierProvider<PhoneVerification, String?>.internal(
  PhoneVerification.new,
  name: r'phoneVerificationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$phoneVerificationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhoneVerification = AutoDisposeAsyncNotifier<String?>;
String _$phoneSignInHash() => r'afaed5eb7829045ac4223758ac98bf7e82af77c7';

/// Manages OTP sign-in state (verifying the SMS code).
///
/// Copied from [PhoneSignIn].
@ProviderFor(PhoneSignIn)
final phoneSignInProvider =
    AutoDisposeAsyncNotifierProvider<PhoneSignIn, AuthUser?>.internal(
  PhoneSignIn.new,
  name: r'phoneSignInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$phoneSignInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhoneSignIn = AutoDisposeAsyncNotifier<AuthUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
