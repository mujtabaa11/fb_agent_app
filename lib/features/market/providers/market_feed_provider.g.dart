// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketRepositoryHash() => r'941a7a90259f911f35747241a00523b7f720e4ce';

/// See also [marketRepository].
@ProviderFor(marketRepository)
final marketRepositoryProvider = Provider<MarketRepository>.internal(
  marketRepository,
  name: r'marketRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarketRepositoryRef = ProviderRef<MarketRepository>;
String _$marketFeedHash() => r'7df1b4cde1216166913dc1b5185c8d6665b26c21';

/// See also [marketFeed].
@ProviderFor(marketFeed)
final marketFeedProvider =
    AutoDisposeStreamProvider<List<MarketPostModel>>.internal(
  marketFeed,
  name: r'marketFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$marketFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarketFeedRef = AutoDisposeStreamProviderRef<List<MarketPostModel>>;
String _$marketPostAgentHash() => r'61f0634616bf869760ec2e42308e874e113a9c8a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [marketPostAgent].
@ProviderFor(marketPostAgent)
const marketPostAgentProvider = MarketPostAgentFamily();

/// See also [marketPostAgent].
class MarketPostAgentFamily extends Family<AsyncValue<UserModel?>> {
  /// See also [marketPostAgent].
  const MarketPostAgentFamily();

  /// See also [marketPostAgent].
  MarketPostAgentProvider call(
    String agentId,
  ) {
    return MarketPostAgentProvider(
      agentId,
    );
  }

  @override
  MarketPostAgentProvider getProviderOverride(
    covariant MarketPostAgentProvider provider,
  ) {
    return call(
      provider.agentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketPostAgentProvider';
}

/// See also [marketPostAgent].
class MarketPostAgentProvider extends AutoDisposeFutureProvider<UserModel?> {
  /// See also [marketPostAgent].
  MarketPostAgentProvider(
    String agentId,
  ) : this._internal(
          (ref) => marketPostAgent(
            ref as MarketPostAgentRef,
            agentId,
          ),
          from: marketPostAgentProvider,
          name: r'marketPostAgentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$marketPostAgentHash,
          dependencies: MarketPostAgentFamily._dependencies,
          allTransitiveDependencies:
              MarketPostAgentFamily._allTransitiveDependencies,
          agentId: agentId,
        );

  MarketPostAgentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.agentId,
  }) : super.internal();

  final String agentId;

  @override
  Override overrideWith(
    FutureOr<UserModel?> Function(MarketPostAgentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketPostAgentProvider._internal(
        (ref) => create(ref as MarketPostAgentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        agentId: agentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserModel?> createElement() {
    return _MarketPostAgentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketPostAgentProvider && other.agentId == agentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, agentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketPostAgentRef on AutoDisposeFutureProviderRef<UserModel?> {
  /// The parameter `agentId` of this provider.
  String get agentId;
}

class _MarketPostAgentProviderElement
    extends AutoDisposeFutureProviderElement<UserModel?>
    with MarketPostAgentRef {
  _MarketPostAgentProviderElement(super.provider);

  @override
  String get agentId => (origin as MarketPostAgentProvider).agentId;
}

String _$filteredMarketFeedHash() =>
    r'b21668e55edd03614839b12a659d2ca143f15648';

/// See also [filteredMarketFeed].
@ProviderFor(filteredMarketFeed)
final filteredMarketFeedProvider =
    AutoDisposeProvider<List<MarketPostModel>>.internal(
  filteredMarketFeed,
  name: r'filteredMarketFeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredMarketFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredMarketFeedRef = AutoDisposeProviderRef<List<MarketPostModel>>;
String _$marketFeedFilterHash() => r'6560890190e96b1b9a4f7d098256826816748f4c';

/// See also [MarketFeedFilter].
@ProviderFor(MarketFeedFilter)
final marketFeedFilterProvider = AutoDisposeNotifierProvider<MarketFeedFilter,
    MarketFeedFilterState>.internal(
  MarketFeedFilter.new,
  name: r'marketFeedFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$marketFeedFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MarketFeedFilter = AutoDisposeNotifier<MarketFeedFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
