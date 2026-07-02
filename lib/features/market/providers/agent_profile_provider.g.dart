// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agentProfileHash() => r'f73a2a625b0e19b0fc034503465cbda7c16d8b51';

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

/// Streams the public profile of [agentId]. Emits `null` if the agent
/// document does not exist.
///
/// Copied from [agentProfile].
@ProviderFor(agentProfile)
const agentProfileProvider = AgentProfileFamily();

/// Streams the public profile of [agentId]. Emits `null` if the agent
/// document does not exist.
///
/// Copied from [agentProfile].
class AgentProfileFamily extends Family<AsyncValue<UserModel?>> {
  /// Streams the public profile of [agentId]. Emits `null` if the agent
  /// document does not exist.
  ///
  /// Copied from [agentProfile].
  const AgentProfileFamily();

  /// Streams the public profile of [agentId]. Emits `null` if the agent
  /// document does not exist.
  ///
  /// Copied from [agentProfile].
  AgentProfileProvider call(
    String agentId,
  ) {
    return AgentProfileProvider(
      agentId,
    );
  }

  @override
  AgentProfileProvider getProviderOverride(
    covariant AgentProfileProvider provider,
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
  String? get name => r'agentProfileProvider';
}

/// Streams the public profile of [agentId]. Emits `null` if the agent
/// document does not exist.
///
/// Copied from [agentProfile].
class AgentProfileProvider extends AutoDisposeStreamProvider<UserModel?> {
  /// Streams the public profile of [agentId]. Emits `null` if the agent
  /// document does not exist.
  ///
  /// Copied from [agentProfile].
  AgentProfileProvider(
    String agentId,
  ) : this._internal(
          (ref) => agentProfile(
            ref as AgentProfileRef,
            agentId,
          ),
          from: agentProfileProvider,
          name: r'agentProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$agentProfileHash,
          dependencies: AgentProfileFamily._dependencies,
          allTransitiveDependencies:
              AgentProfileFamily._allTransitiveDependencies,
          agentId: agentId,
        );

  AgentProfileProvider._internal(
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
    Stream<UserModel?> Function(AgentProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AgentProfileProvider._internal(
        (ref) => create(ref as AgentProfileRef),
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
  AutoDisposeStreamProviderElement<UserModel?> createElement() {
    return _AgentProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentProfileProvider && other.agentId == agentId;
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
mixin AgentProfileRef on AutoDisposeStreamProviderRef<UserModel?> {
  /// The parameter `agentId` of this provider.
  String get agentId;
}

class _AgentProfileProviderElement
    extends AutoDisposeStreamProviderElement<UserModel?> with AgentProfileRef {
  _AgentProfileProviderElement(super.provider);

  @override
  String get agentId => (origin as AgentProfileProvider).agentId;
}

String _$agentActivePostsHash() => r'93e1a2fcffcae543e63322a4f544b593418281db';

/// Streams [agentId]'s active Market posts, excluding expired ones.
///
/// Copied from [agentActivePosts].
@ProviderFor(agentActivePosts)
const agentActivePostsProvider = AgentActivePostsFamily();

/// Streams [agentId]'s active Market posts, excluding expired ones.
///
/// Copied from [agentActivePosts].
class AgentActivePostsFamily extends Family<AsyncValue<List<MarketPostModel>>> {
  /// Streams [agentId]'s active Market posts, excluding expired ones.
  ///
  /// Copied from [agentActivePosts].
  const AgentActivePostsFamily();

  /// Streams [agentId]'s active Market posts, excluding expired ones.
  ///
  /// Copied from [agentActivePosts].
  AgentActivePostsProvider call(
    String agentId,
  ) {
    return AgentActivePostsProvider(
      agentId,
    );
  }

  @override
  AgentActivePostsProvider getProviderOverride(
    covariant AgentActivePostsProvider provider,
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
  String? get name => r'agentActivePostsProvider';
}

/// Streams [agentId]'s active Market posts, excluding expired ones.
///
/// Copied from [agentActivePosts].
class AgentActivePostsProvider
    extends AutoDisposeStreamProvider<List<MarketPostModel>> {
  /// Streams [agentId]'s active Market posts, excluding expired ones.
  ///
  /// Copied from [agentActivePosts].
  AgentActivePostsProvider(
    String agentId,
  ) : this._internal(
          (ref) => agentActivePosts(
            ref as AgentActivePostsRef,
            agentId,
          ),
          from: agentActivePostsProvider,
          name: r'agentActivePostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$agentActivePostsHash,
          dependencies: AgentActivePostsFamily._dependencies,
          allTransitiveDependencies:
              AgentActivePostsFamily._allTransitiveDependencies,
          agentId: agentId,
        );

  AgentActivePostsProvider._internal(
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
    Stream<List<MarketPostModel>> Function(AgentActivePostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AgentActivePostsProvider._internal(
        (ref) => create(ref as AgentActivePostsRef),
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
  AutoDisposeStreamProviderElement<List<MarketPostModel>> createElement() {
    return _AgentActivePostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentActivePostsProvider && other.agentId == agentId;
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
mixin AgentActivePostsRef
    on AutoDisposeStreamProviderRef<List<MarketPostModel>> {
  /// The parameter `agentId` of this provider.
  String get agentId;
}

class _AgentActivePostsProviderElement
    extends AutoDisposeStreamProviderElement<List<MarketPostModel>>
    with AgentActivePostsRef {
  _AgentActivePostsProviderElement(super.provider);

  @override
  String get agentId => (origin as AgentActivePostsProvider).agentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
