library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../market/models/market_post_enums.dart';
import '../../market/models/market_post_model.dart';

class DashboardPostItem extends StatelessWidget {
  const DashboardPostItem({required this.post, super.key});

  final MarketPostModel post;

  bool get _isPlayerAvailable => post.type == MarketPostType.playerAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final typeLabel = _isPlayerAvailable
        ? l10n.postTypePlayerAvailable
        : l10n.postTypeNeedPlayer;
    final typeSurface = _isPlayerAvailable
        ? (isDark ? AppColors.successSurfaceDark : AppColors.successSurface)
        : AppColors.primarySurface;
    final typeColor = _isPlayerAvailable
        ? (isDark ? AppColors.successDark : AppColors.success)
        : AppColors.primary;

    final detailLine = _detailLine(l10n);
    final daysRemainingText = _daysRemainingText(l10n);
    final isUrgent = _daysUntilExpiry() <= 7;

    final semanticsLabel =
        '$typeLabel, $detailLine, $daysRemainingText';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: () => context.push('/market/post/${post.id}'),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          margin: const EdgeInsetsDirectional.only(bottom: AppTokens.space12),
          padding: const EdgeInsetsDirectional.all(AppTokens.space12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmStatusBadge(
                      label: typeLabel,
                      backgroundColor: typeSurface,
                      textColor: typeColor,
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      detailLine,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Text(
                daysRemainingText,
                style: TextStyle(
                  fontSize: AppTokens.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  color: isUrgent
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _detailLine(AppLocalizations l10n) {
    if (_isPlayerAvailable) {
      if (post.isPlayerAnonymous) return l10n.dashboardPostAnonymous;
      final position = post.playerPosition?.toFirestoreValue() ?? '';
      final nationality = post.playerNationality ?? '';
      return [position, nationality].where((s) => s.isNotEmpty).join(' • ');
    }

    final position = post.neededPosition?.toFirestoreValue() ?? '';
    final nationality = (post.neededNationalities?.isNotEmpty ?? false)
        ? post.neededNationalities!.first
        : l10n.dashboardPostAnyNationality;
    return [position, nationality].where((s) => s.isNotEmpty).join(' • ');
  }

  int _daysUntilExpiry() {
    final now = DateTime.now();
    final expiresAt = post.expiresAt;
    return DateTime(expiresAt.year, expiresAt.month, expiresAt.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  String _daysRemainingText(AppLocalizations l10n) {
    final days = _daysUntilExpiry();
    if (days <= 0) return l10n.postExpiresToday;
    if (days == 1) return l10n.postOneDayRemaining;
    return l10n.postDaysRemaining(days);
  }
}
