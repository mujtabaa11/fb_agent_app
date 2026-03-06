/// Tests for the auth-aware redirect guard logic.
///
/// The production router in `lib/routing/router.dart` uses module-level globals
/// for the [AuthRepository] and refresh notifier, so we cannot inject
/// dependencies into it directly. Instead, we extract the redirect logic into
/// a test-local [GoRouter] that uses [FakeAuthRepository] and a controllable
/// loading flag, replicating the same guard conditions.
///
/// Tests verify the redirect path, NOT rendered widget content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/mock_providers.dart';

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

void main() {
  late FakeAuthRepository fakeAuth;
  late _TestAuthChangeNotifier refreshNotifier;

  /// Builds a [GoRouter] with the same redirect logic as production, but
  /// backed by [fakeAuth] and [refreshNotifier] for test control.
  ///
  /// Routes use simple [Scaffold] widgets with a [Text] label — we test the
  /// redirect path, not rendered content.
  GoRouter buildTestRouter({String initialLocation = '/splash'}) {
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

        if (refreshNotifier.isLoading) return null;

        final user = fakeAuth.currentUser;

        if (user == null && !isAuthRoute) return '/login';

        if (user != null) {
          final needsVerification =
              fakeAuth.currentSignInProvider == 'password' &&
                  !user.emailVerified;

          if (needsVerification && !isVerifyEmail) return '/verify-email';

          if (!needsVerification &&
              (isAuthRoute || isSplash || isVerifyEmail)) {
            return '/home';
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
        ShellRoute(
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  const Scaffold(body: Text('home')),
            ),
            GoRoute(
              path: '/explore',
              builder: (context, state) =>
                  const Scaffold(body: Text('explore')),
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
    refreshNotifier = _TestAuthChangeNotifier();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  // ---------------------------------------------------------------------------
  // Unauthenticated guards
  // ---------------------------------------------------------------------------

  group('unauthenticated user', () {
    testWidgets('navigating to /home redirects to /login', (tester) async {
      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/login',
      );
    });

    testWidgets('navigating to /explore redirects to /login', (tester) async {
      final router = buildTestRouter(initialLocation: '/explore');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/login',
      );
    });

    testWidgets('navigating to /profile redirects to /login', (tester) async {
      final router = buildTestRouter(initialLocation: '/profile');
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
  // Authenticated guards
  // ---------------------------------------------------------------------------

  group('authenticated user', () {
    setUp(() {
      fakeAuth.setUser(createTestAuthUser());
    });

    testWidgets('navigating to /home is allowed with no redirect',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets('navigating to /login redirects to /home', (tester) async {
      final router = buildTestRouter(initialLocation: '/login');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets('navigating to /signup redirects to /home', (tester) async {
      final router = buildTestRouter(initialLocation: '/signup');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets('navigating to /forgot-password redirects to /home',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/forgot-password');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets('navigating to /splash redirects to /home', (tester) async {
      final router = buildTestRouter(initialLocation: '/splash');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets('navigating to /explore is allowed with no redirect',
        (tester) async {
      final router = buildTestRouter(initialLocation: '/explore');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/explore',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  group('loading state', () {
    testWidgets('while auth state is loading, no redirect occurs',
        (tester) async {
      refreshNotifier = _TestAuthChangeNotifier(isLoading: true);
      final router = buildTestRouter(initialLocation: '/splash');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/splash',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Email verification guard
  // ---------------------------------------------------------------------------

  group('email verification guard', () {
    testWidgets(
        'authenticated email/password user with emailVerified false redirects to /verify-email',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'password';

      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/verify-email',
      );
    });

    testWidgets(
        'authenticated email/password user with emailVerified true is allowed to /home',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'password';

      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets(
        'authenticated Google user is allowed to /home regardless of emailVerified',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'google.com';

      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets(
        'authenticated Apple user is allowed to /home regardless of emailVerified',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'apple.com';

      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets(
        'unverified email/password user navigating to /profile redirects to /verify-email',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'password';

      final router = buildTestRouter(initialLocation: '/profile');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/verify-email',
      );
    });

    testWidgets(
        'verified email/password user on /verify-email redirects to /home',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'password';

      final router = buildTestRouter(initialLocation: '/verify-email');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Phone auth user guard
  // ---------------------------------------------------------------------------

  group('phone auth user', () {
    testWidgets(
        'phone-authenticated user is allowed to /home without email verification',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(
        uid: 'phone-uid',
        email: '',
        emailVerified: false,
      ));
      fakeAuth.fakeProvider = 'phone';

      final router = buildTestRouter(initialLocation: '/home');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });

    testWidgets(
        'phone-authenticated user on /login redirects to /home',
        (tester) async {
      fakeAuth.setUser(createTestAuthUser(
        uid: 'phone-uid',
        email: '',
        emailVerified: false,
      ));
      fakeAuth.fakeProvider = 'phone';

      final router = buildTestRouter(initialLocation: '/login');
      await pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        '/home',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Post-login deep link redirect
  // ---------------------------------------------------------------------------

  // TODO(US-54): Post-login redirect (deep link → login → forward to original
  // route after auth) is not implemented in the current router. The redirect
  // guard does not capture the original intended destination before redirecting
  // to /login. When this feature is added, test that navigating to e.g.
  // /profile while unauthenticated → login → authenticate → arrives at
  // /profile (not /home).
}
