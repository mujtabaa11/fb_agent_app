import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmTextField extends StatelessWidget {
  const AmTextField({
    required this.label,
    this.controller,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.multiline = false,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool multiline;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType ?? (multiline ? TextInputType.multiline : null),
        maxLines: multiline ? 5 : 1,
        minLines: multiline ? 3 : 1,
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space12,
          ),
        ),
      ),
    );
  }
}
