// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editPlayerNotifierHash() =>
    r'5b8340cb7f227f807cb0394acf2e6b38f6b92d22';

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

abstract class _$EditPlayerNotifier
    extends BuildlessAutoDisposeNotifier<EditPlayerState> {
  late final String playerId;

  EditPlayerState build(
    String playerId,
  );
}

/// See also [EditPlayerNotifier].
@ProviderFor(EditPlayerNotifier)
const editPlayerNotifierProvider = EditPlayerNotifierFamily();

/// See also [EditPlayerNotifier].
class EditPlayerNotifierFamily extends Family<EditPlayerState> {
  /// See also [EditPlayerNotifier].
  const EditPlayerNotifierFamily();

  /// See also [EditPlayerNotifier].
  EditPlayerNotifierProvider call(
    String playerId,
  ) {
    return EditPlayerNotifierProvider(
      playerId,
    );
  }

  @override
  EditPlayerNotifierProvider getProviderOverride(
    covariant EditPlayerNotifierProvider provider,
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
  String? get name => r'editPlayerNotifierProvider';
}

/// See also [EditPlayerNotifier].
class EditPlayerNotifierProvider extends AutoDisposeNotifierProviderImpl<
    EditPlayerNotifier, EditPlayerState> {
  /// See also [EditPlayerNotifier].
  EditPlayerNotifierProvider(
    String playerId,
  ) : this._internal(
          () => EditPlayerNotifier()..playerId = playerId,
          from: editPlayerNotifierProvider,
          name: r'editPlayerNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editPlayerNotifierHash,
          dependencies: EditPlayerNotifierFamily._dependencies,
          allTransitiveDependencies:
              EditPlayerNotifierFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  EditPlayerNotifierProvider._internal(
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
  EditPlayerState runNotifierBuild(
    covariant EditPlayerNotifier notifier,
  ) {
    return notifier.build(
      playerId,
    );
  }

  @override
  Override overrideWith(EditPlayerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditPlayerNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<EditPlayerNotifier, EditPlayerState>
      createElement() {
    return _EditPlayerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditPlayerNotifierProvider && other.playerId == playerId;
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
mixin EditPlayerNotifierRef on AutoDisposeNotifierProviderRef<EditPlayerState> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _EditPlayerNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<EditPlayerNotifier,
        EditPlayerState> with EditPlayerNotifierRef {
  _EditPlayerNotifierProviderElement(super.provider);

  @override
  String get playerId => (origin as EditPlayerNotifierProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
