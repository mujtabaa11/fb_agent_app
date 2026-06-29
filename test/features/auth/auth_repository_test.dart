/// Tests for [FirebaseAuthRepository].
///
/// Mocks FirebaseAuth, GoogleSignIn, and the Apple sign-in provider at the
/// dependency injection boundary using mockito. Tests verify that the
/// repository correctly maps inputs and exceptions to [Result<T>] outputs.
///
/// Every [FirebaseAuthException] code that has an explicit case in the
/// repository has a corresponding test.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:football_agent_mate/core/data/result.dart';
import 'package:football_agent_mate/core/errors/app_exceptions.dart';
import 'package:football_agent_mate/features/auth/models/auth_user.dart';
import 'package:football_agent_mate/features/auth/repositories/auth_repository.dart';

@GenerateMocks([
  fb.FirebaseAuth,
  fb.UserCredential,
  fb.User,
  GoogleSignIn,
  GoogleSignInAccount,
])
import 'auth_repository_test.mocks.dart';

// FirebaseAuthException has a @protected constructor. This subclass exposes it
// for test use only.
class TestFirebaseAuthException extends fb.FirebaseAuthException {
  TestFirebaseAuthException({
    required super.code,
    super.message,
    super.email,
    super.credential,
  });
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late FirebaseAuthRepository repo;

  /// Stub that simulates a successful Apple sign-in returning valid tokens.
  Future<AuthorizationCredentialAppleID> successAppleSignIn({
    required List<AppleIDAuthorizationScopes> scopes,
  }) async {
    return const AuthorizationCredentialAppleID(
      authorizationCode: 'apple-auth-code',
      identityToken: 'apple-id-token',
      userIdentifier: 'apple-user-id',
      givenName: 'Apple',
      familyName: 'User',
      email: 'apple@example.com',
      state: null,
    );
  }

