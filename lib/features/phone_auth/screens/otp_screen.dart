/// OTP verification screen for phone authentication.
///
/// Shows a masked phone number, 6-digit code input with auto-advance,
/// auto-submit on 6th digit, countdown timer, and resend functionality.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/phone_auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _codeLength = 6;
  static const _countdownDuration = 60;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late String _verificationId;
  int _countdown = _countdownDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
    _startCountdown();
    // Focus the first field after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = _countdownDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _maskedPhone() {
    final phone = widget.phoneNumber;
    if (phone.length <= 4) return phone;
    // Show dial code area and last 4 digits, mask the rest.
    // Find where the local number starts (after + and dial code digits).
    final lastFour = phone.substring(phone.length - 4);
    final prefix = phone.substring(0, phone.length - 4);
    final masked = prefix.replaceAll(RegExp(r'\d'), '*');
    return '$masked$lastFour';
  }

  String get _code {
    return _controllers.map((c) => c.text).join();
  }

  void _clearFields() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _onVerify() async {
    final code = _code;
    if (code.length != _codeLength) return;

    await ref
        .read(phoneSignInProvider.notifier)
        .signIn(_verificationId, code);
  }

  Future<void> _onResend() async {
    final verificationId = await ref
        .read(phoneVerificationProvider.notifier)
        .verifyPhoneNumber(widget.phoneNumber);

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (verificationId != null && verificationId != 'auto-verified') {
      _verificationId = verificationId;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneCodeSentConfirmation)),
      );
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling — distribute digits across fields.
      _handlePaste(value, index);
      return;
    }

    if (value.length == 1 && index < _codeLength - 1) {
      // Auto-advance to next field.
      _focusNodes[index + 1].requestFocus();
    }

    if (value.length == 1 && index == _codeLength - 1) {
      // Last digit entered — auto-submit.
      _focusNodes[index].unfocus();
      _onVerify();
    }
  }

  void _handlePaste(String pasted, int startIndex) {
    final digits = pasted.replaceAll(RegExp(r'[^\d]'), '');
    for (var i = 0; i < digits.length && (startIndex + i) < _codeLength; i++) {
      _controllers[startIndex + i].text = digits[i];
    }
    // Focus the next empty field or the last one.
    final nextEmpty = _controllers.indexWhere(
      (c) => c.text.isEmpty,
      startIndex,
    );
    if (nextEmpty != -1) {
      _focusNodes[nextEmpty].requestFocus();
    } else {
      _focusNodes[_codeLength - 1].unfocus();
      _onVerify();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    // Handle backspace on empty field — move to previous.
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _localizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'invalid-verification-code' => l10n.phoneInvalidCodeError,
        'credential-already-in-use' => l10n.phoneAccountExistsError,
        _ => l10n.errorGeneric,
      };
    }
    if (error is NetworkException) {
      return l10n.phoneNetworkError;
    }
    return l10n.errorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signInState = ref.watch(phoneSignInProvider);
    final isLoading = signInState.isLoading;

    // Listen for auth state changes (handles Android auto-verification).
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null && mounted) {
        context.go('/dashboard');
      }
    });

    ref.listen(phoneSignInProvider, (previous, next) {
      if (next.hasError && next.error is AppException) {
        final error = next.error! as AppException;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedError(error, l10n))),
        );
        // Clear fields on invalid code.
        if (error is AuthException && error.code == 'invalid-verification-code') {
          _clearFields();
        }
      }
    });

    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    final countdownText =
        '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phoneOtpTitle),
        leading: Semantics(
          label: l10n.backToLogin,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Masked phone number
              Text(
                _maskedPhone(),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 6-digit OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_codeLength, (index) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: index == 0 ? 0 : 8,
                    ),
                    child: Semantics(
                      label: l10n.phoneOtpDigitLabel(index + 1, _codeLength),
                      child: SizedBox(
                        width: 44,
                        height: 56,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) => _onKeyEvent(index, event),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: Theme.of(context).textTheme.headlineSmall,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsetsDirectional.symmetric(
                                vertical: 12,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) =>
                                _onDigitChanged(index, value),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Verify button (fallback for accessibility)
              Semantics(
                label: l10n.phoneVerifyButton,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading || _code.length != _codeLength
                        ? null
                        : _onVerify,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.phoneVerifyButton),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Countdown and resend
              if (_countdown > 0)
                Text(
                  l10n.phoneResendCountdown(countdownText),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              else
                Center(
                  child: Semantics(
                    label: l10n.phoneResendButton,
                    child: TextButton(
                      onPressed: _onResend,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(l10n.phoneResendButton),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
