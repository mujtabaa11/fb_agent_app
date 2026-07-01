// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsNotifierHash() => r'69f2c6f34de7f2017ffb667ca2629783c3f894b1';

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

abstract class _$DocumentsNotifier
    extends BuildlessAutoDisposeNotifier<DocumentsState> {
  late final String playerId;

  DocumentsState build(
    String playerId,
  );
}

/// See also [DocumentsNotifier].
@ProviderFor(DocumentsNotifier)
const documentsNotifierProvider = DocumentsNotifierFamily();

/// See also [DocumentsNotifier].
class DocumentsNotifierFamily extends Family<DocumentsState> {
  /// See also [DocumentsNotifier].
  const DocumentsNotifierFamily();

  /// See also [DocumentsNotifier].
  DocumentsNotifierProvider call(
    String playerId,
  ) {
    return DocumentsNotifierProvider(
      playerId,
    );
  }

  @override
  DocumentsNotifierProvider getProviderOverride(
    covariant DocumentsNotifierProvider provider,
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
  String? get name => r'documentsNotifierProvider';
}

/// See also [DocumentsNotifier].
class DocumentsNotifierProvider
    extends AutoDisposeNotifierProviderImpl<DocumentsNotifier, DocumentsState> {
  /// See also [DocumentsNotifier].
  DocumentsNotifierProvider(
    String playerId,
  ) : this._internal(
          () => DocumentsNotifier()..playerId = playerId,
          from: documentsNotifierProvider,
          name: r'documentsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$documentsNotifierHash,
          dependencies: DocumentsNotifierFamily._dependencies,
          allTransitiveDependencies:
              DocumentsNotifierFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  DocumentsNotifierProvider._internal(
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
  DocumentsState runNotifierBuild(
    covariant DocumentsNotifier notifier,
  ) {
    return notifier.build(
      playerId,
    );
  }

  @override
  Override overrideWith(DocumentsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DocumentsNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<DocumentsNotifier, DocumentsState>
      createElement() {
    return _DocumentsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsNotifierProvider && other.playerId == playerId;
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
mixin DocumentsNotifierRef on AutoDisposeNotifierProviderRef<DocumentsState> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _DocumentsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<DocumentsNotifier,
        DocumentsState> with DocumentsNotifierRef {
  _DocumentsNotifierProviderElement(super.provider);

  @override
  String get playerId => (origin as DocumentsNotifierProvider).playerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
