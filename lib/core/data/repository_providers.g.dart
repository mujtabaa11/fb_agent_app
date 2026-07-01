// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileRepositoryHash() =>
    r'a22ca5f0388dfde910e759bc9eb81a5091083277';

/// Provides a [BaseRepository] for [UserProfileModel] documents
/// stored in the `users` Firestore collection.
///
/// Copied from [userProfileRepository].
@ProviderFor(userProfileRepository)
final userProfileRepositoryProvider =
    Provider<BaseRepository<UserProfileModel>>.internal(
  userProfileRepository,
  name: r'userProfileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userProfileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRepositoryRef
    = ProviderRef<BaseRepository<UserProfileModel>>;
String _$userRepositoryHash() => r'2633985184ef41f7c590acd16f0c28c53e7e6efe';

/// Provides a [BaseRepository] for [UserModel] documents
/// stored in the `users` Firestore collection.
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = Provider<BaseRepository<UserModel>>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = ProviderRef<BaseRepository<UserModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
