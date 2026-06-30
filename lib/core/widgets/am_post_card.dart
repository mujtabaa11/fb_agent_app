import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'am_avatar.dart';
import 'am_status_badge.dart';

class AmPostCard extends StatelessWidget {
  const AmPostCard({
    required this.postTypeBadgeLabel,
    required this.postTypeBadgeBackgroundColor,
    required this.postTypeBadgeTextColor,
    required this.detailsLine,
    required this.descriptionPreview,
    required this.agentName,
    required this.postedDate,
    this.playerPhotoUrl,
    this.agentAvatarUrl,
    this.onTap,
    super.key,
  });

  final String postTypeBadgeLabel;
  final Color postTypeBadgeBackgroundColor;
  final Color postTypeBadgeTextColor;
  final String detailsLine;
  final String descriptionPreview;
  final String agentName;
  final String postedDate;
  final String? playerPhotoUrl;
  final String? agentAvatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Semantics(
      button: onTap != null,
      label: l10n.postCardLabel(postTypeBadgeLabel, detailsLine),
      child: Card(
        elevation: AppTokens.elevationSm,
        margin: EdgeInsetsDirectional.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AmStatusBadge(
                        label: postTypeBadgeLabel,
                        backgroundColor: postTypeBadgeBackgroundColor,
                        textColor: postTypeBadgeTextColor,
                      ),
                      const Spacer(),
                      if (playerPhotoUrl != null)
                        AmAvatar(
                          imageUrl: playerPhotoUrl,
                          size: AmAvatarSize.small,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space12),
                  Text(
                    detailsLine,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    descriptionPreview,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTokens.space12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: AppTokens.space12),
                  Row(
                    children: [
                      AmAvatar(
                        imageUrl: agentAvatarUrl,
                        name: agentName,
                        size: AmAvatarSize.small,
                      ),
                      const SizedBox(width: AppTokens.space8),
                      Expanded(
                        child: Text(
                          agentName,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        postedDate,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
