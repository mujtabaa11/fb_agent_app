import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmDropdownField<T> extends StatelessWidget {
  const AmDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final String? helperText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          errorText: errorText,
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space12,
          ),
        ),
        items: items.map((item) {
          final text = itemLabel(item);
          return DropdownMenuItem<T>(
            value: item,
            child: Text(text),
          );
        }).toList(),
      ),
    );
  }
}
