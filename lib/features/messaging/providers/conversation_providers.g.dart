// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationRepositoryHash() =>
    r'2e1cef8b37194024ad4acb5ecf6acf6a483aae5d';

/// See also [conversationRepository].
@ProviderFor(conversationRepository)
final conversationRepositoryProvider =
    Provider<ConversationRepository>.internal(
  conversationRepository,
  name: r'conversationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conversationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationRepositoryRef = ProviderRef<ConversationRepository>;
String _$messageAgentNotifierHash() =>
    r'053e36f0fd562f4e1cc557e6e817ac1b19c536c4';

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

abstract class _$MessageAgentNotifier
    extends BuildlessAutoDisposeNotifier<MessageAgentState> {
  late final String postId;

  MessageAgentState build(
    String postId,
  );
}

/// See also [MessageAgentNotifier].
@ProviderFor(MessageAgentNotifier)
const messageAgentNotifierProvider = MessageAgentNotifierFamily();

/// See also [MessageAgentNotifier].
class MessageAgentNotifierFamily extends Family<MessageAgentState> {
  /// See also [MessageAgentNotifier].
  const MessageAgentNotifierFamily();

  /// See also [MessageAgentNotifier].
  MessageAgentNotifierProvider call(
    String postId,
  ) {
    return MessageAgentNotifierProvider(
      postId,
    );
  }

  @override
  MessageAgentNotifierProvider getProviderOverride(
    covariant MessageAgentNotifierProvider provider,
  ) {
    return call(
      provider.postId,
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
  String? get name => r'messageAgentNotifierProvider';
}

/// See also [MessageAgentNotifier].
class MessageAgentNotifierProvider extends AutoDisposeNotifierProviderImpl<
    MessageAgentNotifier, MessageAgentState> {
  /// See also [MessageAgentNotifier].
  MessageAgentNotifierProvider(
    String postId,
  ) : this._internal(
          () => MessageAgentNotifier()..postId = postId,
          from: messageAgentNotifierProvider,
          name: r'messageAgentNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageAgentNotifierHash,
          dependencies: MessageAgentNotifierFamily._dependencies,
          allTransitiveDependencies:
              MessageAgentNotifierFamily._allTransitiveDependencies,
          postId: postId,
        );

  MessageAgentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  MessageAgentState runNotifierBuild(
    covariant MessageAgentNotifier notifier,
  ) {
    return notifier.build(
      postId,
    );
  }

  @override
  Override overrideWith(MessageAgentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageAgentNotifierProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MessageAgentNotifier, MessageAgentState>
      createElement() {
    return _MessageAgentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAgentNotifierProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageAgentNotifierRef
    on AutoDisposeNotifierProviderRef<MessageAgentState> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _MessageAgentNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<MessageAgentNotifier,
        MessageAgentState> with MessageAgentNotifierRef {
  _MessageAgentNotifierProviderElement(super.provider);

  @override
  String get postId => (origin as MessageAgentNotifierProvider).postId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
