/// Content layout for a single onboarding page.
///
/// Renders an icon inside a circular accent, a title, and a subtitle using
/// theme tokens. On the final page, also renders the primary/secondary CTA
/// buttons defined on [OnboardingPageData]. All text comes from
/// [AppLocalizations] — no hardcoded strings.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_button.dart';
import '../models/onboarding_page_data.dart';

/// A single page in the onboarding carousel displaying an icon, title,
/// subtitle, and — on the final page — the CTA buttons.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.data,
    required this.onPrimaryCta,
    required this.onSecondaryCta,
    super.key,
  });

  /// The page data to render.
  final OnboardingPageData data;

  /// Called when the primary CTA is tapped (final page only).
  final VoidCallback onPrimaryCta;

  /// Called when the secondary CTA is tapped (final page only).
  final VoidCallback onSecondaryCta;

  static const double _iconSize = 96;
  static const double _iconAccentSize = _iconSize * 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasCta = data.primaryCtaLabel != null;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          // Top area — icon centered on a circular accent.
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: _iconAccentSize,
                height: _iconAccentSize,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    data.icon,
                    size: _iconSize,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Bottom area — headline, body, and (on the final page) CTAs.
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    data.title(l10n),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space16),
                  Text(
                    data.subtitle(l10n),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasCta) ...[
                    const SizedBox(height: AppTokens.space24),
                    SizedBox(
                      width: double.infinity,
                      child: AmPrimaryButton(
                        label: data.primaryCtaLabel!(l10n),
                        onPressed: onPrimaryCta,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AmTextButton(
                      label: data.secondaryCtaLabel!(l10n),
                      onPressed: onSecondaryCta,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
