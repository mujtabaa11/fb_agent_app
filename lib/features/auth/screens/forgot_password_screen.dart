/// Forgot-password screen — email input → confirmation view (in place).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/errors/app_exceptions.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = l10n.invalidEmailError;
      });
      return;
    }

    setState(() {
      _emailError = null;
    });

    await ref.read(passwordResetProvider.notifier).sendPasswordResetEmail(email);
  }

  String _localizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'too-many-requests' => l10n.tooManyRequestsError,
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
    final resetState = ref.watch(passwordResetProvider);
    final isLoading = resetState.isLoading;

    ref.listen(passwordResetProvider, (previous, next) {
      if (!next.isLoading && !next.hasError && previous?.isLoading == true) {
        setState(() {
          _emailSent = true;
        });
      }
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
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: _emailSent ? _buildConfirmation(l10n) : _buildForm(l10n, isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.passwordResetTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        AuthTextField(
          label: l10n.emailLabel,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _emailError,
          onFieldSubmitted: (_) => _onSubmit(),
        ),
        const SizedBox(height: 24),

        Semantics(
          label: l10n.passwordResetButton,
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isLoading ? null : _onSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(l10n.passwordResetButton),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, size: 64),
        const SizedBox(height: 24),

        Text(
          l10n.passwordResetConfirmation,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        Semantics(
          label: l10n.backToLogin,
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.backToLogin),
            ),
          ),
        ),
      ],
    );
  }
}
