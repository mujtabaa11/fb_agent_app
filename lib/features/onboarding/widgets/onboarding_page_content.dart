/// Content layout for a single onboarding page.
///
/// Renders a placeholder icon, a title, and a subtitle using theme tokens.
/// All text comes from [AppLocalizations] — no hardcoded strings.
library;

import 'package:flutter/material.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';
import '../models/onboarding_page_data.dart';

/// A single page in the onboarding carousel displaying an icon, title, and
/// subtitle.
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.data,
    super.key,
  });

  /// The page data to render.
  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder illustration icon.
          ExcludeSemantics(
            child: Icon(
              data.icon,
              size: 120,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppTokens.space48),

          // Title.
          Text(
            data.title(l10n),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space16),

          // Subtitle.
          Text(
            data.subtitle(l10n),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
