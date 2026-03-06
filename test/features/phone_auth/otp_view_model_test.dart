/// Tests for the phone auth Riverpod providers ([PhoneVerification] and
/// [PhoneSignIn]).
///
/// Uses [FakeAuthRepository] with a [ProviderContainer] for unit testing.
/// Verifies that providers correctly map [Result] from the repository to
/// Riverpod [AsyncValue] states.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template_app/core/errors/app_exceptions.dart';
import 'package:template_app/features/auth/models/auth_user.dart';
import 'package:template_app/features/auth/providers/auth_providers.dart';
import 'package:template_app/features/biometric/providers/biometric_providers.dart';
import 'package:template_app/features/phone_auth/providers/phone_auth_providers.dart';
import 'package:template_app/core/services/crashlytics_service.dart';

import '../../helpers/mock_providers.dart';

void main() {
  late FakeAuthRepository fakeAuth;

  setUp(() {
    fakeAuth = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        biometricServiceProvider.overrideWithValue(FakeBiometricService()),
        crashlyticsServiceProvider
            .overrideWithValue(NoOpCrashlyticsService()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ---------------------------------------------------------------------------
  // PhoneVerification
  // ---------------------------------------------------------------------------

  group('PhoneVerification', () {
    test('initial state is AsyncData(null)', () {
      final container = createContainer();

      final state = container.read(phoneVerificationProvider);

      expect(state, isA<AsyncData<String?>>());
      expect(state.value, isNull);
    });

    test('verifyPhoneNumber success sets state to AsyncData with verificationId',
        () async {
      final container = createContainer();

      final verificationId = await container
          .read(phoneVerificationProvider.notifier)
          .verifyPhoneNumber('+1234567890');

      expect(verificationId, 'fake-verification-id');

      final state = container.read(phoneVerificationProvider);
      expect(state, isA<AsyncData<String?>>());
      expect(state.value, 'fake-verification-id');
    });

    test('verifyPhoneNumber failure sets state to AsyncError', () async {
      fakeAuth.failWith = const NetworkException();
      final container = createContainer();

      final verificationId = await container
          .read(phoneVerificationProvider.notifier)
          .verifyPhoneNumber('+1234567890');

      expect(verificationId, isNull);

      final state = container.read(phoneVerificationProvider);
      expect(state, isA<AsyncError<String?>>());
      expect(state.error, isA<NetworkException>());
    });
  });

  // ---------------------------------------------------------------------------
  // PhoneSignIn
  // ---------------------------------------------------------------------------

  group('PhoneSignIn', () {
    test('initial state is AsyncData(null)', () {
      final container = createContainer();

      final state = container.read(phoneSignInProvider);

      expect(state, isA<AsyncData<AuthUser?>>());
      expect(state.value, isNull);
    });

    test('signIn success sets state to AsyncData with AuthUser', () async {
      final container = createContainer();

      final user = await container
          .read(phoneSignInProvider.notifier)
          .signIn('verification-id', '123456');

      expect(user, isNotNull);
      expect(user!.uid, 'phone-uid');
      expect(user.phoneNumber, '+1234567890');

      final state = container.read(phoneSignInProvider);
      expect(state, isA<AsyncData<AuthUser?>>());
      expect(state.value?.uid, 'phone-uid');
    });

    test('signIn failure sets state to AsyncError', () async {
      fakeAuth.failWith = const AuthException('invalid code');
      final container = createContainer();

      final user = await container
          .read(phoneSignInProvider.notifier)
          .signIn('verification-id', '000000');

      expect(user, isNull);

      final state = container.read(phoneSignInProvider);
      expect(state, isA<AsyncError<AuthUser?>>());
      expect(state.error, isA<AuthException>());
    });
  });
}
