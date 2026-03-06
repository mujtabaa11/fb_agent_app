/// Tests for [BiometricPreferenceNotifier].
///
/// Uses [FakeStorageService] and [FakeBiometricService] from the test helpers
/// with a [ProviderContainer] for Riverpod unit testing.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template_app/core/constants/storage_keys.dart';
import 'package:template_app/core/services/crashlytics_service.dart';
import 'package:template_app/core/storage/storage_providers.dart';
import 'package:template_app/features/auth/models/auth_user.dart';
import 'package:template_app/features/auth/providers/auth_providers.dart';
import 'package:template_app/features/biometric/providers/biometric_preference_notifier.dart';
import 'package:template_app/features/biometric/providers/biometric_providers.dart';

import '../../helpers/mock_providers.dart';

void main() {
  late FakeStorageService fakeStorage;
  late FakeBiometricService fakeBiometric;
  late FakeAuthRepository fakeAuth;

  setUp(() {
    fakeStorage = FakeStorageService();
    fakeBiometric = FakeBiometricService();
    fakeAuth = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  Future<ProviderContainer> createContainer({AuthUser? user}) async {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(fakeStorage),
        biometricServiceProvider.overrideWithValue(fakeBiometric),
        authRepositoryProvider.overrideWithValue(fakeAuth),
        crashlyticsServiceProvider.overrideWithValue(FakeCrashlyticsService()),
      ],
    );
    addTearDown(container.dispose);

    // Start listening to the auth stream BEFORE emitting the user so the
    // broadcast event is not lost.
    container.read(authStateChangesProvider);

    if (user != null) {
      fakeAuth.setUser(user);
      // Allow the stream provider to process the emitted user.
      await Future<void>.delayed(Duration.zero);
    }

    return container;
  }

  const testUser = AuthUser(
    uid: 'user-a',
    email: 'a@example.com',
    emailVerified: true,
  );

  const testUserB = AuthUser(
    uid: 'user-b',
    email: 'b@example.com',
    emailVerified: true,
  );

  // ---------------------------------------------------------------------------
  // Default state
  // ---------------------------------------------------------------------------

  group('default preference', () {
    test('defaults to false when no value is stored', () async {
      final container = await createContainer(user: testUser);

      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);

      expect(enabled, isFalse);
    });

    test('defaults to false when user is not authenticated', () async {
      final container = await createContainer();

      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);

      expect(enabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // enable()
  // ---------------------------------------------------------------------------

  group('enable', () {
    test('with biometrics available and auth succeeding writes true to storage', () async {
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = true;
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      final result = await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test reason');

      expect(result, BiometricEnableResult.success);

      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, 'true');

      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);
      expect(enabled, isTrue);
    });

    test('with biometrics NOT available returns notAvailable and does not write', () async {
      fakeBiometric.available = false;
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      final result = await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test reason');

      expect(result, BiometricEnableResult.notAvailable);

      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, isNull);
    });

    test('with auth failing returns verificationFailed and does not write', () async {
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = false;
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      final result = await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test reason');

      expect(result, BiometricEnableResult.verificationFailed);

      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // disable()
  // ---------------------------------------------------------------------------

  group('disable', () {
    test('deletes the key from secure storage', () async {
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = true;
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      // Enable first.
      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test reason');

      // Disable.
      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .disable();

      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, isNull);

      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);
      expect(enabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // clearForUser()
  // ---------------------------------------------------------------------------

  group('clearForUser', () {
    test('deletes the correct user-scoped key', () async {
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      // Manually write a preference.
      await fakeStorage.write(
        StorageKeys.biometricEnabledForUser('user-a'),
        'true',
      );

      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .clearForUser('user-a');

      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, isNull);
    });

    test('after clearForUser reading the preference returns false', () async {
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      // Enable biometric.
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = true;
      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test');

      // Clear for user (simulates account deletion).
      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .clearForUser('user-a');

      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);
      expect(enabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // User-scoped key isolation
  // ---------------------------------------------------------------------------

  group('user-scoped key isolation', () {
    test('user A preference does not affect user B', () async {
      // Write preference for user A.
      await fakeStorage.write(
        StorageKeys.biometricEnabledForUser('user-a'),
        'true',
      );

      // Create container for user B.
      final container = await createContainer(user: testUserB);
      final enabled = await container
          .read(biometricPreferenceNotifierProvider.future);

      expect(enabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Sign-out preservation
  // ---------------------------------------------------------------------------

  group('sign-out behavior', () {
    test('sign-out does NOT clear biometric preference', () async {
      final container = await createContainer(user: testUser);
      await container.read(biometricPreferenceNotifierProvider.future);

      // Enable biometric.
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = true;
      await container
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable('test');

      // Simulate sign-out via repository.
      await fakeAuth.signOut();

      // Verify the storage key is still present.
      final stored = await fakeStorage
          .read(StorageKeys.biometricEnabledForUser('user-a'));
      expect(stored, 'true');
    });
  });
}
