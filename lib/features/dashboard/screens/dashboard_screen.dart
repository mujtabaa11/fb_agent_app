/// Dashboard tab screen — quick stats strip and contract expiry alerts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/agent_providers.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/contract_expiry_alert_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.space16,
                AppTokens.space24,
                AppTokens.space16,
                AppTokens.space8,
              ),
              child: _GreetingHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: AppTokens.space16,
                bottom: AppTokens.space8,
              ),
              child: _QuickStatsStrip(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.space16,
                AppTokens.space24,
                AppTokens.space16,
                AppTokens.space8,
              ),
              child: _SectionHeader(
                title: AppLocalizations.of(context)!.sectionUpcomingExpiries,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.space16,
                0,
                AppTokens.space16,
                AppTokens.space24,
              ),
              child: _ContractExpirySection(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final agent = ref.watch(currentAgentProvider);
    final fullName = agent?.fullName ?? '';
    final firstName =
        fullName.trim().isEmpty ? '' : fullName.trim().split(' ').first;

    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 5 && <= 11 => l10n.dashboardGreetingMorning(firstName),
      >= 12 && <= 17 => l10n.dashboardGreetingAfternoon(firstName),
      _ => l10n.dashboardGreetingEvening(firstName),
    };

    return Semantics(
      header: true,
      child: Text(
        greeting,
        style: const TextStyle(
          fontSize: AppTokens.fontSizeXxl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppTokens.fontSizeLg,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QuickStatsStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(playerStatsProvider);

    return SizedBox(
      height: 108,
      child: statsAsync.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.space16,
          ),
          children: const [
            SizedBox(width: 160, child: AmLoadingSkeleton()),
          ],
        ),
        error: (error, _) => AmErrorState(
          message: l10n.errorLoadingDashboard,
          onRetry: () => ref.invalidate(playerStatsProvider),
        ),
        data: (stats) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.space16,
          ),
          child: Row(
            children: [
              _StatTile(
                value: '${stats.totalPlayers}',
                label: l10n.statsTotalPlayers,
              ),
              const SizedBox(width: AppTokens.space12),
              _StatTile(
                value: '${stats.activeClients}',
                label: l10n.statsActiveClients,
              ),
              const SizedBox(width: AppTokens.space12),
              _StatTile(
                value: '${stats.prospects}',
                label: l10n.statsProspects,
              ),
              const SizedBox(width: AppTokens.space12),
              _StatTile(
                value: '0',
                label: l10n.statsMarketPosts,
                subLabel: l10n.statsComingSoon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.subLabel,
  });

  final String value;
  final String label;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel =
        subLabel == null ? '$value $label' : '$value $label, $subLabel';

    return Semantics(
      label: semanticsLabel,
      child: Container(
        width: 140,
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: AppTokens.fontSizeXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTokens.fontSizeSm,
                color: AppColors.textSecondary,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: AppTokens.space4),
              Text(
                subLabel!,
                style: const TextStyle(
                  fontSize: AppTokens.fontSizeXs,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContractExpirySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final alertsAsync = ref.watch(contractExpiryAlertsProvider);

    return alertsAsync.when(
      loading: () => const Column(
        children: [
          AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
          AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
        ],
      ),
      error: (error, _) => AmErrorState(
        message: l10n.errorLoadingDashboard,
        onRetry: () => ref.invalidate(contractExpiryAlertsProvider),
      ),
      data: (alerts) {
        if (alerts.isEmpty) {
          return AmEmptyState(
            icon: Icons.event_available_outlined,
            title: l10n.emptyExpiriesTitle,
            subtitle: l10n.emptyExpiriesMessage,
          );
        }

        return Column(
          children: [
            for (final alert in alerts)
              ContractExpiryAlertItem(
                key: ValueKey('${alert.playerId}-${alert.contractType}'),
                alert: alert,
              ),
          ],
        );
      },
    );
  }
}
