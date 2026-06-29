/// Manual fakes for unit and widget testing.
///
/// This file provides lightweight fake implementations of the app's abstract
/// service interfaces. These are preferred over mockito-generated mocks for
/// most tests because:
///   - The interfaces are small and stable.
///   - Manual fakes are deterministic with no code-gen step.
///   - The codebase already ships NoOp implementations for Firebase services.
///
/// For tests that need fine-grained call verification (call counts, argument
/// capture), use `@GenerateMocks` from mockito instead. See README.md in this
/// directory for guidance.
///
/// For Firestore-specific tests, use `fake_cloud_firestore` directly —
/// see [FakeFirebaseFirestore] in the `fake_cloud_firestore` package.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:football_agent_mate/core/data/base_repository.dart';
import 'package:football_agent_mate/core/data/paginated_result.dart';
import 'package:football_agent_mate/core/data/query_options.dart';
import 'package:football_agent_mate/core/data/result.dart';
import 'package:football_agent_mate/core/errors/app_exceptions.dart';
import 'package:football_agent_mate/core/services/analytics_service.dart';
import 'package:football_agent_mate/core/services/app_check_service.dart';
import 'package:football_agent_mate/core/services/connectivity_service.dart';
import 'package:football_agent_mate/core/services/crashlytics_service.dart';
import 'package:football_agent_mate/core/services/notification_service.dart';
import 'package:football_agent_mate/core/services/remote_config_service.dart';
import 'package:football_agent_mate/core/storage/base_storage_service.dart';
import 'package:football_agent_mate/core/storage/storage_service.dart';
import 'package:football_agent_mate/features/auth/models/auth_user.dart';
import 'package:football_agent_mate/features/auth/repositories/auth_repository.dart';
import 'package:football_agent_mate/features/biometric/services/biometric_service.dart';
import 'package:football_agent_mate/features/profile/data/user_profile_model.dart';

// ---------------------------------------------------------------------------
// BaseRepository<UserProfileModel>
// ---------------------------------------------------------------------------

/// In-memory fake repository for [UserProfileModel].
///
/// Stores documents in a local map. All methods return [Success] by default.
/// Set [shouldFail] to `true` to make operations return [Failure] with a
/// [DocumentNotFoundException].
class FakeUserProfileRepository implements BaseRepository<UserProfileModel> {
  final Map<String, UserProfileModel> _store = {};

  /// When `true`, all operations return [Failure].
  bool shouldFail = false;

  /// The controller backing [watchStream]. Add events manually in tests.
  final StreamController<Result<UserProfileModel>> watchController =
      StreamController<Result<UserProfileModel>>.broadcast();

  @override
  Future<Result<UserProfileModel>> create(UserProfileModel model) async {
    if (shouldFail) {
      return const Failure(DocumentNotFoundException());
    }
    _store[model.id] = model;
    return Success(model);
  }

  @override
  Future<Result<UserProfileModel>> read(String id) async {
    if (shouldFail) {
      return const Failure(DocumentNotFoundException());
    }
    final model = _store[id];
    if (model == null) {
      return const Failure(DocumentNotFoundException());
    }
    return Success(model);
  }

  @override
  Future<Result<UserProfileModel>> update(
    String id,
    UserProfileModel model,
  ) async {
    if (shouldFail) {
      return const Failure(DocumentNotFoundException());
    }
    _store[id] = model;
    return Success(model);
  }

  @override
  Future<Result<void>> delete(String id) async {
    if (shouldFail) {
      return const Failure(DocumentNotFoundException());
    }
    _store.remove(id);
    return const Success(null);
  }

  @override
  Stream<Result<UserProfileModel>> watchStream(String id) =>
      watchController.stream;

  @override
  Future<Result<PaginatedResult<UserProfileModel>>> queryList(
    QueryOptions options,
  ) async {
    if (shouldFail) {
      return const Failure(DocumentNotFoundException());
    }
    final items = _store.values.toList();
    return Success(PaginatedResult(items: items, hasMore: false));
  }

  void dispose() {
    watchController.close();
  }
}

// ---------------------------------------------------------------------------
// StorageService (key-value)
// ---------------------------------------------------------------------------

/// In-memory fake for [StorageService] (replaces SecureStorage / Prefs).
class FakeStorageService implements StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _store[key];
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

// ---------------------------------------------------------------------------
// BaseStorageService (cloud file storage)
// ---------------------------------------------------------------------------

/// In-memory fake for [BaseStorageService] (replaces FirebaseStorageService).
class FakeBaseStorageService implements BaseStorageService {
  /// When non-null, all operations return [Failure] with this exception.
  AppException? failWith;

  /// The URL returned by [uploadFile] and [downloadUrl] on success.
  String fakeDownloadUrl = 'https://fake-storage.example.com/file.png';

  @override
  Future<Result<String>> uploadFile(
    String storagePath,
    Uint8List bytes, {
    void Function(double progress)? onProgress,
  }) async {
    if (failWith != null) return Failure(failWith!);
    onProgress?.call(0.5);
    onProgress?.call(1.0);
    return Success(fakeDownloadUrl);
  }

