import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens for the application.
///
/// Color values are sourced from [AppColors] (the official Agent Mate palette).
abstract final class AppTokens {
  // ---------------------------------------------------------------------------
  // Colors — Light scheme
  // ---------------------------------------------------------------------------

  static const Color primaryLight = AppColors.primary;
  static const Color onPrimaryLight = AppColors.onPrimary;
  static const Color secondaryLight = AppColors.primaryLight;
  static const Color onSecondaryLight = AppColors.onPrimary;
  static const Color backgroundLight = AppColors.background;
  static const Color onBackgroundLight = AppColors.textPrimary;
  static const Color surfaceLight = AppColors.surface;
  static const Color onSurfaceLight = AppColors.textPrimary;
  static const Color errorLight = AppColors.error;
  static const Color onErrorLight = AppColors.onPrimary;

  // ---------------------------------------------------------------------------
  // Colors — Dark scheme
  // ---------------------------------------------------------------------------

  static const Color primaryDark = AppColors.primaryLight;
  static const Color onPrimaryDark = AppColors.onPrimary;
  static const Color secondaryDark = AppColors.primaryLight;
  static const Color onSecondaryDark = AppColors.onPrimary;
  static const Color backgroundDark = AppColors.backgroundDark;
  static const Color onBackgroundDark = AppColors.textPrimaryDark;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color onSurfaceDark = AppColors.textPrimaryDark;
  static const Color errorDark = AppColors.errorDark;
  static const Color onErrorDark = AppColors.textPrimary;

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  static const String fontFamily = 'System';
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 17.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeDisplay = 32.0;

  // ---------------------------------------------------------------------------
  // Border radius
  // ---------------------------------------------------------------------------

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------

  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
}
