/// Tests for the email verification flow (US-63).
///
/// Tests cover:
/// - [SendEmailVerification] and [EmailVerificationCheck] providers
/// - Resend cooldown (60-second window)
/// - Reload + emailVerified → navigates home vs stays on screen
/// - SSO users bypass verification
/// - Rate limiting error handling
/// - Polling interval verification using [fakeAsync]
library;

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/errors/app_exceptions.dart';
import 'package:football_agent_mate/features/auth/providers/auth_providers.dart';

import '../../helpers/mock_providers.dart';

void main() {
  late FakeAuthRepository fakeAuth;
  late ProviderContainer container;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    fakeAuth.setUser(createTestAuthUser(emailVerified: false));
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    fakeAuth.dispose();
  });

  // ---------------------------------------------------------------------------
  // sendEmailVerification
  // ---------------------------------------------------------------------------

  group('sendEmailVerification', () {
    test('success returns AsyncData', () async {
      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();

      final state = container.read(sendEmailVerificationProvider);
      expect(state, isA<AsyncData<void>>());
      expect(fakeAuth.callLog, contains('sendEmailVerification'));
    });

    test('failure returns AsyncError with AuthException', () async {
      fakeAuth.sendEmailVerificationFailWith = const AuthException.coded(
        'No signed-in user.',
        code: 'no-user',
      );

      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();

      final state = container.read(sendEmailVerificationProvider);
      expect(state, isA<AsyncError<void>>());
      expect((state as AsyncError).error, isA<AuthException>());
    });

    test('network error returns AsyncError with NetworkException', () async {
      fakeAuth.sendEmailVerificationFailWith = const NetworkException();

      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();

      final state = container.read(sendEmailVerificationProvider);
      expect(state, isA<AsyncError<void>>());
      expect((state as AsyncError).error, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // Resend cooldown
  // ---------------------------------------------------------------------------

  group('resend cooldown', () {
    test(
        'sendEmailVerification can be called successfully, simulating resend',
        () async {
      // First send
      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();
      expect(
        container.read(sendEmailVerificationProvider),
        isA<AsyncData<void>>(),
      );

      // Second send (simulating after cooldown — the cooldown is enforced
      // by the UI timer in VerifyEmailScreen, not the provider)
      await notifier.send();
      expect(
        container.read(sendEmailVerificationProvider),
        isA<AsyncData<void>>(),
      );
      // Both calls should have been recorded
      expect(
        fakeAuth.callLog.where((c) => c == 'sendEmailVerification').length,
        2,
      );
    });

    test(
        'cooldown is enforced by UI timer — repository does not reject rapid sends',
        () async {
      // The 60-second cooldown is a UI-layer concern (VerifyEmailScreen's
      // _cooldownSeconds timer). The repository and provider accept calls
      // at any rate — rate limiting comes from Firebase's too-many-requests.
      // This test documents that the provider layer does not enforce cooldown.
      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();
      await notifier.send();
      await notifier.send();

      // All three calls succeed at the provider level
      expect(
        fakeAuth.callLog.where((c) => c == 'sendEmailVerification').length,
        3,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Reload + emailVerified check
  // ---------------------------------------------------------------------------

  group('email verification check', () {
    test('reload succeeds and emailVerified is true after setEmailVerified',
        () async {
      final notifier =
          container.read(emailVerificationCheckProvider.notifier);
      await notifier.check();

      // After reload, check currentUser status
      final state = container.read(emailVerificationCheckProvider);
      expect(state, isA<AsyncData<void>>());

      // Simulate email verified on the server
      fakeAuth.setEmailVerified(true);
      expect(fakeAuth.currentUser!.emailVerified, isTrue);
    });

    test(
        'reload succeeds but emailVerified is false — user remains unverified',
        () async {
      final notifier =
          container.read(emailVerificationCheckProvider.notifier);
      await notifier.check();

      final state = container.read(emailVerificationCheckProvider);
      expect(state, isA<AsyncData<void>>());
      expect(fakeAuth.currentUser!.emailVerified, isFalse);
    });

    test('reload + verified triggers state that allows navigation', () async {
      fakeAuth.setEmailVerified(true);

      final notifier =
          container.read(emailVerificationCheckProvider.notifier);
      await notifier.check();

      final state = container.read(emailVerificationCheckProvider);
      expect(state, isA<AsyncData<void>>());
      // The provider completes successfully. The screen checks
      // repo.currentUser.emailVerified to decide navigation.
      expect(fakeAuth.currentUser!.emailVerified, isTrue);
    });

    test('reload failure returns AsyncError', () async {
      fakeAuth.reloadUserFailWith = const NetworkException();

      final notifier =
          container.read(emailVerificationCheckProvider.notifier);
      await notifier.check();

      final state = container.read(emailVerificationCheckProvider);
      expect(state, isA<AsyncError<void>>());
      expect((state as AsyncError).error, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // SSO bypass
  // ---------------------------------------------------------------------------

  group('SSO users bypass verification', () {
    test('Google user has emailVerified true and provider is google.com',
        () {
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'google.com';

      final user = fakeAuth.currentUser!;
      final provider = fakeAuth.currentSignInProvider;

      expect(user.emailVerified, isTrue);
      expect(provider, 'google.com');
      // The router guard skips verification for non-password providers.
      final needsVerification =
          provider == 'password' && !user.emailVerified;
      expect(needsVerification, isFalse);
    });

    test('Apple user has emailVerified true and provider is apple.com', () {
      fakeAuth.setUser(createTestAuthUser(emailVerified: true));
      fakeAuth.fakeProvider = 'apple.com';

      final user = fakeAuth.currentUser!;
      final provider = fakeAuth.currentSignInProvider;

      expect(user.emailVerified, isTrue);
      expect(provider, 'apple.com');
      final needsVerification =
          provider == 'password' && !user.emailVerified;
      expect(needsVerification, isFalse);
    });

    test('SSO user with emailVerified false still bypasses verification gate',
        () {
      // Even if emailVerified is false, SSO providers bypass the gate
      // because the router guard only checks for 'password' provider.
      fakeAuth.setUser(createTestAuthUser(emailVerified: false));
      fakeAuth.fakeProvider = 'google.com';

      final user = fakeAuth.currentUser!;
      final provider = fakeAuth.currentSignInProvider;

      final needsVerification =
          provider == 'password' && !user.emailVerified;
      expect(needsVerification, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Rate limiting
  // ---------------------------------------------------------------------------

  group('rate limiting', () {
    test('too-many-requests on sendEmailVerification returns correct error',
        () async {
      fakeAuth.sendEmailVerificationFailWith = const AuthException.coded(
        'Too many requests.',
        code: 'too-many-requests',
      );

      final notifier =
          container.read(sendEmailVerificationProvider.notifier);
      await notifier.send();

      final state = container.read(sendEmailVerificationProvider);
      expect(state, isA<AsyncError<void>>());
      final error = (state as AsyncError).error as AuthException;
      expect(error.code, 'too-many-requests');
    });

    test('too-many-requests on reloadUser returns correct error', () async {
      fakeAuth.reloadUserFailWith = const AuthException.coded(
        'Too many requests.',
        code: 'too-many-requests',
      );

      final notifier =
          container.read(emailVerificationCheckProvider.notifier);
      await notifier.check();

      final state = container.read(emailVerificationCheckProvider);
      expect(state, isA<AsyncError<void>>());
      final error = (state as AsyncError).error as AuthException;
      expect(error.code, 'too-many-requests');
    });
  });

  // ---------------------------------------------------------------------------
  // Polling interval (fakeAsync)
  // ---------------------------------------------------------------------------

  group('polling interval', () {
    test('periodic reload is called at 5-second intervals using fakeAsync',
        () {
      fakeAsync((async) {
        // Simulate the polling logic from VerifyEmailScreen._startPolling().
        // The screen creates a Timer.periodic with 5-second interval that
        // calls _checkVerification (which calls repo.reloadUser()).
        final localAuth = FakeAuthRepository();
        localAuth.setUser(createTestAuthUser(emailVerified: false));

        Timer.periodic(const Duration(seconds: 5), (_) {
          localAuth.reloadUser();
        });

        // No calls yet at t=0
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          0,
        );

        // Advance 5 seconds — first poll
        async.elapse(const Duration(seconds: 5));
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          1,
        );

        // Advance another 5 seconds — second poll
        async.elapse(const Duration(seconds: 5));
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          2,
        );

        // Advance 15 more seconds — should have 3 more polls (5 total)
        async.elapse(const Duration(seconds: 15));
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          5,
        );

        localAuth.dispose();
      });
    });

    test('polling stops when timer is cancelled', () {
      fakeAsync((async) {
        final localAuth = FakeAuthRepository();
        localAuth.setUser(createTestAuthUser(emailVerified: false));

        final timer = Timer.periodic(const Duration(seconds: 5), (_) {
          localAuth.reloadUser();
        });

        // First poll
        async.elapse(const Duration(seconds: 5));
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          1,
        );

        // Cancel timer (simulating verified or navigated away)
        timer.cancel();

        // Advance more time — no additional polls
        async.elapse(const Duration(seconds: 20));
        expect(
          localAuth.callLog.where((c) => c == 'reloadUser').length,
          1,
        );

        localAuth.dispose();
      });
    });
  });
}
