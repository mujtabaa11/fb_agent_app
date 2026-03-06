// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStorageHash() => r'06f6b119a94d633b0d83c48ad2768ac061fcc54a';

/// See also [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<StorageService>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<StorageService>;
String _$prefsStorageHash() => r'646ae0b145e3852a9f7190e616d736c5ef9738a7';

/// See also [prefsStorage].
@ProviderFor(prefsStorage)
final prefsStorageProvider = Provider<StorageService>.internal(
  prefsStorage,
  name: r'prefsStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$prefsStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrefsStorageRef = ProviderRef<StorageService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
