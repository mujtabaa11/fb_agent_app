library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class CreatePostTypeScreen extends StatelessWidget {
  const CreatePostTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createPostTitle)),
      body: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: Column(
          children: [
            _PostTypeOptionCard(
              icon: Icons.person,
              title: l10n.postTypePlayerAvailable,
              subtitle: l10n.postTypePlayerAvailableSubtitle,
              onTap: () => context.push('/market/post/create/player-available'),
            ),
            const SizedBox(height: AppTokens.space16),
            _PostTypeOptionCard(
              icon: Icons.search,
              title: l10n.postTypeNeedPlayer,
              subtitle: l10n.postTypeNeedAPlayerSubtitle,
              onTap: () => context.push('/market/post/create/need-a-player'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostTypeOptionCard extends StatelessWidget {
  const _PostTypeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsetsDirectional.all(AppTokens.space16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: AppTokens.space32),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppTokens.fontSizeLg,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppTokens.fontSizeSm,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
