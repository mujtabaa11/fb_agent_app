/// Bottom sheet for the account deletion flow.
///
/// Implements a multi-step process:
/// 1. First confirmation — warns the user that deletion is permanent.
/// 2. Re-authentication — verifies identity via password, Google, or Apple.
/// 3. Loading state — shows progress during the three-step deletion.
/// 4. Success — pops the sheet and navigates to login.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/widgets/auth_text_field.dart';

/// Minimum touch target dimension recommended by WCAG 2.1 SC 2.5.5.
const double _kMinTouchTarget = 44;

/// Shows the account deletion bottom sheet from the given [context].
Future<void> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (sheetContext) => const DeleteAccountSheet(),
  );
}

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

enum _Step { confirm, reAuth, deleting }

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  _Step _step = _Step.confirm;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _onConfirmDelete() {
    setState(() => _step = _Step.reAuth);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  Future<void> _onReAuthWithEmail() async {
    setState(() => _passwordError = null);
    final repo = ref.read(authRepositoryProvider);
    final email = repo.currentUser?.email ?? '';
    await ref
        .read(deleteAccountProvider.notifier)
        .reAuthWithEmailAndDelete(email, _passwordController.text);
  }

  Future<void> _onReAuthWithGoogle() async {
    setState(() => _passwordError = null);
    await ref.read(deleteAccountProvider.notifier).reAuthWithGoogleAndDelete();
  }

  Future<void> _onReAuthWithApple() async {
    setState(() => _passwordError = null);
    await ref.read(deleteAccountProvider.notifier).reAuthWithAppleAndDelete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deleteState = ref.watch(deleteAccountProvider);
    final isLoading = deleteState.isLoading;

    // Update step to deleting when loading starts from re-auth.
    if (isLoading && _step == _Step.reAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _step = _Step.deleting);
      });
    }

    ref.listen(deleteAccountProvider, (previous, next) {
      // Success — account deleted.
      if (next is AsyncData && previous is AsyncLoading) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.deleteAccountSuccessMessage)),
            );
          context.go('/login');
        }
        return;
      }

      if (next.hasError && next.error is AppException) {
        final error = next.error! as AppException;

        if (error is AuthException) {
          switch (error.code) {
            case 'requires-recent-login':
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteAccountRequiresRecentLogin),
                    ),
                  );
                // Return to re-auth step.
                setState(() => _step = _Step.reAuth);
              }
              return;
            case 'wrong-password' || 'invalid-credential' || 'user-not-found':
              setState(() {
                _passwordError = l10n.deleteAccountWrongPassword;
                _step = _Step.reAuth;
              });
              return;
            case 'too-many-requests':
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(l10n.tooManyRequestsError)),
                  );
                setState(() => _step = _Step.reAuth);
              }
              return;
          }
        }

        // Unexpected failure — log, show error, return to profile.
        ref.read(crashlyticsServiceProvider).recordError(
              error,
              StackTrace.current,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.deleteAccountErrorGeneric)),
            );
          Navigator.of(context).pop();
        }
      }
    });

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppTokens.space24,
        end: AppTokens.space24,
        top: AppTokens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.space24,
      ),
      child: switch (_step) {
        _Step.confirm => _buildConfirmStep(l10n),
        _Step.reAuth => _buildReAuthStep(l10n, isLoading),
        _Step.deleting => _buildDeletingStep(l10n),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Confirmation
  // ---------------------------------------------------------------------------

  Widget _buildConfirmStep(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space16),

        // Title
        Semantics(
          header: true,
          child: Text(
            l10n.deleteAccountConfirmTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppTokens.space12),

        // Body
        Text(
          l10n.deleteAccountConfirmBody,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space24),

        // Cancel button
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kMinTouchTarget,
            minHeight: _kMinTouchTarget,
          ),
          child: Semantics(
            button: true,
            label: l10n.deleteAccountConfirmCancel,
            child: OutlinedButton(
              onPressed: _onCancel,
              child: Text(l10n.deleteAccountConfirmCancel),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space12),

        // Delete button — destructive styling
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kMinTouchTarget,
            minHeight: _kMinTouchTarget,
          ),
          child: Semantics(
            button: true,
            label: l10n.deleteAccountConfirmDelete,
            child: OutlinedButton(
              onPressed: _onConfirmDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
              child: Text(l10n.deleteAccountConfirmDelete),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Re-authentication
  // ---------------------------------------------------------------------------

  Widget _buildReAuthStep(AppLocalizations l10n, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = ref.read(authRepositoryProvider).currentSignInProvider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space16),

        // Title
        Semantics(
          header: true,
          child: Text(
            l10n.deleteAccountReauthTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppTokens.space8),

        // Body
        Text(
          l10n.deleteAccountReauthBody,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space24),

        // Email/password re-auth
        if (provider == 'password') ...[
          AuthTextField(
            label: l10n.passwordLabel,
            controller: _passwordController,
            obscureText: _obscurePassword,
            onToggleObscure: _togglePasswordVisibility,
            textInputAction: TextInputAction.done,
            errorText: _passwordError,
            onFieldSubmitted: (_) => _onReAuthWithEmail(),
          ),
          const SizedBox(height: AppTokens.space16),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _kMinTouchTarget,
              minHeight: _kMinTouchTarget,
            ),
            child: Semantics(
              button: true,
              label: l10n.deleteAccountReauthPasswordButton,
              child: FilledButton(
                onPressed: isLoading ? null : _onReAuthWithEmail,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.deleteAccountReauthPasswordButton),
              ),
            ),
          ),
        ],

        // Google re-auth
        if (provider == 'google.com') ...[
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _kMinTouchTarget,
              minHeight: _kMinTouchTarget,
            ),
            child: Semantics(
              button: true,
              label: l10n.deleteAccountReauthGoogleButton,
              child: FilledButton(
                onPressed: isLoading ? null : _onReAuthWithGoogle,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.deleteAccountReauthGoogleButton),
              ),
            ),
          ),
        ],

        // Apple re-auth — iOS only
        if (provider == 'apple.com' && Platform.isIOS) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _kMinTouchTarget,
              minHeight: _kMinTouchTarget,
            ),
            child: Semantics(
              button: true,
              label: l10n.deleteAccountReauthAppleButton,
              child: FilledButton(
                onPressed: isLoading ? null : _onReAuthWithApple,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.deleteAccountReauthAppleButton),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppTokens.space16),

        // Cancel button
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kMinTouchTarget,
            minHeight: _kMinTouchTarget,
          ),
          child: Semantics(
            button: true,
            label: l10n.deleteAccountConfirmCancel,
            child: TextButton(
              onPressed: isLoading ? null : _onCancel,
              child: Text(l10n.deleteAccountConfirmCancel),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Deleting in progress
  // ---------------------------------------------------------------------------

  Widget _buildDeletingStep(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppTokens.space32),
        Semantics(
          label: l10n.deleteAccountDeletingProgress,
          child: const CircularProgressIndicator(),
        ),
        const SizedBox(height: AppTokens.space16),
        Text(
          l10n.deleteAccountDeletingProgress,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space32),
      ],
    );
  }
}
