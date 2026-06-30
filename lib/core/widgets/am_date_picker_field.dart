import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmDatePickerField extends StatelessWidget {
  const AmDatePickerField({
    required this.label,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.errorText,
    this.helperText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;
  final String? helperText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final displayText = value != null
        ? MaterialLocalizations.of(context).formatMediumDate(value!)
        : '';

    return Semantics(
      button: true,
      label: '$label${value != null ? ': $displayText' : ''}',
      child: GestureDetector(
        onTap: enabled ? () => _pickDate(context) : null,
        child: AbsorbPointer(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: TextField(
              controller: TextEditingController(text: displayText),
              enabled: false,
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                errorText: errorText,
                suffixIcon: const Icon(Icons.calendar_today),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onChanged?.call(picked);
    }
  }
}
