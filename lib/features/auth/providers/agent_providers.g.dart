// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentAgentHash() => r'd198ca008ecd2f798bad93101a0bff058b401d54';

/// The current agent's Firestore profile.
///
/// Placeholder — returns `null` until Phase 0 account setup wires this to
/// the `users` collection. The route guard treats `null` as an incomplete
/// profile and redirects to `/setup`.
///
/// Copied from [currentAgent].
@ProviderFor(currentAgent)
final currentAgentProvider = AutoDisposeProvider<UserModel?>.internal(
  currentAgent,
  name: r'currentAgentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentAgentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAgentRef = AutoDisposeProviderRef<UserModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
