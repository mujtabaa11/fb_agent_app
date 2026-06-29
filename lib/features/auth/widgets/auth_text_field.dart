/// Reusable text field for authentication screens.
///
/// Supports password visibility toggle, inline validation errors, and
/// accessibility via [Semantics] labels.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.label,
    required this.controller,
    required this.textInputAction,
    this.obscureText = false,
    this.onToggleObscure,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onFieldSubmitted,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: onToggleObscure != null
            ? Semantics(
                label: obscureText ? l10n.showPassword : l10n.hidePassword,
                child: IconButton(
                  icon: ExcludeSemantics(
                    child: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  onPressed: onToggleObscure,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
