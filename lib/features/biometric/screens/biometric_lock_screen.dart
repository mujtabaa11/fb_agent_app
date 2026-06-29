/// Full-screen lock overlay that shows when biometric authentication is
/// required after returning to the app.
///
/// Shows the native biometric prompt automatically on mount. On failure or
/// cancel, offers "Try Again" and "Use Passcode" buttons. If the platform
/// retry limit is exceeded, shows a fallback state with "Use Passcode" only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../providers/biometric_providers.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({
    required this.onAuthenticated,
    super.key,
  });

  /// Called when biometric or passcode authentication succeeds.
  final VoidCallback onAuthenticated;

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _biometricFailed = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Trigger biometric prompt after the first frame so the widget tree is
    // fully built and context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !mounted) return;
    setState(() => _isAuthenticating = true);

    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(biometricServiceProvider);
    final success = await service.authenticate(
      localizedReason: l10n.biometricReason,
    );

    if (!mounted) return;

    if (success) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _isAuthenticating = false;
        _biometricFailed = true;
      });
    }
  }

  Future<void> _authenticateWithPasscode() async {
    if (_isAuthenticating || !mounted) return;
    setState(() => _isAuthenticating = true);

    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(biometricServiceProvider);
    final success = await service.authenticateWithPasscode(
      localizedReason: l10n.biometricReason,
    );

    if (!mounted) return;

    if (success) {
      widget.onAuthenticated();
    } else {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _biometricFailed ? Icons.lock_outline : Icons.fingerprint,
                    size: 64,
                    color: colorScheme.primary,
                    semanticLabel: _biometricFailed
                        ? l10n.biometricFailedTitle
                        : l10n.biometricLockTitle,
                  ),
                  const SizedBox(height: AppTokens.space24),
                  Text(
                    _biometricFailed
                        ? l10n.biometricFailedTitle
                        : l10n.biometricLockTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Text(
                    _biometricFailed
                        ? l10n.biometricFailedSubtitle
                        : l10n.biometricLockSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space48),
                  if (_isAuthenticating)
                    const CircularProgressIndicator()
                  else ...[
                    if (!_biometricFailed)
                      AccessibleTouchTarget(
                        semanticsLabel: l10n.biometricTryAgainButton,
                        child: FilledButton.icon(
                          onPressed: _authenticate,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(l10n.biometricTryAgainButton),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                    if (!_biometricFailed)
                      const SizedBox(height: AppTokens.space12),
                    AccessibleTouchTarget(
                      semanticsLabel: l10n.biometricUsePasscodeButton,
                      child: OutlinedButton.icon(
                        onPressed: _authenticateWithPasscode,
                        icon: const Icon(Icons.dialpad),
                        label: Text(l10n.biometricUsePasscodeButton),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
