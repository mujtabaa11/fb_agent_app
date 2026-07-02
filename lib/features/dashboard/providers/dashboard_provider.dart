library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../market/models/market_post_enums.dart';
import '../../market/models/market_post_model.dart';
import '../../market/providers/my_posts_provider.dart';
import '../../players/models/player_enums.dart';
import '../../players/providers/player_providers.dart';

part 'dashboard_provider.g.dart';

enum ContractType {
  representationAgreement,
  clubContract,
}

enum ExpiryUrgency {
  critical,
  warning,
  safe,
}

class ContractExpiryAlert {
  const ContractExpiryAlert({
    required this.playerId,
    required this.playerName,
    required this.contractType,
    required this.expiryDate,
    required this.daysRemaining,
    required this.urgency,
  });

  final String playerId;
  final String playerName;
  final ContractType contractType;
  final DateTime expiryDate;
  final int daysRemaining;
  final ExpiryUrgency urgency;
}

class PlayerStats {
  const PlayerStats({
    required this.totalPlayers,
    required this.activeClients,
    required this.prospects,
  });

  final int totalPlayers;
  final int activeClients;
  final int prospects;
}

ExpiryUrgency _urgencyForDaysRemaining(int daysRemaining) {
  if (daysRemaining <= 30) return ExpiryUrgency.critical;
  if (daysRemaining <= 60) return ExpiryUrgency.warning;
  return ExpiryUrgency.safe;
}

@riverpod
Future<List<ContractExpiryAlert>> contractExpiryAlerts(
    ContractExpiryAlertsRef ref) async {
  final players = await ref.watch(agentPlayersProvider.future);

  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final cutoff = today.add(const Duration(days: 90));

  final alerts = <ContractExpiryAlert>[];

  for (final player in players) {
    final representationExpiry = player.representationAgreementExpiry;
    if (representationExpiry != null &&
        !representationExpiry.isBefore(today) &&
        !representationExpiry.isAfter(cutoff)) {
      final daysRemaining = representationExpiry.difference(today).inDays;
      alerts.add(ContractExpiryAlert(
        playerId: player.id,
        playerName: player.fullName,
        contractType: ContractType.representationAgreement,
        expiryDate: representationExpiry,
        daysRemaining: daysRemaining,
        urgency: _urgencyForDaysRemaining(daysRemaining),
      ));
    }

    final clubExpiry = player.clubContractExpiry;
    if (clubExpiry != null &&
        !clubExpiry.isBefore(today) &&
        !clubExpiry.isAfter(cutoff)) {
      final daysRemaining = clubExpiry.difference(today).inDays;
      alerts.add(ContractExpiryAlert(
        playerId: player.id,
        playerName: player.fullName,
        contractType: ContractType.clubContract,
        expiryDate: clubExpiry,
        daysRemaining: daysRemaining,
        urgency: _urgencyForDaysRemaining(daysRemaining),
      ));
    }
  }

  alerts.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  return alerts;
}

@riverpod
Future<PlayerStats> playerStats(PlayerStatsRef ref) async {
  final players = await ref.watch(agentPlayersProvider.future);

  return PlayerStats(
    totalPlayers: players.length,
    activeClients:
        players.where((p) => p.status == PlayerStatus.activeClient).length,
    prospects: players.where((p) => p.status == PlayerStatus.prospect).length,
  );
}

bool _isActivePost(MarketPostModel post) =>
    post.status == MarketPostStatus.active && !post.isExpired;

/// The agent's active (non-expired, non-closed) Market posts, sorted by
/// soonest expiry first. Capped to the top 3 for the Dashboard section;
/// [dashboardActivePostsCount] reports the full count separately.
@riverpod
Future<List<MarketPostModel>> dashboardActivePosts(
  DashboardActivePostsRef ref,
) async {
  final posts = await ref.watch(myPostsProvider.future);
  final active = posts.where(_isActivePost).toList()
    ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
  return active.take(3).toList();
}

@riverpod
Future<int> dashboardActivePostsCount(
  DashboardActivePostsCountRef ref,
) async {
  final posts = await ref.watch(myPostsProvider.future);
  return posts.where(_isActivePost).length;
}
