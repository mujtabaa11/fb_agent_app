/// Root application widget.
///
/// Wires routing, theming, and localisation into a single [MaterialApp.router].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/locale_notifier.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/biometric/widgets/biometric_guard.dart';

class App extends ConsumerWidget {
  const App({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider).valueOrNull ??
        ThemeMode.system;
    final localeState = ref.watch(localeNotifierProvider);
    final locale = localeState.valueOrNull;

    return MaterialApp.router(
      title: AppConstants.appTitle,
      // ------------------------------------------------------------------
      // Theming
      // ------------------------------------------------------------------
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // ------------------------------------------------------------------
      // Routing
      // ------------------------------------------------------------------
      routerConfig: router,
      // ------------------------------------------------------------------
      // Localisation
      // ------------------------------------------------------------------
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) {
        return BiometricGuard(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
