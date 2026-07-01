/// Test utilities for widget and integration tests.
///
/// The main entry point is [pumpApp], which wraps a widget under test in the
/// same widget tree shape as the real app: [ProviderScope] + [MaterialApp.router]
/// with localisation delegates and the app theme.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_agent_mate/core/constants/storage_keys.dart';
import 'package:football_agent_mate/core/services/connectivity_service.dart';
import 'package:football_agent_mate/core/theme/app_theme.dart';
import 'package:football_agent_mate/features/biometric/providers/biometric_providers.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import 'mock_providers.dart';

/// Pumps [child] inside a fully-configured app shell.
///
/// The shell includes:
///   - [ProviderScope] with optional [overrides]
///   - [MaterialApp.router] with a single-route [GoRouter]
///   - [AppLocalizations] delegates (English only for now; more locales can
///     be added later without changing this shape)
///   - Light theme by default
///   - A default [FakeConnectivityService] (online) so that widgets depending
///     on [connectivityStatusProvider] resolve correctly without explicit setup.
///
/// Parameters:
///   - [child] — the widget under test.
///   - [overrides] — Riverpod provider overrides (e.g. swap a real repo for
///     a fake). Defaults to an empty list. If you need to test offline widget
///     behavior, explicitly override [connectivityServiceProvider] with a
///     [FakeConnectivityService] whose initial status is
///     [ConnectivityStatus.offline].
///   - [locale] — the locale passed to [MaterialApp.router]. Defaults to
///     English (`en`), currently the only supported locale.
///   - [hasCompletedOnboarding] — whether the onboarding flag is set in
///     [SharedPreferences]. Defaults to `true` so that all existing tests
///     bypass onboarding. Set to `false` in onboarding-specific tests.
///
/// Example:
/// ```dart
/// testWidgets('shows title', (tester) async {
///   await pumpApp(
///     tester,
///     const MyWidget(),
///     overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepo)],
///   );
///   expect(find.text('Title'), findsOneWidget);
/// });
/// ```
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  bool hasCompletedOnboarding = true,
}) async {
  // Set SharedPreferences mock values so that providers reading the
  // onboarding flag (and any other prefs) resolve correctly in tests.
  SharedPreferences.setMockInitialValues({
    if (hasCompletedOnboarding)
      StorageKeys.hasCompletedOnboarding: true,
  });

  final testRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
    ],
  );

  // Inject default fakes so widgets resolve providers without errors.
  // Tests that need specific behavior should explicitly override.
  final effectiveOverrides = [
    connectivityServiceProvider
        .overrideWithValue(FakeConnectivityService()),
    biometricServiceProvider
        .overrideWithValue(FakeBiometricService()),
    ...overrides,
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: effectiveOverrides,
      child: MaterialApp.router(
        routerConfig: testRouter,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
      ),
    ),
  );

  // Allow async providers, animations, and the router to settle.
  await tester.pumpAndSettle();
}
