/// Modal bottom sheet for the account-linking flow.
///
/// Shown when SSO sign-in detects that the email is already registered under a
/// different provider. The user re-authenticates with their existing method
/// (email/password or SSO) and the pending credential is linked automatically.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/crashlytics_service.dart';
import '../providers/auth_providers.dart';
import 'auth_text_field.dart';

class AccountLinkSheet extends ConsumerStatefulWidget {
  const AccountLinkSheet({required this.email, super.key});

  final String email;

  @override
  ConsumerState<AccountLinkSheet> createState() => _AccountLinkSheetState();
}

class _AccountLinkSheetState extends ConsumerState<AccountLinkSheet> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _onSignInAndLink() async {
    setState(() => _passwordError = null);
    await ref.read(accountLinkProvider.notifier).reAuthAndLink(
          widget.email,
          _passwordController.text,
        );
  }

  Future<void> _onGoogleLink() async {
    setState(() => _passwordError = null);
    await ref.read(accountLinkProvider.notifier).reAuthWithGoogleAndLink();
  }

  Future<void> _onAppleLink() async {
    setState(() => _passwordError = null);
    await ref.read(accountLinkProvider.notifier).reAuthWithAppleAndLink();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final linkState = ref.watch(accountLinkProvider);
    final isLoading = linkState.isLoading;

    ref.listen(accountLinkProvider, (previous, next) {
      if (next is AsyncData && previous is AsyncLoading) {
        // Link succeeded — pop with `true` so the caller knows.
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountLinkSuccessMessage)),
        );
        return;
      }

      if (next.hasError && next.error is AppException) {
        final error = next.error! as AppException;
        if (error is AuthException) {
          switch (error.code) {
            case 'wrong-password' || 'invalid-credential' || 'user-not-found':
              setState(() {
                _passwordError = l10n.accountLinkWrongPassword;
              });
              return;
            case 'too-many-requests':
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.tooManyRequestsError)),
              );
              return;
          }
        }
        // Unexpected failure — log + SnackBar.
        ref.read(crashlyticsServiceProvider).recordError(
              error,
              StackTrace.current,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountLinkFailedMessage)),
        );
      }
    });

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 24,
        end: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l10n.accountLinkTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Body
          Text(
            l10n.accountLinkBody(widget.email),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Read-only email field
          AuthTextField(
            label: l10n.emailLabel,
            controller: TextEditingController(text: widget.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: false,
          ),
          const SizedBox(height: 16),

          // Password field
          AuthTextField(
            label: l10n.accountLinkPasswordLabel,
            controller: _passwordController,
            obscureText: _obscurePassword,
            onToggleObscure: _togglePasswordVisibility,
            textInputAction: TextInputAction.done,
            errorText: _passwordError,
            onFieldSubmitted: (_) => _onSignInAndLink(),
          ),
          const SizedBox(height: 16),

          // Sign In & Link button
          Semantics(
            label: l10n.accountLinkSignInButton,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: isLoading ? null : _onSignInAndLink,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.accountLinkSignInButton),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // "or sign in with" divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Text(
                  l10n.accountLinkOrDivider,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Google SSO
          Semantics(
            label: l10n.googleSignInButton,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading ? null : _onGoogleLink,
                child: Text(l10n.googleSignInButton),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Apple SSO — iOS only
          if (Platform.isIOS)
            Semantics(
              label: l10n.appleSignInButton,
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _onAppleLink,
                  child: Text(l10n.appleSignInButton),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
