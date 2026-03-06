/// Authentication repository — the only layer that touches Firebase Auth.
///
/// All Firebase [FirebaseAuthException] errors are caught here and wrapped in
/// [Failure] with typed [AuthException] or [NetworkException] so that no raw
/// Firebase exceptions ever reach providers or UI.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/crashlytics_service.dart';
import '../models/auth_user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  Future<Result<AuthUser>> signUpWithEmail(String email, String password);
  Future<Result<AuthUser>> signInWithEmail(String email, String password);
  Future<Result<AuthUser?>> signInWithGoogle();
  Future<Result<AuthUser?>> signInWithApple();
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordResetEmail(String email);
  Future<Result<void>> sendEmailVerification();
  Future<Result<void>> reloadUser();
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  /// Links the pending SSO credential to the currently signed-in user.
  Future<Result<AuthUser>> linkPendingCredential();

  /// Whether a pending link credential is stored from a prior SSO attempt.
  bool get hasPendingLink;

  /// The email from the conflicting account, if any.
  String? get pendingLinkEmail;

  /// Clears any stored pending link state.
  void clearPendingLink();

  /// Returns the primary sign-in provider for the currently authenticated user.
  ///
  /// Returns `'password'`, `'google.com'`, `'apple.com'`, or `null` if
  /// no user is signed in.
  String? get currentSignInProvider;

  /// Re-authenticates the current user with the given [credential].
  ///
  /// Must be called before sensitive operations like account deletion.
  Future<Result<void>> reauthenticateWithEmail(String email, String password);

  /// Re-authenticates the current user via Google sign-in.
  Future<Result<void>> reauthenticateWithGoogle();

  /// Re-authenticates the current user via Apple sign-in.
  Future<Result<void>> reauthenticateWithApple();

  /// Deletes the current user's account in three steps:
  ///
  /// 1. Delete Cloud Storage files at `users/{uid}/`
  /// 2. Delete Firestore document at `users/{uid}`
  /// 3. Delete Firebase Auth record
  ///
  /// Storage and Firestore failures are logged via [CrashlyticsService] but
  /// do not abort the flow. Returns [Failure] only if the auth deletion
  /// itself fails.
  Future<Result<void>> deleteAccount();

  /// Initiates phone number verification by sending an SMS code.
  ///
  /// Wraps [FirebaseAuth.verifyPhoneNumber] using a [Completer] to bridge the
  /// callback-based API to a [Future]. Returns [Success] with the
  /// `verificationId` on [codeSent], or [Failure] on [verificationFailed].
  ///
  /// The [verificationCompleted] callback (Android auto-verify) automatically
  /// signs the user in without requiring manual OTP entry.
  Future<Result<String>> verifyPhoneNumber(String phoneNumber);

  /// Signs in with a phone auth credential constructed from [verificationId]
  /// and [smsCode].
  ///
  /// Returns [Success] with the [AuthUser] on success, or [Failure] with an
  /// [AuthException] whose code distinguishes `invalid-verification-code`
  /// from other errors.
  Future<Result<AuthUser>> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  );
}

/// Signature for the Apple sign-in credential request.
///
/// Extracted as a typedef so tests can inject a mock without depending on the
/// static [SignInWithApple.getAppleIDCredential] method.
typedef AppleSignInProvider = Future<AuthorizationCredentialAppleID> Function({
  required List<AppleIDAuthorizationScopes> scopes,
});

