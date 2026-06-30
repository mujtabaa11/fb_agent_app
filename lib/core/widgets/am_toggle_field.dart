import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmToggleField extends StatelessWidget {
  const AmToggleField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      toggled: value,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppTokens.space4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
