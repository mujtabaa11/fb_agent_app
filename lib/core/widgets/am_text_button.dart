import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AmTextButton extends StatelessWidget {
  const AmTextButton({
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        child: TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space12,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
