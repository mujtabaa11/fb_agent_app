/// Riverpod providers for the current agent's Firestore profile.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'agent_providers.g.dart';

/// The current agent's Firestore profile.
///
/// Placeholder — returns `null` until Phase 0 account setup wires this to
/// the `users` collection. The route guard treats `null` as an incomplete
/// profile and redirects to `/setup`.
@riverpod
UserModel? currentAgent(CurrentAgentRef ref) {
  return null;
}
