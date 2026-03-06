/// Data class representing a single onboarding page.
///
/// Each page is defined by an [icon], a [titleKey] getter name, and a
/// [subtitleKey] getter name that reference [AppLocalizations] properties.
/// The placeholder pages are defined in [defaultPages] — downstream projects
/// edit this list to customize content.
library;

import 'package:flutter/material.dart';
import 'package:template_app/l10n/app_localizations.dart';

/// Immutable data describing one onboarding carousel page.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Placeholder illustration icon displayed at the top of the page.
  final IconData icon;

  /// Localized title getter — called with the current [AppLocalizations].
  final String Function(AppLocalizations l10n) title;

  /// Localized subtitle getter — called with the current [AppLocalizations].
  final String Function(AppLocalizations l10n) subtitle;
}

/// Placeholder onboarding pages shipped with the boilerplate.
///
/// To customize: add, remove, or reorder entries in this list. Each entry
/// needs a corresponding ARB key in `app_en.arb` and `app_ar.arb`.
const List<OnboardingPageData> defaultOnboardingPages = [
  OnboardingPageData(
    icon: Icons.rocket_launch_outlined,
    title: _welcomeTitle,
    subtitle: _welcomeSubtitle,
  ),
  OnboardingPageData(
    icon: Icons.bolt_outlined,
    title: _buildFasterTitle,
    subtitle: _buildFasterSubtitle,
  ),
  OnboardingPageData(
    icon: Icons.verified_outlined,
    title: _shipTitle,
    subtitle: _shipSubtitle,
  ),
];

// ---------------------------------------------------------------------------
// Localized string accessors — one per ARB key.
// ---------------------------------------------------------------------------

String _welcomeTitle(AppLocalizations l10n) => l10n.onboardingWelcomeTitle;
String _welcomeSubtitle(AppLocalizations l10n) =>
    l10n.onboardingWelcomeSubtitle;

String _buildFasterTitle(AppLocalizations l10n) =>
    l10n.onboardingBuildFasterTitle;
String _buildFasterSubtitle(AppLocalizations l10n) =>
    l10n.onboardingBuildFasterSubtitle;

String _shipTitle(AppLocalizations l10n) => l10n.onboardingShipTitle;
String _shipSubtitle(AppLocalizations l10n) => l10n.onboardingShipSubtitle;
