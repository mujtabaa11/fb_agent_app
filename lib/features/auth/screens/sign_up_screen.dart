/// Sign-up screen — email & password registration with client-side validation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/errors/app_exceptions.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Validates the password against the required criteria.
  /// Returns `true` if the password is valid.
  bool _validatePassword(AppLocalizations l10n) {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp('[A-Z]'));
    final hasNumber = password.contains(RegExp('[0-9]'));

    if (!hasMinLength || !hasUppercase || !hasNumber) {
      setState(() {
        _passwordError = l10n.weakPasswordError;
      });
      return false;
    }

    setState(() {
      _passwordError = null;
    });
    return true;
  }

  Future<void> _onSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validatePassword(l10n)) return;

    await ref.read(signUpProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  String _localizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'email-already-in-use' => l10n.emailAlreadyInUseError,
        'wrong-password' => l10n.wrongPasswordError,
        'user-not-found' => l10n.wrongPasswordError,
        'weak-password' => l10n.weakPasswordError,
        'too-many-requests' => l10n.tooManyRequestsError,
        'invalid-credential' => l10n.wrongPasswordError,
        _ => l10n.errorGeneric,
      };
    }
    if (error is NetworkException) {
      return l10n.noInternetError;
    }
    return l10n.errorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signUpState = ref.watch(signUpProvider);
    final isLoading = signUpState.isLoading;

    ref.listen(signUpProvider, (previous, next) {
      if (next.hasError && next.error is AppException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizedError(next.error! as AppException, l10n),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.signUpTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email field
                AuthTextField(
                  label: l10n.emailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: l10n.passwordLabel,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleObscure: _togglePasswordVisibility,
                  errorText: _passwordError,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSignUp(),
                ),
                const SizedBox(height: 24),

                // Sign Up button
                Semantics(
                  label: l10n.signUpButton,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : _onSignUp,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.signUpButton),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigate to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Text(l10n.loginTitle)),
                    Semantics(
                      label: l10n.loginButton,
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.padded,
                          minimumSize: const Size(44, 44),
                        ),
                        child: Text(l10n.loginButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
