// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contractExpiryAlertsHash() =>
    r'e15676514fc9a4adff7de112a5f0e6f690629254';

/// See also [contractExpiryAlerts].
@ProviderFor(contractExpiryAlerts)
final contractExpiryAlertsProvider =
    AutoDisposeFutureProvider<List<ContractExpiryAlert>>.internal(
  contractExpiryAlerts,
  name: r'contractExpiryAlertsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contractExpiryAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContractExpiryAlertsRef
    = AutoDisposeFutureProviderRef<List<ContractExpiryAlert>>;
String _$playerStatsHash() => r'3ff031d496dbaeaa3290c6e038ead7ec08a4c76a';

/// See also [playerStats].
@ProviderFor(playerStats)
final playerStatsProvider = AutoDisposeFutureProvider<PlayerStats>.internal(
  playerStats,
  name: r'playerStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$playerStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerStatsRef = AutoDisposeFutureProviderRef<PlayerStats>;
String _$dashboardActivePostsHash() =>
    r'6700d091dc5937ed5f230f80f4bfd4d68ef2382f';

/// The agent's active (non-expired, non-closed) Market posts, sorted by
/// soonest expiry first. Capped to the top 3 for the Dashboard section;
/// [dashboardActivePostsCount] reports the full count separately.
///
/// Copied from [dashboardActivePosts].
@ProviderFor(dashboardActivePosts)
final dashboardActivePostsProvider =
    AutoDisposeFutureProvider<List<MarketPostModel>>.internal(
  dashboardActivePosts,
  name: r'dashboardActivePostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardActivePostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardActivePostsRef
    = AutoDisposeFutureProviderRef<List<MarketPostModel>>;
String _$dashboardActivePostsCountHash() =>
    r'a60c9d76c7ff448c697b1a3f1145af2c2d180e70';

/// See also [dashboardActivePostsCount].
@ProviderFor(dashboardActivePostsCount)
final dashboardActivePostsCountProvider =
    AutoDisposeFutureProvider<int>.internal(
  dashboardActivePostsCount,
  name: r'dashboardActivePostsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardActivePostsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardActivePostsCountRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
