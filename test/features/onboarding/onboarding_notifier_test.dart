/// Tests for [OnboardingNotifier].
///
/// Uses [SharedPreferences.setMockInitialValues] and [ProviderContainer] to
/// unit-test the notifier without pumping a widget — same pattern as
/// [ThemeNotifier] tests.
///
/// Tests verify persistence behavior only — does the flag persist? Does the
/// default apply? — NOT rendered UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_agent_mate/core/constants/storage_keys.dart';
import 'package:football_agent_mate/features/onboarding/providers/onboarding_notifier.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Default behavior
  // ---------------------------------------------------------------------------

  group('default behavior', () {
    test('hasCompletedOnboarding returns false when no flag exists in '
        'SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final completed =
          await container.read(onboardingNotifierProvider.future);

      expect(completed, false);
    });
  });

  // ---------------------------------------------------------------------------
  // completeOnboarding
  // ---------------------------------------------------------------------------

  group('completeOnboarding', () {
    test('writes true to SharedPreferences and updates provider state',
        () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial build.
      await container.read(onboardingNotifierProvider.future);

      // Complete onboarding.
      await container
          .read(onboardingNotifierProvider.notifier)
          .completeOnboarding();

      // Verify provider state updated.
      final completed =
          await container.read(onboardingNotifierProvider.future);
      expect(completed, true);

      // Verify SharedPreferences was written.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(StorageKeys.hasCompletedOnboarding), true);
    });
  });

  // ---------------------------------------------------------------------------
  // Existing flag at init
  // ---------------------------------------------------------------------------

  group('existing flag at init', () {
    test('on next initialization with flag set, hasCompletedOnboarding '
        'returns true', () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.hasCompletedOnboarding: true});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final completed =
          await container.read(onboardingNotifierProvider.future);

      expect(completed, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Persistence across provider rebuilds
  // ---------------------------------------------------------------------------

  group('persistence across provider rebuilds', () {
    test('flag written by completeOnboarding is preserved across provider '
        'rebuilds', () async {
      SharedPreferences.setMockInitialValues({});

      // First container: complete onboarding.
      final container1 = ProviderContainer();
      await container1.read(onboardingNotifierProvider.future);
      await container1
          .read(onboardingNotifierProvider.notifier)
          .completeOnboarding();
      container1.dispose();

      // Second container: simulates a fresh app launch. The flag persisted
      // via SharedPreferences should be read back.
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      final completed =
          await container2.read(onboardingNotifierProvider.future);

      expect(completed, true);
    });
  });
}
