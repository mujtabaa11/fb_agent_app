/// Firebase App Check abstraction.
///
/// Ships with a [DebugAppCheckService] that uses the debug provider for both
/// Android and iOS. Downstream projects should create a
/// `ProductionAppCheckService` that uses `AndroidProvider.playIntegrity` and
/// `AppleProvider.deviceCheck`, then swap the provider below.
library;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_check_service.g.dart';

/// Contract for Firebase App Check activation.
abstract class AppCheckService {
  /// Activate App Check with the appropriate attestation provider.
  Future<void> activate();
}

/// Debug-only implementation — prints a debug token to the console.
///
/// Register the token in Firebase Console → App Check → Apps → Manage debug
/// tokens to allow requests from this device.
class DebugAppCheckService implements AppCheckService {
  @override
  Future<void> activate() async {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidDebugProvider(),
      providerApple: const AppleDebugProvider(),
    );

    if (kDebugMode) {
      debugPrint('[AppCheck] Debug provider activated — '
          'copy the debug token from the native console output above '
          'and register it in Firebase Console → App Check → Manage debug tokens.');
    }
  }
}

@Riverpod(keepAlive: true)
AppCheckService appCheckService(AppCheckServiceRef ref) =>
    DebugAppCheckService();
