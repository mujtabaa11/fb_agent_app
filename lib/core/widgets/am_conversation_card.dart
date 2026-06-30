import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'am_avatar.dart';

class AmConversationCard extends StatelessWidget {
  const AmConversationCard({
    required this.agentName,
    required this.lastMessage,
    required this.timestamp,
    this.agentAvatarUrl,
    this.unreadCount = 0,
    this.onTap,
    super.key,
  });

  final String agentName;
  final String lastMessage;
  final String timestamp;
  final String? agentAvatarUrl;
  final int unreadCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: l10n.conversationCardLabel(agentName, lastMessage),
      child: Card(
        elevation: AppTokens.elevationNone,
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
                    imageUrl: agentAvatarUrl,
                    name: agentName,
                    size: AmAvatarSize.medium,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                agentName,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTokens.space8),
                            Text(
                              timestamp,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMessage,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: AppTokens.space8),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppTokens.space8,
                                  vertical: AppTokens.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppTokens.radiusXl,
                                  ),
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    fontSize: AppTokens.fontSizeXs,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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
