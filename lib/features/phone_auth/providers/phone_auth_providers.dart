/// Riverpod providers for phone authentication.
///
/// All providers depend on [AuthRepository] — they never reference Firebase
/// directly. Repository methods return [Result<T>]; providers pattern-match
/// on [Success]/[Failure] and surface errors via Riverpod's [AsyncError].
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_providers.dart';

part 'phone_auth_providers.g.dart';

/// Manages phone number verification state (sending SMS).
@riverpod
class PhoneVerification extends _$PhoneVerification {
  @override
  FutureOr<String?> build() => null;

  Future<String?> verifyPhoneNumber(String phoneNumber) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).verifyPhoneNumber(phoneNumber);
    return switch (result) {
      Success(:final value) => () {
          state = AsyncData(value);
          return value;
        }(),
      Failure(:final exception) => () {
          state = AsyncError(exception, StackTrace.current);
          return null;
        }(),
    };
  }
}

/// Manages OTP sign-in state (verifying the SMS code).
@riverpod
class PhoneSignIn extends _$PhoneSignIn {
  @override
  FutureOr<AuthUser?> build() => null;

  Future<AuthUser?> signIn(String verificationId, String smsCode) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithPhoneCredential(verificationId, smsCode);
    return switch (result) {
      Success(:final value) => () {
          state = AsyncData(value);
          return value;
        }(),
      Failure(:final exception) => () {
          state = AsyncError(exception, StackTrace.current);
          return null;
        }(),
    };
  }
}
