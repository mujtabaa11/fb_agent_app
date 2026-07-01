library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../auth/providers/agent_providers.dart';
import '../models/player_model.dart';
import '../repositories/player_repository.dart';
import '../repositories/player_repository_impl.dart';

part 'player_providers.g.dart';

@Riverpod(keepAlive: true)
PlayerRepository playerRepository(PlayerRepositoryRef ref) {
  return PlayerRepositoryImpl();
}

@riverpod
Stream<List<PlayerModel>> agentPlayers(AgentPlayersRef ref) {
  final agent = ref.watch(currentAgentProvider);
  if (agent == null) return Stream.value([]);

  final repo = ref.watch(playerRepositoryProvider);
  return repo.watchPlayersByAgent(agent.id).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

@riverpod
Future<PlayerModel> playerDetail(PlayerDetailRef ref, String playerId) async {
  final repo = ref.watch(playerRepositoryProvider);
  final result = await repo.getPlayer(playerId);
  return switch (result) {
    Success(:final value) => value,
    Failure(:final exception) => throw exception,
  };
}
