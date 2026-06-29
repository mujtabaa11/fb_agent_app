/// A UI overlay that shows the biometric lock screen when the app resumes
/// from the background after the grace period has elapsed.
///
/// This is NOT a router guard — it sits above the [MaterialApp.router] in the
/// widget tree and obscures app content with a blur + lock screen overlay.
///
/// Behaviour:
///   - Tracks `_lastBackgroundedTimestamp` in memory (resets on cold start).
///   - Cold start always requires biometric if the preference is enabled.
///   - Grace period: [AppConstants.biometricGracePeriodSeconds] (30 s).
///   - On Android, sets `FLAG_SECURE` while locked to prevent app switcher
///     preview.
///   - If Firebase session expires while locked, routes to login after unlock.
///   - On initialization, checks device enrollment — auto-clears preference
///     if biometrics are no longer available (e.g. user removed all
///     fingerprints/faces from device settings).
library;

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/biometric_preference_notifier.dart';
import '../providers/biometric_providers.dart';
import '../screens/biometric_lock_screen.dart';

class BiometricGuard extends ConsumerStatefulWidget {
  const BiometricGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends ConsumerState<BiometricGuard>
    with WidgetsBindingObserver {
  /// Timestamp when the app was last backgrounded. Null on cold start, which
  /// means biometric is always required on first open.
  DateTime? _lastBackgroundedTimestamp;

  /// Whether the lock screen overlay is currently showing.
  bool _isLocked = false;

  /// Whether we've completed the initial check after first build.
  bool _initialCheckDone = false;

  static const _platform = MethodChannel('com.footballagentmate.app/flags');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Schedule the initial biometric check for cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialCheck();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lastBackgroundedTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkAndLock();
    }
  }

  Future<void> _performInitialCheck() async {
    if (_initialCheckDone) return;
    _initialCheckDone = true;

    // Check device enrollment — auto-clear preference if biometrics are no
    // longer available (AC #9).
    await ref
        .read(biometricPreferenceNotifierProvider.notifier)
        .checkDeviceEnrollment();

    await _checkAndLock();
  }

  Future<void> _checkAndLock() async {
    if (_isLocked) return;

    final biometricPref =
        ref.read(biometricPreferenceNotifierProvider).valueOrNull;
    if (biometricPref != true) return;

    final authState = ref.read(authStateChangesProvider);
    final hasSession = authState.valueOrNull != null;
    if (!hasSession) return;

    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (!available) return;

    final shouldLock = _lastBackgroundedTimestamp == null ||
        DateTime.now().difference(_lastBackgroundedTimestamp!).inSeconds >
            AppConstants.biometricGracePeriodSeconds;

    if (shouldLock) {
      setState(() => _isLocked = true);
      _setFlagSecure(true);
    }
  }

  void _onAuthenticated() {
    setState(() => _isLocked = false);
    _setFlagSecure(false);

    // If Firebase session expired while locked, the router redirect will
    // automatically route to login — no extra handling needed here because
    // the router's refreshListenable fires on auth state changes.
  }

  void _setFlagSecure(bool secure) {
    if (!Platform.isAndroid) return;
    _platform.invokeMethod<void>(
      'setFlagSecure',
      {'secure': secure},
    ).catchError((_) {
      // Ignore — FLAG_SECURE is best-effort. If the method channel is not
      // set up (e.g. in tests or on a fresh project without the native
      // handler), we silently skip.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked) ...[
          // Blur overlay to obscure app content.
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: ColoredBox(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned.fill(
            child: BiometricLockScreen(
              onAuthenticated: _onAuthenticated,
            ),
          ),
        ],
      ],
    );
  }
}
