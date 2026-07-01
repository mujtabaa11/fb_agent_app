/// Tests for the onboarding redirect guard logic.
///
/// The production router in `lib/routing/router.dart` uses module-level globals,
/// so we cannot inject dependencies directly. Instead, we build a test-local
/// [GoRouter] that replicates the five-state redirect chain with controllable
/// onboarding, auth, and profile-completeness flags.
///
/// Tests verify the redirect path, NOT rendered widget content.
///
/// The five-state priority chain:
///   1. Onboarding not completed → `/onboarding`
///   2. Unauthenticated → `/login`
///   3. Email/password user with unverified email → `/verify-email`
///   4. Profile incomplete (or not yet loaded) → `/setup`
///   5. Authenticated, verified, and profile complete → `/dashboard`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/mock_providers.dart';

/// A [ChangeNotifier] that mirrors the production [_AuthChangeNotifier] but
/// allows tests to control the [isLoading] flag directly.
class _TestAuthChangeNotifier extends ChangeNotifier {
  bool _isLoading;

  _TestAuthChangeNotifier({bool isLoading = false}) : _isLoading = isLoading;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void notify() => notifyListeners();
}

/// A test-local notifier that mirrors the production [OnboardingFlagNotifier]
/// with controllable state.
class _TestOnboardingFlagNotifier extends ChangeNotifier {
  _TestOnboardingFlagNotifier({
    bool isLoading = false,
    bool hasCompleted = false,
  })  : _isLoading = isLoading,
        _hasCompleted = hasCompleted;

  bool _isLoading;
  bool _hasCompleted;

  bool get isLoading => _isLoading;
  bool get hasCompleted => _hasCompleted;

