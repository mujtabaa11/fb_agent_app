/// Data class representing a single onboarding page.
///
/// Each page is defined by an [icon], a [title] getter, and a [subtitle]
/// getter that reference [AppLocalizations] properties. The final page in
/// [defaultOnboardingPages] additionally carries primary/secondary CTA
/// labels — when present, the screen renders these instead of the generic
/// Skip/Next controls.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

/// Immutable data describing one onboarding carousel page.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.primaryCtaLabel,
    this.secondaryCtaLabel,
  });

  /// Icon displayed at the top of the page.
  final IconData icon;

  /// Localized title getter — called with the current [AppLocalizations].
  final String Function(AppLocalizations l10n) title;

  /// Localized subtitle getter — called with the current [AppLocalizations].
  final String Function(AppLocalizations l10n) subtitle;

  /// Localized label for the primary CTA button. Only the final page
  /// defines this — when non-null, [OnboardingPageContent] renders the CTA
  /// buttons instead of relying on the generic nav controls' Done button.
  final String Function(AppLocalizations l10n)? primaryCtaLabel;

  /// Localized label for the secondary CTA button (shown below the
  /// primary CTA on the final page only).
  final String Function(AppLocalizations l10n)? secondaryCtaLabel;
}

/// Agent Mate onboarding pages.
const List<OnboardingPageData> defaultOnboardingPages = [
  OnboardingPageData(
    icon: Icons.sports_soccer,
    title: _slide1Title,
    subtitle: _slide1Body,
  ),
  OnboardingPageData(
    icon: Icons.people,
    title: _slide2Title,
    subtitle: _slide2Body,
  ),
  OnboardingPageData(
    icon: Icons.storefront,
    title: _slide3Title,
    subtitle: _slide3Body,
    primaryCtaLabel: _getStarted,
    secondaryCtaLabel: _haveAccount,
  ),
];

// ---------------------------------------------------------------------------
// Localized string accessors — one per ARB key.
// ---------------------------------------------------------------------------

String _slide1Title(AppLocalizations l10n) => l10n.onboardingSlide1Title;
String _slide1Body(AppLocalizations l10n) => l10n.onboardingSlide1Body;

String _slide2Title(AppLocalizations l10n) => l10n.onboardingSlide2Title;
String _slide2Body(AppLocalizations l10n) => l10n.onboardingSlide2Body;

String _slide3Title(AppLocalizations l10n) => l10n.onboardingSlide3Title;
String _slide3Body(AppLocalizations l10n) => l10n.onboardingSlide3Body;

String _getStarted(AppLocalizations l10n) => l10n.onboardingGetStarted;
String _haveAccount(AppLocalizations l10n) => l10n.onboardingHaveAccount;
