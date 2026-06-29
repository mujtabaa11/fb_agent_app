/// Email verification screen — shown after email/password sign-up.
///
/// The router guard redirects unverified email/password users here.
/// SSO users (Google, Apple) bypass this screen entirely since their
/// emails are provider-verified.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const _cooldownDuration = 60;
  static const _pollInterval = Duration(seconds: 5);

  Timer? _cooldownTimer;
  Timer? _pollTimer;
  int _cooldownSeconds = 0;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
    // Send verification email on mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSeconds = _cooldownDuration;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
      });
      if (_cooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Firebase authStateChanges() does not fire on user.reload(), so we must
    // poll periodically to detect when the user verifies their email in
    // another tab or device.
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      await _checkVerification(silent: true);
    });
  }

  Future<void> _sendVerificationEmail() async {
    final result =
        await ref.read(authRepositoryProvider).sendEmailVerification();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case Success():
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifyEmailSentConfirmation)),
        );
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedError(exception, l10n))),
        );
    }
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isCheckingVerification) return;
    // Only call setState for the loading indicator when the user tapped the
    // button (non-silent). Silent background polls should not trigger rebuilds.
    if (!silent) {
      setState(() {
        _isCheckingVerification = true;
      });
    } else {
      _isCheckingVerification = true;
    }

    final repo = ref.read(authRepositoryProvider);
    final reloadResult = await repo.reloadUser();
    if (!mounted) return;

    switch (reloadResult) {
      case Success():
        final user = repo.currentUser;
        if (user != null && user.emailVerified) {
          _pollTimer?.cancel();
          if (mounted) context.go('/home');
          return;
        }
        if (!silent && mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.verifyEmailNotYetVerified)),
          );
        }
      case Failure(:final exception):
        if (!silent && mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_localizedError(exception, l10n))),
          );
        }
    }

    if (mounted) {
      if (!silent) {
        setState(() {
          _isCheckingVerification = false;
        });
      } else {
        _isCheckingVerification = false;
      }
    }
  }

  Future<void> _handleSignOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    switch (result) {
      case Success():
        context.go('/login');
      case Failure(:final exception):
        if (kDebugMode) debugPrint('Sign-out failed: $exception');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGeneric),
          ),
        );
    }
  }

  String _localizedError(AppException error, AppLocalizations l10n) {
    if (error is NetworkException) return l10n.noInternetError;
    if (error is AuthException && error.code == 'too-many-requests') {
      return l10n.tooManyRequestsError;
    }
    return l10n.verifyEmailSendFailed;
  }

  /// Masks an email for display: `john@x.com` → `j**n@x.com`.
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) {
      // `ab@x.com` → `a*@x.com`
      return '${local[0]}${'*' * (local.length - 1)}@$domain';
    }
    // `john@x.com` → `j**n@x.com`
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authRepositoryProvider).currentUser;
    final email = user?.email ?? '';
    final maskedEmail = _maskEmail(email);
    final isCooldownActive = _cooldownSeconds > 0;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 64),
                const SizedBox(height: 24),

                Text(
                  l10n.verifyEmailTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.verifyEmailBody(maskedEmail),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // "I've Verified My Email" button
                Semantics(
                  label: l10n.verifyEmailContinueButton,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed:
                          _isCheckingVerification ? null : () => _checkVerification(),
                      child: _isCheckingVerification
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: Semantics(
                                label: l10n.verifyEmailCheckLabel,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(l10n.verifyEmailContinueButton),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend button with cooldown
                Semantics(
                  label: isCooldownActive
                      ? l10n.verifyEmailResendCooldown(_cooldownSeconds)
                      : l10n.verifyEmailResendButton,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed:
                          isCooldownActive ? null : _sendVerificationEmail,
                      child: Text(
                        isCooldownActive
                            ? l10n.verifyEmailResendCooldown(_cooldownSeconds)
                            : l10n.verifyEmailResendButton,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign out
                Semantics(
                  label: l10n.verifyEmailSignOutButton,
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      onPressed: _handleSignOut,
                      child: Text(l10n.verifyEmailSignOutButton),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
