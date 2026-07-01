/// Navigation controls for the onboarding carousel.
///
/// Renders Skip and Next on non-final pages. Hidden entirely on the final
/// page — the final page's CTAs are rendered inline by
/// [OnboardingPageContent] instead. All buttons meet 44x44pt minimum touch
/// targets and have [Semantics] labels.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Bottom navigation row for the onboarding screen.
class OnboardingNavControls extends StatelessWidget {
  const OnboardingNavControls({
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
    super.key,
  });

  /// Whether the current page is the last page.
  final bool isLastPage;

  /// Called when the user taps Skip.
  final VoidCallback onSkip;

  /// Called when the user taps Next.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (isLastPage) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: l10n.onboardingSkip,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              child: Text(l10n.onboardingSkip),
            ),
          ),
          Semantics(
            label: l10n.onboardingNextButton,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(44, 48),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space24,
                ),
              ),
              child: Text(l10n.onboardingNextButton),
            ),
          ),
        ],
      ),
    );
  }
}
