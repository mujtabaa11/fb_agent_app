// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesNotifierHash() => r'b33e29822869817eb00da627dc88e88177df746a';

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

abstract class _$NotesNotifier
    extends BuildlessAutoDisposeNotifier<NotesState> {
  late final String playerId;

  NotesState build(
    String playerId,
  );
}

/// See also [NotesNotifier].
@ProviderFor(NotesNotifier)
const notesNotifierProvider = NotesNotifierFamily();

/// See also [NotesNotifier].
class NotesNotifierFamily extends Family<NotesState> {
  /// See also [NotesNotifier].
  const NotesNotifierFamily();

  /// See also [NotesNotifier].
  NotesNotifierProvider call(
    String playerId,
  ) {
    return NotesNotifierProvider(
      playerId,
    );
  }

  @override
  NotesNotifierProvider getProviderOverride(
    covariant NotesNotifierProvider provider,
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
  String? get name => r'notesNotifierProvider';
}

/// See also [NotesNotifier].
class NotesNotifierProvider
    extends AutoDisposeNotifierProviderImpl<NotesNotifier, NotesState> {
  /// See also [NotesNotifier].
  NotesNotifierProvider(
    String playerId,
  ) : this._internal(
          () => NotesNotifier()..playerId = playerId,
          from: notesNotifierProvider,
          name: r'notesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notesNotifierHash,
          dependencies: NotesNotifierFamily._dependencies,
          allTransitiveDependencies:
              NotesNotifierFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  NotesNotifierProvider._internal(
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
  NotesState runNotifierBuild(
    covariant NotesNotifier notifier,
  ) {
    return notifier.build(
      playerId,
    );
  }

  @override
  Override overrideWith(NotesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: NotesNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<NotesNotifier, NotesState>
      createElement() {
    return _NotesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesNotifierProvider && other.playerId == playerId;
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
mixin NotesNotifierRef on AutoDisposeNotifierProviderRef<NotesState> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _NotesNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<NotesNotifier, NotesState>
    with NotesNotifierRef {
  _NotesNotifierProviderElement(super.provider);

  @override
  String get playerId => (origin as NotesNotifierProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
