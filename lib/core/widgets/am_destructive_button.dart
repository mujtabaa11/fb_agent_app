import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmDestructiveButton extends StatelessWidget {
  const AmDestructiveButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.isDisabled = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        child: filled
            ? FilledButton(
                onPressed: isEnabled ? onPressed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppTokens.space24,
                    vertical: AppTokens.space12,
                  ),
                ),
                child: Text(label),
              )
            : OutlinedButton(
                onPressed: isEnabled ? onPressed : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
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
