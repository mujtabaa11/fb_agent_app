/// Application router with auth-aware redirect guards.
///
/// Uses [FirebaseAuthRepository] to check authentication state. All Firebase
/// interaction goes through the repository — no direct Firebase calls here.
///
/// The redirect guard evaluates five states in priority order:
///   1. Onboarding not completed → `/onboarding`
///   2. Unauthenticated → `/login`
///   3. Email/password user with unverified email → `/verify-email`
///   4. Profile incomplete (or not yet loaded) → `/setup`
///   5. Authenticated, verified, and profile complete → `/dashboard`
library;

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/storage_keys.dart';
import '../core/widgets/splash_screen.dart';
import '../features/auth/models/auth_user.dart';
import '../features/auth/models/user_model.dart';
import '../features/auth/providers/agent_providers.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../features/dev_showcase/screens/component_showcase_screen.dart';
import '../features/market/screens/agent_public_profile_screen.dart';
import '../features/market/screens/create_post_screen.dart';
import '../features/market/screens/market_feed_screen.dart';
import '../features/market/screens/my_posts_screen.dart';
import '../features/market/screens/post_detail_screen.dart';
import '../features/messaging/screens/chat_screen.dart';
import '../features/messaging/screens/conversation_list_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/phone_auth/screens/otp_screen.dart';
import '../features/phone_auth/screens/phone_input_screen.dart';
import '../features/players/screens/add_player_screen.dart';
import '../features/players/screens/edit_player_screen.dart';
import '../features/players/screens/player_list_screen.dart';
import '../features/players/screens/player_profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/setup/screens/account_setup_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
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

// ---------------------------------------------------------------------------
// Agent profile change notifier
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] that bridges [currentAgentProvider] into GoRouter's
/// [refreshListenable] so the redirect guard re-evaluates whenever the
/// agent's Firestore profile (and its `isProfileComplete` flag) changes.
class _AgentChangeNotifier extends ChangeNotifier {
  _AgentChangeNotifier(ProviderContainer container) {
    _subscription = container.listen(
      currentAgentProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<UserModel?> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Transition builder that returns the child unmodified — used by shell tab
/// routes so that switching bottom-nav tabs is instant with no animation.
Widget _noTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    child;

/// Creates the application router using the given [authRepository] and
/// Riverpod [container].
///
/// Sharing the same [AuthRepository] instance as Riverpod avoids stale-state
/// bugs (e.g. email-verified polling). Sharing the same [ProviderContainer]
/// lets the redirect guard read [currentAgentProvider] directly.
GoRouter createRouter(AuthRepository authRepository, ProviderContainer container) {
  final authNotifier =
      _AuthChangeNotifier(authRepository.authStateChanges);

  final agentNotifier = _AgentChangeNotifier(container);

  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  final refreshNotifier =
      Listenable.merge([authNotifier, onboardingFlag, agentNotifier]);

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
      final agent = container.read(currentAgentProvider);
      if (agent == null || !agent.isProfileComplete) {
        router.go('/setup');
      } else {
        router.go('/dashboard');
      }
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
    final isSetup = location == '/setup';

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

      if (!needsVerification) {
        final agent = container.read(currentAgentProvider);
        final profileIncomplete = agent == null || !agent.isProfileComplete;

        // -----------------------------------------------------------------
        // 6. Profile incomplete (or not yet loaded) — redirect to setup.
        // -----------------------------------------------------------------
        if (profileIncomplete && !isSetup) return '/setup';

        // -----------------------------------------------------------------
        // 7. Profile complete but on setup/auth/splash/verify/onboarding
        //    — redirect to the dashboard.
        // -----------------------------------------------------------------
        if (!profileIncomplete &&
            (isAuthRoute || isSplash || isVerifyEmail || isOnboarding || isSetup)) {
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

    GoRoute(
      path: '/setup',
      builder: (context, state) => const AccountSetupScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),

    if (kDebugMode)
      GoRoute(
        path: '/dev/showcase',
        builder: (context, state) => const ComponentShowcaseScreen(),
      ),

    // -----------------------------------------------------------------------
    // Navigation shell — bottom nav & side drawer
    // -----------------------------------------------------------------------
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: DashboardScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
        GoRoute(
          path: '/players',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: PlayerListScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddPlayerScreen(),
            ),
            GoRoute(
              path: ':playerId',
              builder: (context, state) => PlayerProfileScreen(
                playerId: state.pathParameters['playerId']!,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => EditPlayerScreen(
                    playerId: state.pathParameters['playerId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/market',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: MarketFeedScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          routes: [
            GoRoute(
              path: 'post/create',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: 'post/:postId',
              builder: (context, state) => PostDetailScreen(
                postId: state.pathParameters['postId']!,
              ),
            ),
            GoRoute(
              path: 'my-posts',
              builder: (context, state) => const MyPostsScreen(),
            ),
            GoRoute(
              path: 'agent/:agentId',
              builder: (context, state) => AgentPublicProfileScreen(
                agentId: state.pathParameters['agentId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: ConversationListScreen(),
            transitionsBuilder: _noTransition,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          routes: [
            GoRoute(
              path: ':conversationId',
              builder: (context, state) => ChatScreen(
                conversationId: state.pathParameters['conversationId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
}
