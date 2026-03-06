// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'ec4d02416f7c3b0eef2c3312d16a48223a4dabf6';

/// Provides the [AuthRepository] singleton.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$authStateChangesHash() => r'e471e6d514821c591833c69a1f9d13ed56a3590e';

/// Exposes the Firebase auth state as a stream of [AuthUser?].
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = StreamProvider<AuthUser?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = StreamProviderRef<AuthUser?>;
String _$signUpHash() => r'84682ea05a8cb50b5b1fe7ef8db5b20305d5713f';

/// Manages sign-up state (loading / error / data).
///
/// Copied from [SignUp].
@ProviderFor(SignUp)
final signUpProvider = AutoDisposeAsyncNotifierProvider<SignUp, void>.internal(
  SignUp.new,
  name: r'signUpProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signUpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignUp = AutoDisposeAsyncNotifier<void>;
String _$signInHash() => r'0bb4f243bd39f9098456c1a48b382f5d87a1236b';

/// Manages sign-in state (loading / error / data).
///
/// Copied from [SignIn].
@ProviderFor(SignIn)
final signInProvider = AutoDisposeAsyncNotifierProvider<SignIn, void>.internal(
  SignIn.new,
  name: r'signInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignIn = AutoDisposeAsyncNotifier<void>;
String _$passwordResetHash() => r'c75d6bd438a775e476e9ef3d6a4e79c79ee8828f';

/// Manages password reset state (loading / error / data).
///
/// Copied from [PasswordReset].
@ProviderFor(PasswordReset)
final passwordResetProvider =
    AutoDisposeAsyncNotifierProvider<PasswordReset, void>.internal(
  PasswordReset.new,
  name: r'passwordResetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$passwordResetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PasswordReset = AutoDisposeAsyncNotifier<void>;
String _$sendEmailVerificationHash() =>
    r'594c6808a157c24bd73056e524ac7c8100c5c0ba';

/// Sends a verification email to the current user.
///
/// Copied from [SendEmailVerification].
@ProviderFor(SendEmailVerification)
final sendEmailVerificationProvider =
    AutoDisposeAsyncNotifierProvider<SendEmailVerification, void>.internal(
  SendEmailVerification.new,
  name: r'sendEmailVerificationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sendEmailVerificationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SendEmailVerification = AutoDisposeAsyncNotifier<void>;
String _$emailVerificationCheckHash() =>
    r'9fd941ae3c1f84522212f53a8c06472619408667';

/// Reloads the current user and re-reads emailVerified status.
///
/// Copied from [EmailVerificationCheck].
@ProviderFor(EmailVerificationCheck)
final emailVerificationCheckProvider =
    AutoDisposeAsyncNotifierProvider<EmailVerificationCheck, void>.internal(
  EmailVerificationCheck.new,
  name: r'emailVerificationCheckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emailVerificationCheckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmailVerificationCheck = AutoDisposeAsyncNotifier<void>;
String _$googleSsoHash() => r'91502e354478caa6142d2b8d3f24c35446c94b57';

/// Manages Google sign-in state (loading / error / data).
///
/// Copied from [GoogleSso].
@ProviderFor(GoogleSso)
final googleSsoProvider =
    AutoDisposeAsyncNotifierProvider<GoogleSso, AuthUser?>.internal(
  GoogleSso.new,
  name: r'googleSsoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$googleSsoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoogleSso = AutoDisposeAsyncNotifier<AuthUser?>;
String _$appleSsoHash() => r'6b6f3bee78dd2b25e850494497cc095739af9592';

/// Manages Apple sign-in state (loading / error / data).
///
/// Copied from [AppleSso].
@ProviderFor(AppleSso)
final appleSsoProvider =
    AutoDisposeAsyncNotifierProvider<AppleSso, AuthUser?>.internal(
  AppleSso.new,
  name: r'appleSsoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appleSsoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppleSso = AutoDisposeAsyncNotifier<AuthUser?>;
String _$pendingLinkEmailHash() => r'52140406f053f2e435b3bac2122ef41ad583739a';

/// Holds the email that triggered an account-link conflict.
///
/// Non-null value signals the UI to show the linking dialog.
///
/// Copied from [PendingLinkEmail].
@ProviderFor(PendingLinkEmail)
final pendingLinkEmailProvider =
    AutoDisposeNotifierProvider<PendingLinkEmail, String?>.internal(
  PendingLinkEmail.new,
  name: r'pendingLinkEmailProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingLinkEmailHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingLinkEmail = AutoDisposeNotifier<String?>;
String _$accountLinkHash() => r'bfb9cffd48fd784b76bb61b15fff675b9883e956';

/// Orchestrates the two-step re-authenticate-then-link flow.
///
/// Copied from [AccountLink].
@ProviderFor(AccountLink)
final accountLinkProvider =
    AutoDisposeAsyncNotifierProvider<AccountLink, void>.internal(
  AccountLink.new,
  name: r'accountLinkProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accountLinkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountLink = AutoDisposeAsyncNotifier<void>;
String _$deleteAccountHash() => r'323514fb1d511de0989309ba321fbf5869090c36';

/// Orchestrates account deletion: re-authenticate → three-step cleanup.
///
/// Copied from [DeleteAccount].
@ProviderFor(DeleteAccount)
final deleteAccountProvider =
    AutoDisposeAsyncNotifierProvider<DeleteAccount, void>.internal(
  DeleteAccount.new,
  name: r'deleteAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeleteAccount = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