  @override
  Future<Result<String>> downloadUrl(String storagePath) async {
    if (failWith != null) return Failure(failWith!);
    return Success(fakeDownloadUrl);
  }

  @override
  Future<Result<void>> deleteFile(String storagePath) async {
    if (failWith != null) return Failure(failWith!);
    return const Success(null);
  }

  @override
  void cancelUpload() {}
}

// ---------------------------------------------------------------------------
// AuthRepository
// ---------------------------------------------------------------------------

/// In-memory fake for [AuthRepository].
///
/// Controls auth state via [setUser] and [clearUser]. All sign-in methods
/// return the current [_user] as a [Success] unless [failWith] is set.
class FakeAuthRepository implements AuthRepository {
  AuthUser? _user;

  /// When non-null, all operations return [Failure] with this exception.
  AppException? failWith;

  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  /// Set the current authenticated user and emit on [authStateChanges].
  void setUser(AuthUser user) {
    _user = user;
    _authStateController.add(user);
  }

  /// Clear the current authenticated user and emit `null`.
  void clearUser() {
    _user = null;
    _authStateController.add(null);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<Result<AuthUser>> signUpWithEmail(
    String email,
    String password,
  ) async {
    if (failWith != null) return Failure(failWith!);
    final user = AuthUser(uid: 'fake-uid', email: email, emailVerified: false);
    setUser(user);
    return Success(user);
  }

  @override
  Future<Result<AuthUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    callLog.add('signInWithEmail');
    final error = signInWithEmailFailWith ?? failWith;
    if (error != null) return Failure(error);
    final user = _user ??
        AuthUser(uid: 'fake-uid', email: email, emailVerified: true);
    setUser(user);
    return Success(user);
  }

  @override
  Future<Result<AuthUser?>> signInWithGoogle() async {
    callLog.add('signInWithGoogle');
    final error = signInWithGoogleFailWith ?? failWith;
    if (error != null) return Failure(error);
    final user = _user ??
        const AuthUser(
          uid: 'google-uid',
          email: 'google@example.com',
          emailVerified: true,
        );
    setUser(user);
    return Success(user);
  }

