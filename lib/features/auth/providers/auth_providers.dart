/// Riverpod providers for authentication.
///
/// All providers in this file depend on [AuthRepository] — they never
/// reference Firebase directly. Repository methods return [Result<T>];
/// providers pattern-match on [Success]/[Failure] and surface errors via
/// Riverpod's [AsyncError] state.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../biometric/providers/biometric_preference_notifier.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Provides the [AuthRepository] singleton.
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return FirebaseAuthRepository(
    crashlyticsService: ref.watch(crashlyticsServiceProvider),
  );
}

/// Exposes the Firebase auth state as a stream of [AuthUser?].
@Riverpod(keepAlive: true)
Stream<AuthUser?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Manages sign-up state (loading / error / data).
@riverpod
class SignUp extends _$SignUp {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Manages sign-in state (loading / error / data).
@riverpod
class SignIn extends _$SignIn {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).signInWithEmail(email, password);
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Manages password reset state (loading / error / data).
@riverpod
class PasswordReset extends _$PasswordReset {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordResetEmail(email);
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Sends a verification email to the current user.
@riverpod
class SendEmailVerification extends _$SendEmailVerification {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> send() async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).sendEmailVerification();
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Reloads the current user and re-reads emailVerified status.
@riverpod
class EmailVerificationCheck extends _$EmailVerificationCheck {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> check() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).reloadUser();
    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Manages Google sign-in state (loading / error / data).
@riverpod
class GoogleSso extends _$GoogleSso {
  @override
  FutureOr<AuthUser?> build() {
    // Initial idle state.
    return null;
  }

  Future<AuthUser?> signInWithGoogle() async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    return switch (result) {
      Success(:final value) => () {
          state = AsyncData(value);
          return value;
        }(),
      Failure(:final exception) => () {
          if (exception is AccountLinkException) {
            ref.read(pendingLinkEmailProvider.notifier).set(exception.email);
          }
          state = AsyncError(exception, StackTrace.current);
          return null;
        }(),
    };
  }
}

/// Manages Apple sign-in state (loading / error / data).
@riverpod
class AppleSso extends _$AppleSso {
  @override
  FutureOr<AuthUser?> build() {
    // Initial idle state.
    return null;
  }

  Future<AuthUser?> signInWithApple() async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).signInWithApple();
    return switch (result) {
      Success(:final value) => () {
          state = AsyncData(value);
          return value;
        }(),
      Failure(:final exception) => () {
          if (exception is AccountLinkException) {
            ref.read(pendingLinkEmailProvider.notifier).set(exception.email);
          }
          state = AsyncError(exception, StackTrace.current);
          return null;
        }(),
    };
  }
}

/// Holds the email that triggered an account-link conflict.
///
/// Non-null value signals the UI to show the linking dialog.
@riverpod
class PendingLinkEmail extends _$PendingLinkEmail {
  @override
  String? build() => null;

  void set(String email) => state = email;
  void clear() => state = null;
}

/// Orchestrates the two-step re-authenticate-then-link flow.
@riverpod
class AccountLink extends _$AccountLink {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> reAuthAndLink(String email, String password) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final signInResult = await repo.signInWithEmail(email, password);
    state = switch (signInResult) {
      Success() => await _link(repo),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }

  Future<void> reAuthWithGoogleAndLink() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final signInResult = await repo.signInWithGoogle();
    state = switch (signInResult) {
      Success(:final value) when value != null => await _link(repo),
      Success() => const AsyncData(null), // user cancelled
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }

  Future<void> reAuthWithAppleAndLink() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final signInResult = await repo.signInWithApple();
    state = switch (signInResult) {
      Success(:final value) when value != null => await _link(repo),
      Success() => const AsyncData(null), // user cancelled
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }

  Future<AsyncValue<void>> _link(AuthRepository repo) async {
    final linkResult = await repo.linkPendingCredential();
    return switch (linkResult) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}

/// Orchestrates account deletion: re-authenticate → three-step cleanup.
@riverpod
class DeleteAccount extends _$DeleteAccount {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  /// Re-authenticates with email/password, then deletes the account.
  Future<void> reAuthWithEmailAndDelete(String email, String password) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final reAuthResult = await repo.reauthenticateWithEmail(email, password);
    state = switch (reAuthResult) {
      Success() => await _delete(repo),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }

  /// Re-authenticates with Google, then deletes the account.
  Future<void> reAuthWithGoogleAndDelete() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final reAuthResult = await repo.reauthenticateWithGoogle();
    state = switch (reAuthResult) {
      Success() => await _delete(repo),
      Failure(:final exception) => () {
          if (exception is CancelledException) {
            // User cancelled re-auth — return to idle, not error.
            return const AsyncData<void>(null);
          }
          return AsyncError<void>(exception, StackTrace.current);
        }(),
    };
  }

  /// Re-authenticates with Apple, then deletes the account.
  Future<void> reAuthWithAppleAndDelete() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final reAuthResult = await repo.reauthenticateWithApple();
    state = switch (reAuthResult) {
      Success() => await _delete(repo),
      Failure(:final exception) => () {
          if (exception is CancelledException) {
            return const AsyncData<void>(null);
          }
          return AsyncError<void>(exception, StackTrace.current);
        }(),
    };
  }

  Future<AsyncValue<void>> _delete(AuthRepository repo) async {
    // Clear biometric preference before account deletion. Uses the current
    // user's UID. Failure is non-fatal — matches the existing pattern where
    // storage/Firestore cleanup failures don't abort the deletion flow.
    final uid = repo.currentUser?.uid;
    if (uid != null) {
      await ref
          .read(biometricPreferenceNotifierProvider.notifier)
          .clearForUser(uid);
    }

    final deleteResult = await repo.deleteAccount();
    return switch (deleteResult) {
      Success() => const AsyncData(null),
      Failure(:final exception) => AsyncError(exception, StackTrace.current),
    };
  }
}