  void markCompleted() {
    _hasCompleted = true;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

void main() {
  late FakeAuthRepository fakeAuth;
  late _TestAuthChangeNotifier authNotifier;
  late _TestOnboardingFlagNotifier onboardingNotifier;

  /// Whether the fake agent's profile is complete. `null` mirrors
  /// [currentAgentProvider] returning `null` (profile not yet loaded) —
  /// both are treated as incomplete by the guard.
  bool? isProfileComplete;

  /// Builds a [GoRouter] with the full five-state redirect logic from
  /// production, backed by test-controllable fakes.
  GoRouter buildTestRouter({String initialLocation = '/splash'}) {
    final refreshNotifier =
        Listenable.merge([authNotifier, onboardingNotifier]);

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuthRoute = location == '/login' ||
            location == '/signup' ||
            location == '/forgot-password';
        final isSplash = location == '/splash';
        final isVerifyEmail = location == '/verify-email';
        final isOnboarding = location == '/onboarding';
        final isSetup = location == '/setup';

        // 1. Onboarding flag still loading — hold on splash.
        if (onboardingNotifier.isLoading) return isSplash ? null : '/splash';

        // 2. Onboarding not completed — redirect to /onboarding.
        if (!onboardingNotifier.hasCompleted) {
          return isOnboarding ? null : '/onboarding';
        }

        // 3. Auth state not yet determined — hold on splash.
        if (authNotifier.isLoading) return isSplash ? null : '/splash';

        final user = fakeAuth.currentUser;

        // 4. Unauthenticated — redirect to login.
        if (user == null && !isAuthRoute) return '/login';

        if (user != null) {
          final needsVerification =
              fakeAuth.currentSignInProvider == 'password' &&
                  !user.emailVerified;

          // 5. Unverified email/password user — redirect to verification.
          if (needsVerification && !isVerifyEmail) return '/verify-email';

          if (!needsVerification) {
            final profileIncomplete = isProfileComplete != true;

            // 6. Profile incomplete (or not yet loaded) — redirect to setup.
            if (profileIncomplete && !isSetup) return '/setup';

            // 7. Profile complete but on setup/auth/splash/verify/onboarding
            //    — redirect to the dashboard.
            if (!profileIncomplete &&
                (isAuthRoute ||
                    isSplash ||
                    isVerifyEmail ||
                    isOnboarding ||
                    isSetup)) {
              return '/dashboard';
            }
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/splash',
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) =>
              const Scaffold(body: Text('splash')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) =>
              const Scaffold(body: Text('onboarding')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('login')),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) =>
              const Scaffold(body: Text('signup')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('forgot-password')),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) =>
              const Scaffold(body: Text('verify-email')),
        ),
        GoRoute(
          path: '/setup',
          builder: (context, state) =>
              const Scaffold(body: Text('setup')),
        ),
        ShellRoute(
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('dashboard')),
            ),
            GoRoute(
              path: '/players',
              builder: (context, state) =>
                  const Scaffold(body: Text('players')),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: Text('profile')),
            ),
          ],
        ),
      ],
    );
  }

  /// Pumps a [MaterialApp.router] with the given [router] and settles.
  Future<void> pumpRouter(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fakeAuth = FakeAuthRepository();
    authNotifier = _TestAuthChangeNotifier();
    onboardingNotifier = _TestOnboardingFlagNotifier();
    isProfileComplete = null;
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  // ---------------------------------------------------------------------------
  // Onboarding guard — first-time user
  // ---------------------------------------------------------------------------

  group('onboarding guard', () {
    testWidgets(
        'first-time user with onboarding not completed redirects to /onboarding',
        (tester) async {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: false);

      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/onboarding',
      );
    });

    testWidgets(
        'first-time user navigating to /login is redirected to /onboarding',
        (tester) async {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: false);

      final router = buildTestRouter(initialLocation: '/login');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/onboarding',
      );
    });

    testWidgets(
        'first-time user already on /onboarding stays on /onboarding',
        (tester) async {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: false);

      final router = buildTestRouter(initialLocation: '/onboarding');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/onboarding',
      );
    });

    testWidgets(
        'while onboarding flag is loading, user stays on /splash',
        (tester) async {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(isLoading: true);

      final router = buildTestRouter(initialLocation: '/splash');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/splash',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-onboarding — unauthenticated
  // ---------------------------------------------------------------------------

  group('onboarding completed, unauthenticated user', () {
    setUp(() {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: true);
    });

    testWidgets(
        'navigating to /dashboard redirects to /login, not /onboarding',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/login',
      );
    });

    testWidgets('navigating to /onboarding redirects to /login',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/onboarding');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/login',
      );
    });

    testWidgets('navigating to /login stays on /login', (tester) async {
      final router = buildTestRouter(initialLocation: '/login');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/login',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-onboarding — authenticated, unverified email
  // ---------------------------------------------------------------------------

  group('onboarding completed, authenticated with unverified email', () {
    setUp(() {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: true);
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'password';
    });

    testWidgets('navigating to /dashboard redirects to /verify-email',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/verify-email',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-onboarding — authenticated, verified, profile incomplete
  // ---------------------------------------------------------------------------

  group('onboarding completed, authenticated and verified, profile incomplete',
      () {
    setUp(() {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: true);
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'password';
    });

    testWidgets('navigating to /dashboard redirects to /setup',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/setup',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-onboarding — authenticated, verified, profile complete
  // ---------------------------------------------------------------------------

  group('onboarding completed, authenticated and verified, profile complete',
      () {
    setUp(() {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: true);
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'password';
      isProfileComplete = true;
    });

    testWidgets('navigating to /dashboard is allowed with no redirect',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });

    testWidgets('navigating to /login redirects to /dashboard',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/login');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });

    testWidgets('navigating to /onboarding redirects to /dashboard',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/onboarding');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });

    testWidgets('navigating to /splash redirects to /dashboard',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/splash');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });

    testWidgets('navigating to /setup redirects to /dashboard',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/setup');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-onboarding — SSO user
  // ---------------------------------------------------------------------------

  group('onboarding completed, authenticated SSO user', () {
    setUp(() {
      onboardingNotifier =
          _TestOnboardingFlagNotifier(hasCompleted: true);
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'google.com';
      isProfileComplete = true;
    });

    testWidgets(
        'Google user is allowed to /dashboard regardless of emailVerified',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/dashboard');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
    });
  });
}
