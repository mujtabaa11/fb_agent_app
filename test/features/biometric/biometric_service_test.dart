/// Tests for [LocalAuthBiometricService].
///
/// Mocks [LocalAuthentication] at the dependency injection boundary using
/// mockito. Tests verify that the service correctly maps local_auth results
/// to its own [BiometricService] contract.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:template_app/features/biometric/services/biometric_service.dart';

@GenerateMocks([LocalAuthentication])
import 'biometric_service_test.mocks.dart';

void main() {
  late MockLocalAuthentication mockLocalAuth;
  late LocalAuthBiometricService service;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    service = LocalAuthBiometricService(localAuth: mockLocalAuth);
  });

  // ---------------------------------------------------------------------------
  // isAvailable
  // ---------------------------------------------------------------------------

  group('isAvailable', () {
    test('returns true when both canCheckBiometrics and isDeviceSupported return true', () async {
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

      expect(await service.isAvailable(), isTrue);
    });

    test('returns false when canCheckBiometrics is false', () async {
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

      expect(await service.isAvailable(), isFalse);
    });

    test('returns false when isDeviceSupported is false', () async {
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

      expect(await service.isAvailable(), isFalse);
    });

    test('returns false when both are false', () async {
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

      expect(await service.isAvailable(), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // authenticate
  // ---------------------------------------------------------------------------

  group('authenticate', () {
    test('returns true when LocalAuthentication.authenticate succeeds', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => true);

      expect(
        await service.authenticate(localizedReason: 'test'),
        isTrue,
      );
    });

    test('returns false when LocalAuthentication.authenticate returns false', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => false);

      expect(
        await service.authenticate(localizedReason: 'test'),
        isFalse,
      );
    });

    test('returns false when LocalAuthentication.authenticate throws PlatformException', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenThrow(PlatformException(code: 'NotAvailable'));

      expect(
        await service.authenticate(localizedReason: 'test'),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // authenticateWithPasscode
  // ---------------------------------------------------------------------------

  group('authenticateWithPasscode', () {
    test('returns true when authentication succeeds', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => true);

      expect(
        await service.authenticateWithPasscode(localizedReason: 'test'),
        isTrue,
      );
    });

    test('returns false when authentication fails', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => false);

      expect(
        await service.authenticateWithPasscode(localizedReason: 'test'),
        isFalse,
      );
    });

    test('returns false when PlatformException is thrown', () async {
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        options: anyNamed('options'),
      )).thenThrow(PlatformException(code: 'NotEnrolled'));

      expect(
        await service.authenticateWithPasscode(localizedReason: 'test'),
        isFalse,
      );
    });
  });
}
