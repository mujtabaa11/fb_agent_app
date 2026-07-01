// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadMessagesCountHash() =>
    r'53139a5cdcb33e5cff39b946bab8e7f5ef527111';

/// Count of unread messages across all conversations.
///
/// Placeholder — returns `0` until Phase 3 wires this to a Firestore
/// conversations query.
///
/// Copied from [unreadMessagesCount].
@ProviderFor(unreadMessagesCount)
final unreadMessagesCountProvider = AutoDisposeProvider<int>.internal(
  unreadMessagesCount,
  name: r'unreadMessagesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadMessagesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadMessagesCountRef = AutoDisposeProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
