/// Tests for [BiometricGuard].
///
/// Uses [pumpApp] with Riverpod overrides. Overrides
/// [biometricPreferenceNotifierProvider] directly with a synchronous value
/// to avoid an async provider resolution race in the guard's initial check.
///
/// **Known issue**: The production [BiometricPreferenceNotifier.build] uses
/// `ref.read(authStateChangesProvider)` (not `ref.watch`). If the auth state
/// hasn't resolved when `build()` first runs, `_currentUserId` is null and the
/// preference defaults to false regardless of storage. This race exists in
/// production but is mitigated by typical startup timing. In tests, we
/// override the notifier directly to avoid it.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template_app/core/services/crashlytics_service.dart';
import 'package:template_app/features/auth/models/auth_user.dart';
import 'package:template_app/features/auth/providers/auth_providers.dart';
import 'package:template_app/features/biometric/providers/biometric_preference_notifier.dart';
import 'package:template_app/features/biometric/providers/biometric_providers.dart';
import 'package:template_app/features/biometric/widgets/biometric_guard.dart';

import '../../helpers/mock_providers.dart';
import '../../helpers/test_utils.dart';

void main() {
  late FakeBiometricService fakeBiometric;
  late FakeAuthRepository fakeAuth;

  const testUser = AuthUser(
    uid: 'user-a',
    email: 'a@example.com',
    emailVerified: true,
  );

  setUp(() {
    fakeBiometric = FakeBiometricService();
    fakeAuth = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  /// Pumps a [BiometricGuard] wrapping a simple child widget.
  Future<void> pumpGuard(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    await pumpApp(
      tester,
      const BiometricGuard(
        child: Text('Home Content'),
      ),
      overrides: overrides,
    );
    // Pump extra frames to allow post-frame callbacks and async checks.
    await tester.pump();
    await tester.pump();
  }

  /// Builds overrides. Overrides [authStateChangesProvider] and
  /// [biometricPreferenceNotifierProvider] directly to avoid async resolution
  /// races in the guard's initial check.
  List<Override> buildOverrides({
    AuthUser? user,
    bool biometricEnabled = false,
  }) {
    return [
      biometricServiceProvider.overrideWithValue(fakeBiometric),
      authRepositoryProvider.overrideWithValue(fakeAuth),
      crashlyticsServiceProvider
          .overrideWithValue(NoOpCrashlyticsService()),
      authStateChangesProvider.overrideWith(
        (ref) => Stream.value(user),
      ),
      biometricPreferenceNotifierProvider.overrideWith(
        () => _TestBiometricPreferenceNotifier(biometricEnabled),
      ),
    ];
  }

  /// Pre-resolves async providers by pumping the widget tree and waiting for
  /// the [biometricPreferenceNotifierProvider] to have data, then sends a
  /// `resumed` lifecycle event to trigger the guard's lock check.
  Future<void> pumpAndCheckGuard(WidgetTester tester) async {
    // Let the preference notifier's build() resolve.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    // Now send a resumed event so the guard re-runs _checkAndLock with
    // the resolved preference state. _lastBackgroundedTimestamp is null
    // (cold start), so shouldLock = true.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
  }

  // ---------------------------------------------------------------------------
  // Biometric disabled → no lock
  // ---------------------------------------------------------------------------

  group('biometric disabled', () {
    testWidgets('no lock screen shown when biometric preference is off',
        (tester) async {
      fakeBiometric.available = true;

      await pumpGuard(
        tester,
        overrides: buildOverrides(user: testUser, biometricEnabled: false),
      );

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // No active session → no lock
  // ---------------------------------------------------------------------------

  group('no active session', () {
    testWidgets(
        'no lock screen shown regardless of biometric preference when user is null',
        (tester) async {
      fakeBiometric.available = true;

      await pumpGuard(
        tester,
        overrides: buildOverrides(biometricEnabled: true),
      );

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Cold start with biometric enabled → lock screen shown
  // ---------------------------------------------------------------------------

  group('cold start with biometric enabled', () {
    testWidgets('lock screen is shown on cold start when preference is enabled',
        (tester) async {
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = false;

      await pumpGuard(
        tester,
        overrides: buildOverrides(user: testUser, biometricEnabled: true),
      );

      // Let the preference notifier resolve, then simulate resume to
      // trigger _checkAndLock with resolved state.
      await pumpAndCheckGuard(tester);

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets(
        'successful biometric authentication dismisses lock screen',
        (tester) async {
      fakeBiometric.available = true;
      fakeBiometric.authenticateResult = true;

      await pumpGuard(
        tester,
        overrides: buildOverrides(user: testUser, biometricEnabled: true),
      );

      // Let the preference notifier resolve and trigger lock.
      await pumpAndCheckGuard(tester);
      // Auto-authenticate succeeds → lock dismissed.
      await tester.pumpAndSettle();

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Biometric not available → no lock even if preference is on
  // ---------------------------------------------------------------------------

  group('biometric not available', () {
    testWidgets('no lock screen when biometrics are not available on device',
        (tester) async {
      fakeBiometric.available = false;

      await pumpGuard(
        tester,
        overrides: buildOverrides(user: testUser, biometricEnabled: true),
      );

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}

/// Test override for [BiometricPreferenceNotifier] that immediately sets its
/// state to [AsyncData] in [build], avoiding the async timing issue where
/// the guard reads `.valueOrNull` before the real notifier's async build
/// completes.
class _TestBiometricPreferenceNotifier extends BiometricPreferenceNotifier {
  _TestBiometricPreferenceNotifier(this._enabled);

  final bool _enabled;

  @override
  Future<bool> build() {
    // Immediately set the state so .valueOrNull is available synchronously.
    state = AsyncData(_enabled);
    return Future.value(_enabled);
  }

  @override
  Future<void> checkDeviceEnrollment() async {
    // No-op in tests.
  }
}
