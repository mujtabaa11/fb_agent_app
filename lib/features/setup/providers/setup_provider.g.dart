// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$setupRepositoryHash() => r'6c4b461d957d559b867c6e290856bcc9976cf5d0';

/// See also [setupRepository].
@ProviderFor(setupRepository)
final setupRepositoryProvider = Provider<SetupRepository>.internal(
  setupRepository,
  name: r'setupRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$setupRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SetupRepositoryRef = ProviderRef<SetupRepository>;
String _$accountSetupNotifierHash() =>
    r'1010af1db5d987dddf01e8d0c693c8c231cda07a';

/// See also [AccountSetupNotifier].
@ProviderFor(AccountSetupNotifier)
final accountSetupNotifierProvider = AutoDisposeNotifierProvider<
    AccountSetupNotifier, AccountSetupState>.internal(
  AccountSetupNotifier.new,
  name: r'accountSetupNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountSetupNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountSetupNotifier = AutoDisposeNotifier<AccountSetupState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
