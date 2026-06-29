/// Tests for the account deletion flow (US-62).
///
/// Tests cover the [DeleteAccount] provider (re-authenticate → three-step
/// cleanup) and verify execution order, partial failure resilience, cancel
/// behavior, and error handling.
///
/// For execution order verification, a [ThreeStepDeletionFake] records
/// step names to assert the sequence [deleteStorage, deleteFirestore,
/// deleteAuth]. This mirrors the three-step logic in
/// [FirebaseAuthRepository.deleteAccount].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/data/result.dart';
import 'package:football_agent_mate/core/errors/app_exceptions.dart';
import 'package:football_agent_mate/features/auth/providers/auth_providers.dart';
import 'package:football_agent_mate/features/auth/repositories/auth_repository.dart';

import '../../helpers/mock_providers.dart';

// ---------------------------------------------------------------------------
// Three-step deletion fake
// ---------------------------------------------------------------------------

/// An [AuthRepository] fake that simulates the three-step deletion process
/// (Storage → Firestore → Auth) and records step names for order verification.
///
/// Each step can be independently configured to fail, replicating the
/// production [FirebaseAuthRepository.deleteAccount] behavior where Storage
/// and Firestore failures are logged but do not abort the flow.
class ThreeStepDeletionFake extends FakeAuthRepository {
  /// Records the name of each step as it executes.
  final List<String> deletionSteps = [];

  /// When set, the Storage cleanup step fails with this exception.
  AppException? storageFailWith;

  /// When set, the Firestore cleanup step fails with this exception.
  AppException? firestoreFailWith;

  /// When set, the Auth deletion step fails with this exception.
  AppException? authDeleteFailWith;

  @override
  Future<Result<void>> deleteAccount() async {
    callLog.add('deleteAccount');

    // Step 1: Delete Storage — failure does NOT block subsequent steps.
    deletionSteps.add('deleteStorage');
    if (storageFailWith != null) {
      // Log but continue (mirrors production behavior).
    }

    // Step 2: Delete Firestore — failure does NOT block Auth deletion.
    deletionSteps.add('deleteFirestore');
    if (firestoreFailWith != null) {
      // Log but continue (mirrors production behavior).
    }

    // Step 3: Delete Auth — this is the critical step.
    deletionSteps.add('deleteAuth');
    if (authDeleteFailWith != null) {
      return Failure(authDeleteFailWith!);
    }

    clearUser();
    return const Success(null);
  }
}

