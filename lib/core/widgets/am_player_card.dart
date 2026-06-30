import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_tokens.dart';
import 'am_avatar.dart';
import 'am_status_badge.dart';

class AmPlayerCard extends StatelessWidget {
  const AmPlayerCard({
    required this.fullName,
    required this.position,
    required this.currentClub,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusTextColor,
    this.photoUrl,
    this.onTap,
    super.key,
  });

  final String fullName;
  final String position;
  final String currentClub;
  final String statusLabel;
  final Color statusBackgroundColor;
  final Color statusTextColor;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: l10n.playerCardLabel(fullName, position, currentClub),
      child: Card(
        elevation: AppTokens.elevationSm,
        margin: EdgeInsetsDirectional.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space12),
              child: Row(
                children: [
                  AmAvatar(
                    imageUrl: photoUrl,
                    name: fullName,
                    size: AmAvatarSize.medium,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          '$position · $currentClub',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  AmStatusBadge(
                    label: statusLabel,
                    backgroundColor: statusBackgroundColor,
                    textColor: statusTextColor,
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
