// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerProfileHash() => r'ae8f5524141f32a759ad39a88e6668d19ae2078f';

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

/// See also [playerProfile].
@ProviderFor(playerProfile)
const playerProfileProvider = PlayerProfileFamily();

/// See also [playerProfile].
class PlayerProfileFamily extends Family<AsyncValue<PlayerModel?>> {
  /// See also [playerProfile].
  const PlayerProfileFamily();

  /// See also [playerProfile].
  PlayerProfileProvider call(
    String playerId,
  ) {
    return PlayerProfileProvider(
      playerId,
    );
  }

  @override
  PlayerProfileProvider getProviderOverride(
    covariant PlayerProfileProvider provider,
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
  String? get name => r'playerProfileProvider';
}

/// See also [playerProfile].
class PlayerProfileProvider extends AutoDisposeStreamProvider<PlayerModel?> {
  /// See also [playerProfile].
  PlayerProfileProvider(
    String playerId,
  ) : this._internal(
          (ref) => playerProfile(
            ref as PlayerProfileRef,
            playerId,
          ),
          from: playerProfileProvider,
          name: r'playerProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playerProfileHash,
          dependencies: PlayerProfileFamily._dependencies,
          allTransitiveDependencies:
              PlayerProfileFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PlayerProfileProvider._internal(
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
    Stream<PlayerModel?> Function(PlayerProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerProfileProvider._internal(
        (ref) => create(ref as PlayerProfileRef),
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
  AutoDisposeStreamProviderElement<PlayerModel?> createElement() {
    return _PlayerProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerProfileProvider && other.playerId == playerId;
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
mixin PlayerProfileRef on AutoDisposeStreamProviderRef<PlayerModel?> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerProfileProviderElement
    extends AutoDisposeStreamProviderElement<PlayerModel?>
    with PlayerProfileRef {
  _PlayerProfileProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerProfileProvider).playerId;
}

String _$familyContactsHash() => r'8d91f89e5f76c8f03bfa2f190a3fc8692a2d7cab';

/// See also [familyContacts].
@ProviderFor(familyContacts)
const familyContactsProvider = FamilyContactsFamily();

/// See also [familyContacts].
class FamilyContactsFamily
    extends Family<AsyncValue<List<FamilyContactModel>>> {
  /// See also [familyContacts].
  const FamilyContactsFamily();

  /// See also [familyContacts].
  FamilyContactsProvider call(
    String playerId,
  ) {
    return FamilyContactsProvider(
      playerId,
    );
  }

  @override
  FamilyContactsProvider getProviderOverride(
    covariant FamilyContactsProvider provider,
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
  String? get name => r'familyContactsProvider';
}

/// See also [familyContacts].
class FamilyContactsProvider
    extends AutoDisposeStreamProvider<List<FamilyContactModel>> {
  /// See also [familyContacts].
  FamilyContactsProvider(
    String playerId,
  ) : this._internal(
          (ref) => familyContacts(
            ref as FamilyContactsRef,
            playerId,
          ),
          from: familyContactsProvider,
          name: r'familyContactsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$familyContactsHash,
          dependencies: FamilyContactsFamily._dependencies,
          allTransitiveDependencies:
              FamilyContactsFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  FamilyContactsProvider._internal(
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
    Stream<List<FamilyContactModel>> Function(FamilyContactsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FamilyContactsProvider._internal(
        (ref) => create(ref as FamilyContactsRef),
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
  AutoDisposeStreamProviderElement<List<FamilyContactModel>> createElement() {
    return _FamilyContactsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyContactsProvider && other.playerId == playerId;
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
mixin FamilyContactsRef
    on AutoDisposeStreamProviderRef<List<FamilyContactModel>> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _FamilyContactsProviderElement
    extends AutoDisposeStreamProviderElement<List<FamilyContactModel>>
    with FamilyContactsRef {
  _FamilyContactsProviderElement(super.provider);

  @override
  String get playerId => (origin as FamilyContactsProvider).playerId;
}

String _$playerDocumentsHash() => r'459d063a485aa4aa532bcf80347625f4964f3bbe';

/// See also [playerDocuments].
@ProviderFor(playerDocuments)
const playerDocumentsProvider = PlayerDocumentsFamily();

/// See also [playerDocuments].
class PlayerDocumentsFamily
    extends Family<AsyncValue<List<PlayerDocumentModel>>> {
  /// See also [playerDocuments].
  const PlayerDocumentsFamily();

  /// See also [playerDocuments].
  PlayerDocumentsProvider call(
    String playerId,
  ) {
    return PlayerDocumentsProvider(
      playerId,
    );
  }

  @override
  PlayerDocumentsProvider getProviderOverride(
    covariant PlayerDocumentsProvider provider,
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
  String? get name => r'playerDocumentsProvider';
}

/// See also [playerDocuments].
class PlayerDocumentsProvider
    extends AutoDisposeStreamProvider<List<PlayerDocumentModel>> {
  /// See also [playerDocuments].
  PlayerDocumentsProvider(
    String playerId,
  ) : this._internal(
          (ref) => playerDocuments(
            ref as PlayerDocumentsRef,
            playerId,
          ),
          from: playerDocumentsProvider,
          name: r'playerDocumentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playerDocumentsHash,
          dependencies: PlayerDocumentsFamily._dependencies,
          allTransitiveDependencies:
              PlayerDocumentsFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PlayerDocumentsProvider._internal(
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
    Stream<List<PlayerDocumentModel>> Function(PlayerDocumentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerDocumentsProvider._internal(
        (ref) => create(ref as PlayerDocumentsRef),
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
  AutoDisposeStreamProviderElement<List<PlayerDocumentModel>> createElement() {
    return _PlayerDocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerDocumentsProvider && other.playerId == playerId;
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
mixin PlayerDocumentsRef
    on AutoDisposeStreamProviderRef<List<PlayerDocumentModel>> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerDocumentsProviderElement
    extends AutoDisposeStreamProviderElement<List<PlayerDocumentModel>>
    with PlayerDocumentsRef {
  _PlayerDocumentsProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerDocumentsProvider).playerId;
}

String _$playerNotesHash() => r'959757ed16a34e357347c69449241756ac108b54';

/// See also [playerNotes].
@ProviderFor(playerNotes)
const playerNotesProvider = PlayerNotesFamily();

/// See also [playerNotes].
class PlayerNotesFamily extends Family<AsyncValue<List<PlayerNoteModel>>> {
  /// See also [playerNotes].
  const PlayerNotesFamily();

  /// See also [playerNotes].
  PlayerNotesProvider call(
    String playerId,
  ) {
    return PlayerNotesProvider(
      playerId,
    );
  }

  @override
  PlayerNotesProvider getProviderOverride(
    covariant PlayerNotesProvider provider,
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
  String? get name => r'playerNotesProvider';
}

/// See also [playerNotes].
class PlayerNotesProvider
    extends AutoDisposeStreamProvider<List<PlayerNoteModel>> {
  /// See also [playerNotes].
  PlayerNotesProvider(
    String playerId,
  ) : this._internal(
          (ref) => playerNotes(
            ref as PlayerNotesRef,
            playerId,
          ),
          from: playerNotesProvider,
          name: r'playerNotesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playerNotesHash,
          dependencies: PlayerNotesFamily._dependencies,
          allTransitiveDependencies:
              PlayerNotesFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PlayerNotesProvider._internal(
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
    Stream<List<PlayerNoteModel>> Function(PlayerNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerNotesProvider._internal(
        (ref) => create(ref as PlayerNotesRef),
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
  AutoDisposeStreamProviderElement<List<PlayerNoteModel>> createElement() {
    return _PlayerNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerNotesProvider && other.playerId == playerId;
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
mixin PlayerNotesRef on AutoDisposeStreamProviderRef<List<PlayerNoteModel>> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerNotesProviderElement
    extends AutoDisposeStreamProviderElement<List<PlayerNoteModel>>
    with PlayerNotesRef {
  _PlayerNotesProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerNotesProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
