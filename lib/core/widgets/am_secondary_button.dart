import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AmSecondaryButton extends StatelessWidget {
  const AmSecondaryButton({
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
        child: OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isEnabled
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(100),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.space24,
              vertical: AppTokens.space12,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
