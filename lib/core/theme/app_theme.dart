import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Application [ThemeData] for light and dark modes.
///
/// All values are derived from [AppTokens] — no hardcoded literals.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppTokens.primaryLight,
      onPrimary: AppTokens.onPrimaryLight,
      secondary: AppTokens.secondaryLight,
      onSecondary: AppTokens.onSecondaryLight,
      error: AppTokens.errorLight,
      onError: AppTokens.onErrorLight,
      surface: AppTokens.surfaceLight,
      onSurface: AppTokens.onSurfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.backgroundLight,
      textTheme: _buildTextTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppTokens.primaryDark,
      onPrimary: AppTokens.onPrimaryDark,
      secondary: AppTokens.secondaryDark,
      onSecondary: AppTokens.onSecondaryDark,
      error: AppTokens.errorDark,
      onError: AppTokens.onErrorDark,
      surface: AppTokens.surfaceDark,
      onSurface: AppTokens.onSurfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.backgroundDark,
      textTheme: _buildTextTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared builders
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppTokens.fontSizeDisplay,
        fontFamily: AppTokens.fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: AppTokens.fontSizeXxl,
        fontFamily: AppTokens.fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: AppTokens.fontSizeXl,
        fontFamily: AppTokens.fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: AppTokens.fontSizeXl,
        fontFamily: AppTokens.fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: AppTokens.fontSizeLg,
        fontFamily: AppTokens.fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: AppTokens.fontSizeMd,
        fontFamily: AppTokens.fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: AppTokens.fontSizeMd,
        fontFamily: AppTokens.fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTokens.fontSizeSm,
        fontFamily: AppTokens.fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: AppTokens.fontSizeXs,
        fontFamily: AppTokens.fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: AppTokens.fontSizeMd,
        fontFamily: AppTokens.fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: AppTokens.fontSizeSm,
        fontFamily: AppTokens.fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: AppTokens.fontSizeXs,
        fontFamily: AppTokens.fontFamily,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    final borderRadius = BorderRadius.circular(AppTokens.radiusMd);

    return InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.onSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: AppTokens.elevationNone,
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme() {
    TextStyle labelStyle(Set<WidgetState> states) {
      final isSelected = states.contains(WidgetState.selected);
      return TextStyle(
        fontSize: AppTokens.fontSizeXs,
        fontFamily: AppTokens.fontFamily,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      );
    }

    return NavigationBarThemeData(
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(labelStyle),
    );
  }
}
