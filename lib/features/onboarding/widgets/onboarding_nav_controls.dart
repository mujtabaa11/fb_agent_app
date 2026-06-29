/// Navigation controls for the onboarding carousel.
///
/// Renders Skip (hidden on last page), Next (hidden on last page), and
/// Get Started (shown on last page only). All buttons meet 44x44pt minimum
/// touch targets and have [Semantics] labels.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';

/// Bottom navigation row for the onboarding screen.
class OnboardingNavControls extends StatelessWidget {
  const OnboardingNavControls({
    required this.isLastPage,
    required this.isSinglePage,
    required this.onSkip,
    required this.onNext,
    required this.onDone,
    super.key,
  });

  /// Whether the current page is the last page.
  final bool isLastPage;

  /// Whether the carousel has only a single page.
  final bool isSinglePage;

  /// Called when the user taps Skip.
  final VoidCallback onSkip;

  /// Called when the user taps Next.
  final VoidCallback onNext;

  /// Called when the user taps Get Started.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip — hidden on last page and when there's only one page.
          if (!isLastPage && !isSinglePage)
            Semantics(
              label: l10n.onboardingSkipButton,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(l10n.onboardingSkipButton),
              ),
            )
          else
            const SizedBox(width: 44),

          // Next or Get Started.
          if (isLastPage || isSinglePage)
            Semantics(
              label: l10n.onboardingGetStartedButton,
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(44, 48),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppTokens.space24,
                  ),
                ),
                child: Text(l10n.onboardingGetStartedButton),
              ),
            )
          else
            Semantics(
              label: l10n.onboardingNextButton,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
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
