/// Application router with auth-aware redirect guards.
///
/// Uses [FirebaseAuthRepository] to check authentication state. All Firebase
/// interaction goes through the repository — no direct Firebase calls here.
///
/// The redirect guard evaluates four states in priority order:
///   1. Onboarding not completed → `/onboarding`
///   2. Unauthenticated → `/login`
///   3. Email/password user with unverified email → `/verify-email`
///   4. Authenticated and verified (or SSO) → `/home`
library;

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/storage_keys.dart';
import '../core/widgets/splash_screen.dart';
import '../features/auth/models/auth_user.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/phone_auth/screens/otp_screen.dart';
import '../features/phone_auth/screens/phone_input_screen.dart';
import '../features/explore/presentation/user_detail_screen.dart';
import '../features/shell/screens/explore_screen.dart';
import '../features/shell/screens/home_screen.dart';
import '../features/shell/screens/profile_screen.dart';
import '../features/shell/screens/shell_screen.dart';

// ---------------------------------------------------------------------------
// Onboarding flag notifier
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] that reads the `hasCompletedOnboarding` flag from
/// [SharedPreferences] on initialization.
///
/// The router's redirect guard checks [hasCompleted] to decide whether to
/// show the onboarding screen. While the flag is loading, [isLoading] is
/// `true` and the guard holds the user on the splash screen.
///
/// Public so that [OnboardingNotifier] (Riverpod) can call [markCompleted]
/// after persisting the flag — this triggers a router re-evaluation.
class OnboardingFlagNotifier extends ChangeNotifier {
  OnboardingFlagNotifier() {
    _readFlag();
  }

  bool _isLoading = true;
  bool _hasCompleted = false;

  /// Whether the flag has been read from SharedPreferences.
  bool get isLoading => _isLoading;

  /// Whether the user has completed or skipped onboarding.
  bool get hasCompleted => _hasCompleted;

  Future<void> _readFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompleted =
        prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  /// Marks onboarding as completed and notifies listeners (triggers router
  /// re-evaluation). Called by the Riverpod notifier after persisting the
  /// flag to SharedPreferences.
  void markCompleted() {
    _hasCompleted = true;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Auth change notifier
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] backed by the repository's [authStateChanges] stream.
///
/// GoRouter accepts a [refreshListenable] to re-evaluate redirects whenever
/// the auth state changes. Tracks [isLoading] so the redirect guard can avoid
/// redirecting before the auth state is known on cold start.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream<AuthUser?> stream) {
    _subscription = stream.listen((_) {
      if (_isLoading) _isLoading = false;
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthUser?> _subscription;
  bool _isLoading = true;

  /// Whether the initial auth state has been determined.
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// The onboarding flag notifier — public so the Riverpod
/// [OnboardingNotifier] can call [markCompleted] after persisting.
final onboardingFlag = OnboardingFlagNotifier();

/// Transition builder that returns the child unmodified — used by shell tab
/// routes so that switching bottom-nav tabs is instant with no animation.
Widget _noTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    child;

/// Creates the application router using the given [authRepository].
///
/// This ensures the router and Riverpod share the same [AuthRepository]
/// instance, avoiding stale-state bugs (e.g. email-verified polling).
GoRouter createRouter(AuthRepository authRepository) {
  final authNotifier =
      _AuthChangeNotifier(authRepository.authStateChanges);

  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  final refreshNotifier = Listenable.merge([authNotifier, onboardingFlag]);

  return GoRouter(
  initialLocation: '/splash',
  observers: [analyticsObserver],
  refreshListenable: refreshNotifier,
  onException: (context, state, router) {
    // Malformed or unrecognised deep link URLs — route based on auth state.
    if (!onboardingFlag.hasCompleted) {
      router.go('/onboarding');
      return;
    }
    final user = authRepository.currentUser;
    if (user == null) {
      router.go('/login');
    } else if (user.email.isNotEmpty &&
        authRepository.currentSignInProvider == 'password' &&
        !user.emailVerified) {
      router.go('/verify-email');
    } else {
      router.go('/home');
    }
  },
  redirect: (context, state) {
    final location = state.matchedLocation;
    final isAuthRoute = location == '/login' ||
        location == '/signup' ||
        location == '/forgot-password' ||
        location == '/phone-input' ||
        location == '/otp';
    final isSplash = location == '/splash';
    final isVerifyEmail = location == '/verify-email';
    final isOnboarding = location == '/onboarding';

    // -----------------------------------------------------------------------
    // 1. Onboarding flag still loading — hold on splash. No flash.
    // -----------------------------------------------------------------------
    if (onboardingFlag.isLoading) return isSplash ? null : '/splash';

    // -----------------------------------------------------------------------
    // 2. Onboarding not completed — redirect to /onboarding.
    // -----------------------------------------------------------------------
    if (!onboardingFlag.hasCompleted) {
      return isOnboarding ? null : '/onboarding';
    }

    // -----------------------------------------------------------------------
    // 3. Auth state not yet determined — hold on splash.
    // -----------------------------------------------------------------------
    if (authNotifier.isLoading) return isSplash ? null : '/splash';

    final user = authRepository.currentUser;

    // -----------------------------------------------------------------------
    // 4. Unauthenticated — redirect to login.
    // -----------------------------------------------------------------------
    if (user == null && !isAuthRoute) return '/login';

    if (user != null) {
      // Email/password user whose email is not yet verified.
      // Phone auth users (empty email) and SSO users bypass this check.
      final needsVerification = user.email.isNotEmpty &&
          authRepository.currentSignInProvider == 'password' &&
              !user.emailVerified;

      // -------------------------------------------------------------------
      // 5. Unverified email/password user — redirect to verification.
      // -------------------------------------------------------------------
      if (needsVerification && !isVerifyEmail) return '/verify-email';

      // -------------------------------------------------------------------
      // 6. Verified (or SSO) user on auth/splash/verify/onboarding → home.
      // -------------------------------------------------------------------
      if (!needsVerification &&
          (isAuthRoute || isSplash || isVerifyEmail || isOnboarding)) {
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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/phone-input',
      builder: (context, state) => const PhoneInputScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra! as Map<String, String>;
        return OtpScreen(
          verificationId: extra['verificationId']!,
          phoneNumber: extra['phoneNumber']!,
        );
      },
    ),

    // -----------------------------------------------------------------------
    // Navigation shell — bottom nav & side drawer
    // -----------------------------------------------------------------------
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: HomeScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: ExploreScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          routes: [
            GoRoute(
              path: ':userId',
              builder: (context, state) => UserDetailScreen(
                userId: state.pathParameters['userId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: ProfileScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
      ],
    ),
  ],
);
}
