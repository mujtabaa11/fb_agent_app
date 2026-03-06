/// Login screen — email & password sign-in with social placeholders.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/remote_config_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/account_link_sheet.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

  Future<void> _showAccountLinkSheet(String email) async {
    final linked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountLinkSheet(email: email),
    );
    if (!mounted) return;
    ref.read(pendingLinkEmailProvider.notifier).clear();
    ref.read(authRepositoryProvider).clearPendingLink();
    if (linked == true) {
      context.go('/home');
    }
  }

  Future<void> _onLogin() async {
    await ref.read(signInProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _onGoogleSignIn() async {
    final user =
        await ref.read(googleSsoProvider.notifier).signInWithGoogle();
    if (user != null && mounted) {
      context.go('/home');
    }
  }

  Future<void> _onAppleSignIn() async {
    final user =
        await ref.read(appleSsoProvider.notifier).signInWithApple();
    if (user != null && mounted) {
      context.go('/home');
    }
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

  String _googleLocalizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'account-exists-with-different-credential' =>
          l10n.googleAccountLinkError,
        _ => l10n.errorGeneric,
      };
    }
    if (error is NetworkException) {
      return l10n.noInternetError;
    }
    return l10n.errorGeneric;
  }

  String _appleLocalizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'account-exists-with-different-credential' =>
          l10n.appleAccountLinkError,
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
    final signInState = ref.watch(signInProvider);
    final isLoading = signInState.isLoading;
    final googleSsoState = ref.watch(googleSsoProvider);
    final isGoogleLoading = googleSsoState.isLoading;
    final appleSsoState = ref.watch(appleSsoProvider);
    final isAppleLoading = appleSsoState.isLoading;

    ref.listen(signInProvider, (previous, next) {
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

    ref.listen(googleSsoProvider, (previous, next) {
      if (next.hasError && next.error is AppException) {
        if (next.error is AccountLinkException) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _googleLocalizedError(next.error! as AppException, l10n),
            ),
          ),
        );
      }
    });

    ref.listen(appleSsoProvider, (previous, next) {
      if (next.hasError && next.error is AppException) {
        if (next.error is AccountLinkException) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _appleLocalizedError(next.error! as AppException, l10n),
            ),
          ),
        );
      }
    });

    ref.listen(pendingLinkEmailProvider, (previous, next) {
      if (next != null) {
        _showAccountLinkSheet(next);
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
                  l10n.loginTitle,
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onLogin(),
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Semantics(
                    label: l10n.forgotPasswordButton,
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.padded,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(l10n.forgotPasswordButton),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Log In button
                Semantics(
                  label: l10n.loginButton,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : _onLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.loginButton),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Google sign-in
                Semantics(
                  label: l10n.googleSignInButton,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isGoogleLoading ? null : _onGoogleSignIn,
                      child: isGoogleLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.googleSignInButton),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Apple sign-in — iOS only
                if (Platform.isIOS)
                  Semantics(
                    label: l10n.appleSignInButton,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: isAppleLoading ? null : _onAppleSignIn,
                        child: isAppleLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.appleSignInButton),
                      ),
                    ),
                  ),

                // Phone sign-in — feature-flagged via Remote Config
                if (ref.watch(remoteConfigServiceProvider).getBool('phone_auth_enabled')) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    label: l10n.phoneSignInButton,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/phone-input'),
                        icon: const Icon(Icons.phone, size: 20),
                        label: Text(l10n.phoneSignInButton),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Navigate to sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Text(l10n.signUpTitle)),
                    Semantics(
                      label: l10n.signUpButton,
                      child: TextButton(
                        onPressed: () => context.go('/signup'),
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.padded,
                          minimumSize: const Size(44, 44),
                        ),
                        child: Text(l10n.signUpButton),
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