/// Firebase implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    AppleSignInProvider? appleSignInProvider,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    CrashlyticsService? crashlyticsService,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _appleSignIn = appleSignInProvider ?? _defaultAppleSignIn,
        _firestore = firestore,
        _storage = storage,
        _crashlytics = crashlyticsService;

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AppleSignInProvider _appleSignIn;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final CrashlyticsService? _crashlytics;

  /// Lazily resolved Firestore instance — only accessed during [deleteAccount].
  FirebaseFirestore get _firestoreInstance =>
      _firestore ?? FirebaseFirestore.instance;

  /// Lazily resolved Storage instance — only accessed during [deleteAccount].
  FirebaseStorage get _storageInstance =>
      _storage ?? FirebaseStorage.instance;

  // Pending account-link state — stored here so Firebase types stay in the
  // repository layer and never leak into providers or UI.
  fb.AuthCredential? _pendingCredential;
  String? _pendingEmail;

  static Future<AuthorizationCredentialAppleID> _defaultAppleSignIn({
    required List<AppleIDAuthorizationScopes> scopes,
  }) {
    return SignInWithApple.getAppleIDCredential(scopes: scopes);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AuthUser _mapUser(fb.User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
    );
  }

  Failure<T> _mapFirebaseAuthException<T>(fb.FirebaseAuthException e) {
    // Firebase error code → typed AuthException
    // email-already-in-use   → emailAlreadyInUseError
    // wrong-password          → wrongPasswordError
    // user-not-found          → wrongPasswordError  (do not reveal account existence)
    // weak-password           → weakPasswordError
    // too-many-requests       → tooManyRequestsError
    // network-request-failed  → noInternetError
    if (e.code == 'network-request-failed') {
      return Failure(const NetworkException());
    }
    return Failure(AuthException.coded(e.message ?? e.code, code: e.code));
  }

  // ---------------------------------------------------------------------------
  // AuthRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<Result<AuthUser>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(_mapUser(credential.user!));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(_mapUser(credential.user!));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // OAuth client IDs are project-specific and must be configured manually.
  // See README — "Google SSO Setup" section for instructions.
  @override
  Future<Result<AuthUser?>> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;

      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return Success(_mapUser(userCredential.user!));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return const Success(null);
      return Failure(NetworkException(e.description ?? e.toString()));
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _pendingCredential = e.credential;
        _pendingEmail = e.email;
        return Failure(AccountLinkException(email: e.email ?? ''));
      }
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // TODO(US-09): Before this will work, complete these manual steps:
  // 1. Enable 'Sign in with Apple' capability in your App ID in the Apple Developer portal
  //    at https://developer.apple.com/account/resources/identifiers/list
  // 2. Configure the Apple sign-in provider in Firebase Console:
  //    Authentication → Sign-in method → Apple
  //    You will need: Apple Services ID, Apple Team ID, Key ID, and private key (.p8 file)
  // See README — "Apple SSO Setup" section for step-by-step instructions.
  @override
  Future<Result<AuthUser?>> signInWithApple() async {
    try {
      final appleCredential = await _appleSignIn(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _auth.signInWithCredential(oauthCredential);
      return Success(_mapUser(userCredential.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return const Success(null);
      return Failure(NetworkException(e.toString()));
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _pendingCredential = e.credential;
        _pendingEmail = e.email;
        return Failure(AccountLinkException(email: e.email ?? ''));
      }
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // Always succeed silently for unrecognised emails — do not reveal account existence
  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return Failure(AuthException.coded(e.message ?? e.code, code: e.code));
      }
      if (e.code == 'network-request-failed') {
        return const Failure(NetworkException());
      }
      // All other FirebaseAuthException — swallow silently (user-not-found, etc.)
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    try {
      await user.sendEmailVerification();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    try {
      await user.reload();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  // Firebase Auth persists the session and refreshes tokens automatically.
  // This stream emits the current user on app start (null if unauthenticated)
  // and on every auth state change thereafter.
  @override
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  // ---------------------------------------------------------------------------
  // Account linking
  // ---------------------------------------------------------------------------

  @override
  bool get hasPendingLink => _pendingCredential != null;

  @override
  String? get pendingLinkEmail => _pendingEmail;

  @override
  void clearPendingLink() {
    _pendingCredential = null;
    _pendingEmail = null;
  }

  @override
  Future<Result<AuthUser>> linkPendingCredential() async {
    if (_pendingCredential == null) {
      return const Failure(AuthException('No pending credential to link.'));
    }
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(AuthException('No signed-in user to link to.'));
    }
    try {
      final userCredential =
          await currentUser.linkWithCredential(_pendingCredential!);
      clearPendingLink();
      return Success(_mapUser(userCredential.user!));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Sign-in provider detection
  // ---------------------------------------------------------------------------

  @override
  String? get currentSignInProvider {
    final user = _auth.currentUser;
    if (user == null) return null;
    // providerData lists all linked providers. Return the first non-Firebase
    // provider (password, google.com, apple.com).
    for (final info in user.providerData) {
      if (info.providerId != 'firebase') return info.providerId;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Re-authentication
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> reauthenticateWithEmail(
    String email,
    String password,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    try {
      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    try {
      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      await user.reauthenticateWithCredential(credential);
      return const Success(null);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Failure(CancelledException());
      }
      return Failure(NetworkException(e.description ?? e.toString()));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  @override
  Future<Result<void>> reauthenticateWithApple() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    try {
      final appleCredential = await _appleSignIn(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await user.reauthenticateWithCredential(oauthCredential);
      return const Success(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Failure(CancelledException());
      }
      return Failure(NetworkException(e.toString()));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Account deletion
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(AuthException('No signed-in user.'));
    }
    final uid = user.uid;

    // Step 1: Delete Cloud Storage files at users/{uid}/
    // Failure is logged but does not abort the flow.
    try {
      final listResult = await _storageInstance.ref('users/$uid').listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } on Exception catch (e, st) {
      if (kDebugMode) debugPrint('Storage cleanup failed: $e');
      _crashlytics?.recordError(e, st);
    }

    // Step 2: Delete Firestore document at users/{uid}
    // Failure is logged but does not abort the flow.
    try {
      await _firestoreInstance.collection('users').doc(uid).delete();
    } on Exception catch (e, st) {
      if (kDebugMode) debugPrint('Firestore cleanup failed: $e');
      _crashlytics?.recordError(e, st);
    }

    // Step 3: Delete Firebase Auth record — this is the critical step.
    try {
      await user.delete();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Phone authentication
  // ---------------------------------------------------------------------------

  @override
  Future<Result<String>> verifyPhoneNumber(String phoneNumber) async {
    final completer = Completer<Result<String>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // Android auto-verify — sign in automatically.
          try {
            await _auth.signInWithCredential(credential);
          } catch (_) {
            // Auto-sign-in failure is non-fatal — the user can still enter
            // the code manually on the OTP screen.
          }
          if (!completer.isCompleted) {
            // The codeSent callback may have already resolved the completer.
            // If not, resolve with a sentinel so callers know auto-verify
            // happened. The auth state stream will trigger navigation.
            completer.complete(const Success('auto-verified'));
          }
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete(_mapFirebaseAuthException(e));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(Success(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // The auto-retrieval timeout expired. The verificationId may have
          // changed — but the codeSent callback has already resolved the
          // completer, so this is a no-op for the Future.
        },
      );
    } on fb.FirebaseAuthException catch (e) {
      if (!completer.isCompleted) {
        completer.complete(_mapFirebaseAuthException(e));
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(Failure(NetworkException(e.toString())));
      }
    }

    return completer.future;
  }

  @override
  Future<Result<AuthUser>> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return Success(_mapUser(userCredential.user!));
    } on fb.FirebaseAuthException catch (e) {
      return _mapFirebaseAuthException(e);
    } catch (e) {
      return Failure(NetworkException(e.toString()));
    }
  }
}
