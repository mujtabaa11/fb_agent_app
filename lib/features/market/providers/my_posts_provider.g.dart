// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_posts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myPostsHash() => r'2a8237dbd13e64332d4048225c2db02249a90a02';

/// See also [myPosts].
@ProviderFor(myPosts)
final myPostsProvider =
    AutoDisposeStreamProvider<List<MarketPostModel>>.internal(
  myPosts,
  name: r'myPostsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyPostsRef = AutoDisposeStreamProviderRef<List<MarketPostModel>>;
String _$myPostsActionsNotifierHash() =>
    r'dcaf109ab7946d5c51e807281fa644255aead2c5';

/// See also [MyPostsActionsNotifier].
@ProviderFor(MyPostsActionsNotifier)
final myPostsActionsNotifierProvider = AutoDisposeNotifierProvider<
    MyPostsActionsNotifier, MyPostsActionsState>.internal(
  MyPostsActionsNotifier.new,
  name: r'myPostsActionsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myPostsActionsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyPostsActionsNotifier = AutoDisposeNotifier<MyPostsActionsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