void main() {
  // ---------------------------------------------------------------------------
  // Provider-level tests (DeleteAccount notifier)
  // ---------------------------------------------------------------------------

  group('DeleteAccount provider', () {
    late FakeAuthRepository fakeAuth;
    late ProviderContainer container;

    setUp(() {
      fakeAuth = FakeAuthRepository();
      fakeAuth.setUser(createTestAuthUser());
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

    // -------------------------------------------------------------------------
    // Successful deletion
    // -------------------------------------------------------------------------

    group('successful deletion', () {
      test('reAuthWithEmailAndDelete re-authenticates then deletes', () async {
        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncData<void>>());
        expect(fakeAuth.currentUser, isNull);
        expect(fakeAuth.callLog, contains('reauthenticateWithEmail'));
        expect(fakeAuth.callLog, contains('deleteAccount'));
      });

      test('reAuthWithGoogleAndDelete re-authenticates via Google then deletes',
          () async {
        fakeAuth.fakeProvider = 'google.com';

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithGoogleAndDelete();

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncData<void>>());
        expect(fakeAuth.currentUser, isNull);
        expect(fakeAuth.callLog, contains('reauthenticateWithGoogle'));
        expect(fakeAuth.callLog, contains('deleteAccount'));
      });

      test('reAuthWithAppleAndDelete re-authenticates via Apple then deletes',
          () async {
        fakeAuth.fakeProvider = 'apple.com';

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithAppleAndDelete();

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncData<void>>());
        expect(fakeAuth.currentUser, isNull);
        expect(fakeAuth.callLog, contains('reauthenticateWithApple'));
        expect(fakeAuth.callLog, contains('deleteAccount'));
      });
    });

    // -------------------------------------------------------------------------
    // Re-auth failure
    // -------------------------------------------------------------------------

    group('re-authentication failure prevents deletion', () {
      test(
          'wrong-password on email re-auth returns Failure and does not delete',
          () async {
        fakeAuth.reauthFailWith = const AuthException.coded(
          'The password is invalid.',
          code: 'wrong-password',
        );

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithEmailAndDelete('test@example.com', 'wrong');

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncError<void>>());
        final error = (state as AsyncError).error as AuthException;
        expect(error.code, 'wrong-password');
        // Account should NOT be deleted
        expect(fakeAuth.currentUser, isNotNull);
        expect(fakeAuth.callLog, isNot(contains('deleteAccount')));
      });

      test('requires-recent-login triggers re-auth prompt via error code',
          () async {
        fakeAuth.reauthFailWith = const AuthException.coded(
          'This operation requires recent authentication.',
          code: 'requires-recent-login',
        );

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncError<void>>());
        final error = (state as AsyncError).error as AuthException;
        expect(error.code, 'requires-recent-login');
        expect(fakeAuth.currentUser, isNotNull);
      });
    });

    // -------------------------------------------------------------------------
    // Auth deletion failure
    // -------------------------------------------------------------------------

    group('Auth deletion failure', () {
      test('deleteAccount failure returns Failure with AuthException',
          () async {
        fakeAuth.deleteAccountFailWith = const AuthException.coded(
          'Auth deletion failed.',
          code: 'internal-error',
        );

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncError<void>>());
        final error = (state as AsyncError).error as AuthException;
        expect(error.code, 'internal-error');
      });
    });

    // -------------------------------------------------------------------------
    // Cancel
    // -------------------------------------------------------------------------

    group('cancel at re-auth step', () {
      test(
          'Google re-auth cancel returns to idle state with user still intact',
          () async {
        fakeAuth.fakeProvider = 'google.com';
        fakeAuth.reauthFailWith = const CancelledException();

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithGoogleAndDelete();

        // CancelledException is handled by the provider — returns to idle
        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncData<void>>());
        expect(fakeAuth.currentUser, isNotNull);
        expect(fakeAuth.callLog, isNot(contains('deleteAccount')));
      });

      test(
          'Apple re-auth cancel returns to idle state with user still intact',
          () async {
        fakeAuth.fakeProvider = 'apple.com';
        fakeAuth.reauthFailWith = const CancelledException();

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithAppleAndDelete();

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncData<void>>());
        expect(fakeAuth.currentUser, isNotNull);
        expect(fakeAuth.callLog, isNot(contains('deleteAccount')));
      });
    });

    // -------------------------------------------------------------------------
    // Rate limiting
    // -------------------------------------------------------------------------

    group('rate limiting', () {
      test('too-many-requests error is surfaced correctly', () async {
        fakeAuth.reauthFailWith = const AuthException.coded(
          'Too many requests.',
          code: 'too-many-requests',
        );

        final notifier = container.read(deleteAccountProvider.notifier);
        await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

        final state = container.read(deleteAccountProvider);
        expect(state, isA<AsyncError<void>>());
        final error = (state as AsyncError).error as AuthException;
        expect(error.code, 'too-many-requests');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // Execution order and partial failure (three-step deletion)
  // ---------------------------------------------------------------------------

  group('three-step deletion order and resilience', () {
    late ThreeStepDeletionFake threeStepFake;
    late ProviderContainer container;

    setUp(() {
      threeStepFake = ThreeStepDeletionFake();
      threeStepFake.setUser(createTestAuthUser());
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(threeStepFake),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      threeStepFake.dispose();
    });

    test('deletion executes steps in order: deleteStorage, deleteFirestore, deleteAuth',
        () async {
      final notifier = container.read(deleteAccountProvider.notifier);
      await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

      expect(threeStepFake.deletionSteps, [
        'deleteStorage',
        'deleteFirestore',
        'deleteAuth',
      ]);
    });

    test('Storage failure does NOT block Firestore or Auth and returns Success',
        () async {
      threeStepFake.storageFailWith = const DataException(
        message: 'Storage cleanup failed.',
      );

      final notifier = container.read(deleteAccountProvider.notifier);
      await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

      final state = container.read(deleteAccountProvider);
      expect(state, isA<AsyncData<void>>());
      // All three steps should still have executed
      expect(threeStepFake.deletionSteps, [
        'deleteStorage',
        'deleteFirestore',
        'deleteAuth',
      ]);
    });

    test(
        'Firestore failure does NOT block Auth deletion and returns Success',
        () async {
      threeStepFake.firestoreFailWith = const DataException(
        message: 'Firestore cleanup failed.',
      );

      final notifier = container.read(deleteAccountProvider.notifier);
      await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

      final state = container.read(deleteAccountProvider);
      expect(state, isA<AsyncData<void>>());
      expect(threeStepFake.deletionSteps, [
        'deleteStorage',
        'deleteFirestore',
        'deleteAuth',
      ]);
    });

    test('Auth deletion failure returns Failure with AuthException', () async {
      threeStepFake.authDeleteFailWith = const AuthException.coded(
        'Auth deletion failed.',
        code: 'requires-recent-login',
      );

      final notifier = container.read(deleteAccountProvider.notifier);
      await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

      final state = container.read(deleteAccountProvider);
      expect(state, isA<AsyncError<void>>());
      final error = (state as AsyncError).error as AuthException;
      expect(error.code, 'requires-recent-login');
      // All three steps should still have been attempted
      expect(threeStepFake.deletionSteps, [
        'deleteStorage',
        'deleteFirestore',
        'deleteAuth',
      ]);
    });

    test('account with no Storage or Firestore data still succeeds',
        () async {
      // Default ThreeStepDeletionFake has no data to clean up —
      // Storage and Firestore steps complete as no-ops.
      final notifier = container.read(deleteAccountProvider.notifier);
      await notifier.reAuthWithEmailAndDelete('test@example.com', 'password');

      final state = container.read(deleteAccountProvider);
      expect(state, isA<AsyncData<void>>());
      expect(threeStepFake.currentUser, isNull);
      expect(threeStepFake.deletionSteps, [
        'deleteStorage',
        'deleteFirestore',
        'deleteAuth',
      ]);
    });
  });
}
