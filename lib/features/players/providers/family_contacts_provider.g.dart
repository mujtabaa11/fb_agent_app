// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyContactsNotifierHash() =>
    r'838570381862dcad81661d2f0e93f4ad7c87192d';

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

abstract class _$FamilyContactsNotifier
    extends BuildlessAutoDisposeNotifier<FamilyContactsState> {
  late final String playerId;

  FamilyContactsState build(
    String playerId,
  );
}

/// See also [FamilyContactsNotifier].
@ProviderFor(FamilyContactsNotifier)
const familyContactsNotifierProvider = FamilyContactsNotifierFamily();

/// See also [FamilyContactsNotifier].
class FamilyContactsNotifierFamily extends Family<FamilyContactsState> {
  /// See also [FamilyContactsNotifier].
  const FamilyContactsNotifierFamily();

  /// See also [FamilyContactsNotifier].
  FamilyContactsNotifierProvider call(
    String playerId,
  ) {
    return FamilyContactsNotifierProvider(
      playerId,
    );
  }

  @override
  FamilyContactsNotifierProvider getProviderOverride(
    covariant FamilyContactsNotifierProvider provider,
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
  String? get name => r'familyContactsNotifierProvider';
}

/// See also [FamilyContactsNotifier].
class FamilyContactsNotifierProvider extends AutoDisposeNotifierProviderImpl<
    FamilyContactsNotifier, FamilyContactsState> {
  /// See also [FamilyContactsNotifier].
  FamilyContactsNotifierProvider(
    String playerId,
  ) : this._internal(
          () => FamilyContactsNotifier()..playerId = playerId,
          from: familyContactsNotifierProvider,
          name: r'familyContactsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$familyContactsNotifierHash,
          dependencies: FamilyContactsNotifierFamily._dependencies,
          allTransitiveDependencies:
              FamilyContactsNotifierFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  FamilyContactsNotifierProvider._internal(
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
  FamilyContactsState runNotifierBuild(
    covariant FamilyContactsNotifier notifier,
  ) {
    return notifier.build(
      playerId,
    );
  }

  @override
  Override overrideWith(FamilyContactsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FamilyContactsNotifierProvider._internal(
        () => create()..playerId = playerId,
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
  AutoDisposeNotifierProviderElement<FamilyContactsNotifier,
      FamilyContactsState> createElement() {
    return _FamilyContactsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyContactsNotifierProvider &&
        other.playerId == playerId;
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
mixin FamilyContactsNotifierRef
    on AutoDisposeNotifierProviderRef<FamilyContactsState> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _FamilyContactsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<FamilyContactsNotifier,
        FamilyContactsState> with FamilyContactsNotifierRef {
  _FamilyContactsNotifierProviderElement(super.provider);

  @override
  String get playerId => (origin as FamilyContactsNotifierProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