  void stubMockUser({
    String uid = 'test-uid',
    String email = 'test@example.com',
    bool emailVerified = false,
    String? displayName = 'Test User',
    String? phoneNumber,
  }) {
    when(mockUser.uid).thenReturn(uid);
    when(mockUser.email).thenReturn(email);
    when(mockUser.emailVerified).thenReturn(emailVerified);
    when(mockUser.displayName).thenReturn(displayName);
    when(mockUser.phoneNumber).thenReturn(phoneNumber);
    when(mockCredential.user).thenReturn(mockUser);
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockCredential = MockUserCredential();
    mockUser = MockUser();

    stubMockUser();

    repo = FirebaseAuthRepository(
      firebaseAuth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      appleSignInProvider: successAppleSignIn,
    );
  });

  // ---------------------------------------------------------------------------
  // Sign-up
  // ---------------------------------------------------------------------------

  group('signUpWithEmail', () {
    test('success returns Success<AuthUser> with correct user data', () async {
      when(mockAuth.createUserWithEmailAndPassword(
        email: 'a@b.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      final result = await repo.signUpWithEmail('a@b.com', 'password123');

      expect(result, isA<Success<AuthUser>>());
      final user = (result as Success<AuthUser>).value;
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('email-already-in-use returns Failure with AuthException and correct code',
        () async {
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      ));

      final result = await repo.signUpWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'email-already-in-use');
    });

    test('weak-password returns Failure with AuthException and correct code',
        () async {
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'weak-password',
        message: 'The password is too weak.',
      ));

      final result = await repo.signUpWithEmail('a@b.com', '123');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'weak-password');
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'network-request-failed',
      ));

      final result = await repo.signUpWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Something went wrong'));

      final result = await repo.signUpWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // Sign-in (email/password)
  // ---------------------------------------------------------------------------

  group('signInWithEmail', () {
    test('success returns Success<AuthUser>', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'a@b.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      final result = await repo.signInWithEmail('a@b.com', 'password123');

      expect(result, isA<Success<AuthUser>>());
      final user = (result as Success<AuthUser>).value;
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
    });

    test('wrong-password returns Failure with AuthException and correct code',
        () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid.',
      ));

      final result = await repo.signInWithEmail('a@b.com', 'wrong');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'wrong-password');
    });

    test('user-not-found returns Failure with AuthException and correct code',
        () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found.',
      ));

      final result = await repo.signInWithEmail('noone@b.com', 'password');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'user-not-found');
    });

    test('user-disabled returns Failure with AuthException and correct code',
        () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'user-disabled',
        message: 'This account has been disabled.',
      ));

      final result = await repo.signInWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'user-disabled');
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(TestFirebaseAuthException(
        code: 'network-request-failed',
      ));

      final result = await repo.signInWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Something went wrong'));

      final result = await repo.signInWithEmail('a@b.com', 'password123');

      expect(result, isA<Failure<AuthUser>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // Google SSO
  // ---------------------------------------------------------------------------

  group('signInWithGoogle', () {
    late MockGoogleSignInAccount mockGoogleAccount;

    setUp(() {
      mockGoogleAccount = MockGoogleSignInAccount();

      when(mockGoogleSignIn.initialize()).thenAnswer((_) async {});
      when(mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockGoogleAccount);
      when(mockGoogleAccount.authentication).thenReturn(
        const GoogleSignInAuthentication(idToken: 'google-id-token'),
      );
    });

    test('success returns Success<AuthUser>', () async {
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);

      final result = await repo.signInWithGoogle();

      expect(result, isA<Success<AuthUser?>>());
      final user = (result as Success<AuthUser?>).value;
      expect(user, isNotNull);
      expect(user!.uid, 'test-uid');
      expect(user.email, 'test@example.com');
    });

    test('user cancels picker returns Success(null)', () async {
      when(mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
        ),
      );

      final result = await repo.signInWithGoogle();

      expect(result, isA<Success<AuthUser?>>());
      expect((result as Success<AuthUser?>).value, isNull);
    });

    test(
        'account-exists-with-different-credential returns Failure with AccountLinkException, stores pending state',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Account exists.',
          email: 'conflict@example.com',
          credential: fb.GoogleAuthProvider.credential(idToken: 'pending-token'),
        ),
      );

      final result = await repo.signInWithGoogle();

      expect(result, isA<Failure<AuthUser?>>());
      final failure = result as Failure<AuthUser?>;
      expect(failure.exception, isA<AccountLinkException>());
      final linkException = failure.exception as AccountLinkException;
      expect(linkException.code, 'account-exists-with-different-credential');
      expect(linkException.email, 'conflict@example.com');
      expect(
        linkException.message,
        'An account already exists with a different sign-in method.',
      );
      expect(repo.hasPendingLink, isTrue);
      expect(repo.pendingLinkEmail, 'conflict@example.com');
    });

    test('non-cancel GoogleSignInException returns Failure with NetworkException',
        () async {
      when(mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'Something failed',
        ),
      );

      final result = await repo.signInWithGoogle();

      expect(result, isA<Failure<AuthUser?>>());
      final failure = result as Failure<AuthUser?>;
      expect(failure.exception, isA<NetworkException>());
      expect(failure.exception.message, 'Something failed');
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(code: 'network-request-failed'),
      );

      final result = await repo.signInWithGoogle();

      expect(result, isA<Failure<AuthUser?>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockGoogleSignIn.authenticate())
          .thenThrow(Exception('network error'));

      final result = await repo.signInWithGoogle();

      expect(result, isA<Failure<AuthUser?>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // Apple SSO
  // ---------------------------------------------------------------------------

  group('signInWithApple', () {
    test('success returns Success<AuthUser>', () async {
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockCredential);

      final result = await repo.signInWithApple();

      expect(result, isA<Success<AuthUser?>>());
      final user = (result as Success<AuthUser?>).value;
      expect(user, isNotNull);
      expect(user!.uid, 'test-uid');
      expect(user.email, 'test@example.com');
    });

    test('user cancels returns Success(null)', () async {
      repo = FirebaseAuthRepository(
        firebaseAuth: mockAuth,
        googleSignIn: mockGoogleSignIn,
        appleSignInProvider: ({required scopes}) async {
          throw const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.canceled,
            message: 'User cancelled',
          );
        },
      );

      final result = await repo.signInWithApple();

      expect(result, isA<Success<AuthUser?>>());
      expect((result as Success<AuthUser?>).value, isNull);
    });

    test(
        'account-exists-with-different-credential returns Failure with AccountLinkException, stores pending state',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Account exists.',
          email: 'conflict@example.com',
          credential: fb.OAuthProvider('apple.com').credential(idToken: 'pending-token'),
        ),
      );

      final result = await repo.signInWithApple();

      expect(result, isA<Failure<AuthUser?>>());
      final failure = result as Failure<AuthUser?>;
      expect(failure.exception, isA<AccountLinkException>());
      final linkException = failure.exception as AccountLinkException;
      expect(linkException.code, 'account-exists-with-different-credential');
      expect(linkException.email, 'conflict@example.com');
      expect(repo.hasPendingLink, isTrue);
      expect(repo.pendingLinkEmail, 'conflict@example.com');
    });

    test(
        'non-cancel SignInWithAppleAuthorizationException returns Failure with NetworkException',
        () async {
      repo = FirebaseAuthRepository(
        firebaseAuth: mockAuth,
        googleSignIn: mockGoogleSignIn,
        appleSignInProvider: ({required scopes}) async {
          throw const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.failed,
            message: 'Authorization failed',
          );
        },
      );

      final result = await repo.signInWithApple();

      expect(result, isA<Failure<AuthUser?>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(code: 'network-request-failed'),
      );

      final result = await repo.signInWithApple();

      expect(result, isA<Failure<AuthUser?>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      repo = FirebaseAuthRepository(
        firebaseAuth: mockAuth,
        googleSignIn: mockGoogleSignIn,
        appleSignInProvider: ({required scopes}) async {
          throw Exception('network error');
        },
      );

      final result = await repo.signInWithApple();

      expect(result, isA<Failure<AuthUser?>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  group('sendPasswordResetEmail', () {
    test('success returns Success<void>', () async {
      when(mockAuth.sendPasswordResetEmail(email: 'a@b.com'))
          .thenAnswer((_) async {});

      final result = await repo.sendPasswordResetEmail('a@b.com');

      expect(result, isA<Success<void>>());
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
          .thenThrow(TestFirebaseAuthException(
        code: 'network-request-failed',
      ));

      final result = await repo.sendPasswordResetEmail('a@b.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
          .thenThrow(Exception('no connection'));

      final result = await repo.sendPasswordResetEmail('a@b.com');

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('too-many-requests returns Failure with AuthException', () async {
      when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
          .thenThrow(TestFirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many requests.',
      ));

      final result = await repo.sendPasswordResetEmail('a@b.com');

      expect(result, isA<Failure<void>>());
      final failure = result as Failure<void>;
      expect(failure.exception, isA<AuthException>());
      expect((failure.exception as AuthException).code, 'too-many-requests');
    });

    test('user-not-found is silently swallowed and returns Success', () async {
      when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
          .thenThrow(TestFirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found.',
      ));

      final result = await repo.sendPasswordResetEmail('a@b.com');

      expect(result, isA<Success<void>>());
    });
  });

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  group('signOut', () {
    test('success returns Success<void>', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});

      final result = await repo.signOut();

      expect(result, isA<Success<void>>());
    });

    test('FirebaseAuthException returns Failure with AuthException', () async {
      when(mockAuth.signOut()).thenThrow(TestFirebaseAuthException(
        code: 'internal-error',
        message: 'Internal error.',
      ));

      final result = await repo.signOut();

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<AuthException>());
    });

    test('generic exception returns Failure with NetworkException', () async {
      when(mockAuth.signOut()).thenThrow(Exception('sign out failed'));

      final result = await repo.signOut();

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });

    test('network-request-failed returns Failure with NetworkException',
        () async {
      when(mockAuth.signOut()).thenThrow(TestFirebaseAuthException(
        code: 'network-request-failed',
      ));

      final result = await repo.signOut();

      expect(result, isA<Failure<void>>());
      expect((result as Failure).exception, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // authStateChanges
  // ---------------------------------------------------------------------------

  group('authStateChanges', () {
    test('maps Firebase User to AuthUser', () async {
      when(mockUser.uid).thenReturn('stream-uid');
      when(mockUser.email).thenReturn('stream@example.com');
      when(mockUser.displayName).thenReturn('Stream User');

      when(mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      final user = await repo.authStateChanges.first;

      expect(user, isNotNull);
      expect(user!.uid, 'stream-uid');
      expect(user.email, 'stream@example.com');
    });

    test('emits null when no user is signed in', () async {
      when(mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      final user = await repo.authStateChanges.first;

      expect(user, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // currentUser
  // ---------------------------------------------------------------------------

  group('currentUser', () {
    test('returns AuthUser when user is signed in', () {
      when(mockAuth.currentUser).thenReturn(mockUser);

      final user = repo.currentUser;

      expect(user, isNotNull);
      expect(user!.uid, 'test-uid');
    });

    test('returns null when no user is signed in', () {
      when(mockAuth.currentUser).thenReturn(null);

      final user = repo.currentUser;

      expect(user, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Account linking
  // ---------------------------------------------------------------------------

  group('linkPendingCredential', () {
    late MockGoogleSignInAccount mockGoogleAccount;

    setUp(() {
      mockGoogleAccount = MockGoogleSignInAccount();
      when(mockGoogleSignIn.initialize()).thenAnswer((_) async {});
      when(mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockGoogleAccount);
      when(mockGoogleAccount.authentication).thenReturn(
        const GoogleSignInAuthentication(idToken: 'google-id-token'),
      );
    });

    Future<void> triggerPendingLink() async {
      when(mockAuth.signInWithCredential(any)).thenThrow(
        TestFirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Account exists.',
          email: 'conflict@example.com',
          credential:
              fb.GoogleAuthProvider.credential(idToken: 'pending-token'),
        ),
      );
      await repo.signInWithGoogle();
    }

    test('success links credential and clears pending state', () async {
      await triggerPendingLink();
      expect(repo.hasPendingLink, isTrue);

      // Reset signInWithCredential to succeed for linkWithCredential
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.linkWithCredential(any))
          .thenAnswer((_) async => mockCredential);

      final result = await repo.linkPendingCredential();

      expect(result, isA<Success<AuthUser>>());
      expect(repo.hasPendingLink, isFalse);
      expect(repo.pendingLinkEmail, isNull);
    });

    test('returns Failure when no pending credential', () async {
      expect(repo.hasPendingLink, isFalse);

      final result = await repo.linkPendingCredential();

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect(failure.exception.message, 'No pending credential to link.');
    });

    test('returns Failure when no current user', () async {
      await triggerPendingLink();
      when(mockAuth.currentUser).thenReturn(null);

      final result = await repo.linkPendingCredential();

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect(failure.exception.message, 'No signed-in user to link to.');
    });

    test('maps FirebaseAuthException from linkWithCredential', () async {
      await triggerPendingLink();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.linkWithCredential(any)).thenThrow(
        TestFirebaseAuthException(
          code: 'provider-already-linked',
          message: 'Provider already linked.',
        ),
      );

      final result = await repo.linkPendingCredential();

      expect(result, isA<Failure<AuthUser>>());
      final failure = result as Failure<AuthUser>;
      expect(failure.exception, isA<AuthException>());
      expect(
        (failure.exception as AuthException).code,
        'provider-already-linked',
      );
    });

    test('clearPendingLink clears stored state', () async {
      await triggerPendingLink();
      expect(repo.hasPendingLink, isTrue);
      expect(repo.pendingLinkEmail, 'conflict@example.com');

      repo.clearPendingLink();

      expect(repo.hasPendingLink, isFalse);
      expect(repo.pendingLinkEmail, isNull);
    });
  });
}