  @override
  Future<Result<AuthUser?>> signInWithApple() async {
    callLog.add('signInWithApple');
    final error = signInWithAppleFailWith ?? failWith;
    if (error != null) return Failure(error);
    final user = _user ??
        const AuthUser(
          uid: 'apple-uid',
          email: 'apple@example.com',
          emailVerified: true,
        );
    setUser(user);
    return Success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    if (failWith != null) return Failure(failWith!);
    clearUser();
    return const Success(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    if (failWith != null) return Failure(failWith!);
    return const Success(null);
  }

  /// Per-method failure overrides for testing individual method failures
  /// without affecting other methods. When set, these take precedence over
  /// the global [failWith] for the specific method.
  AppException? sendEmailVerificationFailWith;
  AppException? reloadUserFailWith;
  AppException? linkPendingCredentialFailWith;
  AppException? deleteAccountFailWith;
  AppException? signInWithEmailFailWith;
  AppException? signInWithGoogleFailWith;
  AppException? signInWithAppleFailWith;

  /// Tracks method calls in order for verification tests.
  final List<String> callLog = [];

  @override
  Future<Result<void>> sendEmailVerification() async {
    callLog.add('sendEmailVerification');
    final error = sendEmailVerificationFailWith ?? failWith;
    if (error != null) return Failure(error);
    return const Success(null);
  }

  @override
  Future<Result<void>> reloadUser() async {
    callLog.add('reloadUser');
    final error = reloadUserFailWith ?? failWith;
    if (error != null) return Failure(error);
    return const Success(null);
  }

  /// Test helper — updates the current user's emailVerified flag.
  void setEmailVerified(bool verified) {
    if (_user != null) {
      _user = AuthUser(
        uid: _user!.uid,
        email: _user!.email,
        emailVerified: verified,
        displayName: _user!.displayName,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Account linking
  // ---------------------------------------------------------------------------

  bool _hasPending = false;
  String? _pendingEmail;

  /// Test helper — sets pending link state as if an SSO conflict occurred.
  void setPendingLink(String email) {
    _hasPending = true;
    _pendingEmail = email;
  }

  @override
  bool get hasPendingLink => _hasPending;

  @override
  String? get pendingLinkEmail => _pendingEmail;

  @override
  void clearPendingLink() {
    _hasPending = false;
    _pendingEmail = null;
  }

  @override
  Future<Result<AuthUser>> linkPendingCredential() async {
    callLog.add('linkPendingCredential');
    final error = linkPendingCredentialFailWith ?? failWith;
    if (error != null) return Failure(error);
    if (!_hasPending) {
      return const Failure(AuthException('No pending credential to link.'));
    }
    final user = _user ?? const AuthUser(uid: 'linked-uid', email: 'linked@example.com', emailVerified: true);
    clearPendingLink();
    setUser(user);
    return Success(user);
  }

  // ---------------------------------------------------------------------------
  // Sign-in provider detection
  // ---------------------------------------------------------------------------

  String? fakeProvider = 'password';

  @override
  String? get currentSignInProvider => fakeProvider;

  // ---------------------------------------------------------------------------
  // Re-authentication
  // ---------------------------------------------------------------------------

  /// Per-method failure override for re-authentication.
  AppException? reauthFailWith;

  @override
  Future<Result<void>> reauthenticateWithEmail(
    String email,
    String password,
  ) async {
    callLog.add('reauthenticateWithEmail');
    final error = reauthFailWith ?? failWith;
    if (error != null) return Failure(error);
    return const Success(null);
  }

  @override
  Future<Result<void>> reauthenticateWithGoogle() async {
    callLog.add('reauthenticateWithGoogle');
    final error = reauthFailWith ?? failWith;
    if (error != null) return Failure(error);
    return const Success(null);
  }

  @override
  Future<Result<void>> reauthenticateWithApple() async {
    callLog.add('reauthenticateWithApple');
    final error = reauthFailWith ?? failWith;
    if (error != null) return Failure(error);
    return const Success(null);
  }

  // ---------------------------------------------------------------------------
  // Account deletion
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> deleteAccount() async {
    callLog.add('deleteAccount');
    final error = deleteAccountFailWith ?? failWith;
    if (error != null) return Failure(error);
    clearUser();
    return const Success(null);
  }

  // ---------------------------------------------------------------------------
  // Phone authentication
  // ---------------------------------------------------------------------------

  @override
  Future<Result<String>> verifyPhoneNumber(String phoneNumber) async {
    callLog.add('verifyPhoneNumber');
    if (failWith != null) return Failure(failWith!);
    return const Success('fake-verification-id');
  }

  @override
  Future<Result<AuthUser>> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    callLog.add('signInWithPhoneCredential');
    if (failWith != null) return Failure(failWith!);
    final user = AuthUser(
      uid: 'phone-uid',
      email: '',
      emailVerified: false,
      phoneNumber: '+1234567890',
    );
    setUser(user);
    return Success(user);
  }

  void dispose() {
    _authStateController.close();
  }
}

// ---------------------------------------------------------------------------
// Firebase services — use the existing NoOp implementations
// ---------------------------------------------------------------------------

/// Re-export the built-in no-op services for convenience in tests.
///
/// These are production-quality stubs that ship with the app. Tests can
/// import them from here or directly from the service files.
typedef FakeAnalyticsService = NoOpAnalyticsService;
typedef FakeCrashlyticsService = NoOpCrashlyticsService;
typedef FakeNotificationService = NoOpNotificationService;
typedef FakeRemoteConfigService = NoOpRemoteConfigService;

/// No-op fake for [AppCheckService].
class FakeAppCheckService implements AppCheckService {
  @override
  Future<void> activate() async {}
}

/// In-memory fake for [BiometricService] with controllable responses.
///
/// Defaults to not available (`isAvailable() → false`). Tests can set
/// [available] and [authenticateResult] to control behavior.
class FakeBiometricService implements BiometricService {
  /// Whether biometrics are available on the device.
  bool available = false;

  /// What [authenticate] and [authenticateWithPasscode] return.
  bool authenticateResult = false;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async =>
      authenticateResult;

  @override
  Future<bool> authenticateWithPasscode({
    required String localizedReason,
  }) async =>
      authenticateResult;
}

/// In-memory fake for [ConnectivityService] with controllable state.
///
/// Defaults to [ConnectivityStatus.online]. Tests can call [setStatus] to
/// push new values to the stream, or construct with a custom initial status.
///
/// **Note:** The default [FakeConnectivityService] is automatically injected
/// by [pumpApp] so that all existing widget tests have connectivity mocked
/// to online. To test offline widget behavior, explicitly override
/// [connectivityServiceProvider] with a [FakeConnectivityService] whose
/// initial status is [ConnectivityStatus.offline].
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({
    ConnectivityStatus initialStatus = ConnectivityStatus.online,
  }) : _currentStatus = initialStatus {
    _controller.add(initialStatus);
  }

  ConnectivityStatus _currentStatus;
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  /// Push a new connectivity status to all listeners.
  void setStatus(ConnectivityStatus status) {
    _currentStatus = status;
    _controller.add(status);
  }

  @override
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  @override
  Future<ConnectivityStatus> get currentStatus async => _currentStatus;

  void dispose() {
    _controller.close();
  }
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

/// Convenience factory for creating test [AuthUser] instances.
AuthUser createTestAuthUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  bool emailVerified = true,
  String? displayName = 'Test User',
}) {
  return AuthUser(
    uid: uid,
    email: email,
    emailVerified: emailVerified,
    displayName: displayName,
  );
}

/// Convenience factory for creating test [UserProfileModel] instances.
UserProfileModel createTestUserProfile({
  String id = 'test-uid',
  String displayName = 'Test User',
  String email = 'test@example.com',
  String? avatarUrl,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return UserProfileModel(
    id: id,
    displayName: displayName,
    email: email,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
