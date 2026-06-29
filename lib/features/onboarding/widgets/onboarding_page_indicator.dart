/// Dot-based page indicator for the onboarding carousel.
///
/// Reflects the current page position, handles any number of pages (1 to N),
/// and announces the position to screen readers.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';

/// A row of dots that highlights the current page in the onboarding carousel.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.pageCount,
    required this.currentPage,
    super.key,
  });

  /// Total number of pages in the carousel.
  final int pageCount;

  /// Zero-based index of the currently visible page.
  final int currentPage;

  static const double _dotSize = 8.0;
  static const double _activeDotWidth = 24.0;
  static const double _dotSpacing = AppTokens.space8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.onboardingPageIndicator(currentPage + 1, pageCount),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pageCount, (index) {
            final isActive = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsetsDirectional.only(
                end: index < pageCount - 1 ? _dotSpacing : 0,
              ),
              width: isActive ? _activeDotWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(_dotSize / 2),
              ),
            );
          }),
        ),
      ),
    );
  }
}
