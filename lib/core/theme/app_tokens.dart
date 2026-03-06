import 'package:flutter/material.dart';

/// Design tokens for the application.
///
/// All color pairs have been verified to meet WCAG AA contrast minimums
/// (4.5:1 for normal text, 3:1 for large text).
abstract final class AppTokens {
  // ---------------------------------------------------------------------------
  // Colors — Light scheme
  // ---------------------------------------------------------------------------

  static const Color primaryLight = Color(0xFF1E3A5F);
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // 11.50:1
  static const Color secondaryLight = Color(0xFF2D6A9F);
  static const Color onSecondaryLight = Color(0xFFFFFFFF); // 5.72:1
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color onBackgroundLight = Color(0xFF1A1A2E); // 15.89:1
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A1A2E); // 17.06:1
  static const Color errorLight = Color(0xFFB00020);
  static const Color onErrorLight = Color(0xFFFFFFFF); // 7.33:1

  // ---------------------------------------------------------------------------
  // Colors — Dark scheme
  // ---------------------------------------------------------------------------

  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color onPrimaryDark = Color(0xFF0D1B2A); // 9.94:1
  static const Color secondaryDark = Color(0xFF64B5F6);
  static const Color onSecondaryDark = Color(0xFF0D1B2A); // 7.85:1
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color onBackgroundDark = Color(0xFFE8EAF6); // 14.52:1
  static const Color surfaceDark = Color(0xFF1A2D42);
  static const Color onSurfaceDark = Color(0xFFE8EAF6); // 11.70:1
  static const Color errorDark = Color(0xFFCF6679);
  static const Color onErrorDark = Color(0xFF1A1A2E); // 4.74:1

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
