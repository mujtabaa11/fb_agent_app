import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AmPrimaryButton extends StatelessWidget {
  const AmPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && !isDisabled && onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        child: FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.primary.withAlpha(100),
            disabledForegroundColor: AppColors.onPrimary.withAlpha(150),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.space24,
              vertical: AppTokens.space12,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: AppTokens.space24,
                  height: AppTokens.space24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
