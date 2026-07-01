// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerRepositoryHash() => r'652eb7b28db7c375dd51b2a71b3f3245b47752d2';

/// See also [playerRepository].
@ProviderFor(playerRepository)
final playerRepositoryProvider = Provider<PlayerRepository>.internal(
  playerRepository,
  name: r'playerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerRepositoryRef = ProviderRef<PlayerRepository>;
String _$agentPlayersHash() => r'564f65219ab0aae787802cde88ae8ce5b65ad2be';

/// See also [agentPlayers].
@ProviderFor(agentPlayers)
final agentPlayersProvider =
    AutoDisposeStreamProvider<List<PlayerModel>>.internal(
  agentPlayers,
  name: r'agentPlayersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$agentPlayersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgentPlayersRef = AutoDisposeStreamProviderRef<List<PlayerModel>>;
String _$playerDetailHash() => r'e5d9f4bc138aad5a56fc0ad7e83109af667e7878';

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

/// See also [playerDetail].
@ProviderFor(playerDetail)
const playerDetailProvider = PlayerDetailFamily();

/// See also [playerDetail].
class PlayerDetailFamily extends Family<AsyncValue<PlayerModel>> {
  /// See also [playerDetail].
  const PlayerDetailFamily();

  /// See also [playerDetail].
  PlayerDetailProvider call(
    String playerId,
  ) {
    return PlayerDetailProvider(
      playerId,
    );
  }

  @override
  PlayerDetailProvider getProviderOverride(
    covariant PlayerDetailProvider provider,
  ) {
    return call(
      provider.playerId,
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
  String? get name => r'playerDetailProvider';
}

/// See also [playerDetail].
class PlayerDetailProvider extends AutoDisposeFutureProvider<PlayerModel> {
  /// See also [playerDetail].
  PlayerDetailProvider(
    String playerId,
  ) : this._internal(
          (ref) => playerDetail(
            ref as PlayerDetailRef,
            playerId,
          ),
          from: playerDetailProvider,
          name: r'playerDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playerDetailHash,
          dependencies: PlayerDetailFamily._dependencies,
          allTransitiveDependencies:
              PlayerDetailFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PlayerDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final String playerId;

  @override
  Override overrideWith(
    FutureOr<PlayerModel> Function(PlayerDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerDetailProvider._internal(
        (ref) => create(ref as PlayerDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PlayerModel> createElement() {
    return _PlayerDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerDetailProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayerDetailRef on AutoDisposeFutureProviderRef<PlayerModel> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerDetailProviderElement
    extends AutoDisposeFutureProviderElement<PlayerModel> with PlayerDetailRef {
  _PlayerDetailProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerDetailProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
