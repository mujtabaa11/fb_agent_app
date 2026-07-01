library;

import '../../../core/data/result.dart';
import '../models/player_model.dart';

abstract class PlayerRepository {
  Future<Result<PlayerModel>> addPlayer(PlayerModel player);
  Future<Result<PlayerModel>> getPlayer(String playerId);
  Future<Result<PlayerModel>> updatePlayer(PlayerModel player);
  Future<Result<void>> deletePlayer(String playerId);
  Stream<Result<List<PlayerModel>>> watchPlayersByAgent(String agentId);
}
