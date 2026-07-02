library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/am_post_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/market_post_enums.dart';
import '../models/market_post_model.dart';
import '../providers/market_feed_provider.dart';

class MarketPostCardItem extends ConsumerWidget {
  const MarketPostCardItem({required this.post, super.key});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final agentAsync = ref.watch(marketPostAgentProvider(post.agentId));
    final agent = agentAsync.valueOrNull;

    final isPlayerAvailable = post.type == MarketPostType.playerAvailable;

    final daysUntilExpiry = post.expiresAt.difference(DateTime.now()).inDays;
    final expiryWarningText = daysUntilExpiry <= 7 && daysUntilExpiry >= 0
        ? l10n.marketExpiresInDays(daysUntilExpiry)
        : null;

    return AmPostCard(
      postTypeBadgeLabel: isPlayerAvailable
          ? l10n.postTypePlayerAvailable
          : l10n.postTypeNeedPlayer,
      postTypeBadgeBackgroundColor: isPlayerAvailable
          ? (isDark ? AppColors.successSurfaceDark : AppColors.successSurface)
          : AppColors.primarySurface,
      postTypeBadgeTextColor: isPlayerAvailable
          ? (isDark ? AppColors.successDark : AppColors.success)
          : AppColors.primary,
      detailsLine: _detailsLine(l10n, isPlayerAvailable),
      descriptionPreview: post.description,
      agentName: agent?.fullName ?? '',
      postedDate: _relativePostedDate(l10n),
      playerPhotoUrl: (!post.isPlayerAnonymous && isPlayerAvailable)
          ? post.playerPhotoUrl
          : null,
      agentAvatarUrl: agent?.avatarUrl,
      valueLine: _valueLine(isPlayerAvailable),
      expiryWarningText: expiryWarningText,
      onTap: () => context.push('/market/post/${post.id}'),
      onAgentTap: () => context.push('/market/agent/${post.agentId}'),
    );
  }

  String? _valueLine(bool isPlayerAvailable) {
    final value = isPlayerAvailable ? post.playerMarketValue : post.budget;
    if (value == null) return null;
    return formatMarketEurValue(value);
  }

  String _detailsLine(AppLocalizations l10n, bool isPlayerAvailable) {
    if (isPlayerAvailable) {
      final position = post.playerPosition?.toFirestoreValue() ?? '';
      final nationality = post.playerNationality ?? '';
      final age =
          post.playerAge != null ? l10n.marketAgeYears(post.playerAge!) : '';
      return l10n.marketPlayerAgeDetail(position, nationality, age);
    }

    final position = post.neededPosition?.toFirestoreValue() ?? '';
    final nationality = (post.neededNationalities?.isNotEmpty ?? false)
        ? post.neededNationalities!.first
        : '';
    final ageRange = (post.neededMinAge != null && post.neededMaxAge != null)
        ? l10n.marketAgeRange(post.neededMinAge!, post.neededMaxAge!)
        : '';
    return l10n.marketNeededPlayerDetail(position, nationality, ageRange);
  }

  String _relativePostedDate(AppLocalizations l10n) {
    final createdAt = post.createdAt;
    if (createdAt == null) return '';

    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return l10n.marketDurationJustNow;

    final String duration;
    if (difference.inDays >= 1) {
      duration = l10n.marketDurationDays(difference.inDays);
    } else if (difference.inHours >= 1) {
      duration = l10n.marketDurationHours(difference.inHours);
    } else {
      duration = l10n.marketDurationMinutes(difference.inMinutes);
    }

    return l10n.marketPostedAgo(duration);
  }
}

String formatMarketEurValue(double value) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return '€${formatter.format(value)}';
}
