library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../models/user_model.dart';
import 'auth_providers.dart';

part 'agent_providers.g.dart';

@riverpod
Stream<UserModel?> _agentStream(_AgentStreamRef ref) {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);

  final repo = ref.watch(userRepositoryProvider);
  return repo.watchStream(authUser.uid).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure() => null,
    };
  });
}

@riverpod
UserModel? currentAgent(CurrentAgentRef ref) {
  return ref.watch(_agentStreamProvider).valueOrNull;
}
