import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

class AmCurrencyAmountField extends StatelessWidget {
  const AmCurrencyAmountField({
    required this.amountLabel,
    required this.currencies,
    this.amountController,
    this.selectedCurrency,
    this.onCurrencyChanged,
    this.onAmountChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String amountLabel;
  final List<String> currencies;
  final TextEditingController? amountController;
  final String? selectedCurrency;
  final ValueChanged<String?>? onCurrencyChanged;
  final ValueChanged<String>? onAmountChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: amountLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              initialValue: selectedCurrency,
              onChanged: enabled ? onCurrencyChanged : null,
              decoration: InputDecoration(
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space12,
                ),
              ),
              items: currencies.map((c) {
                return DropdownMenuItem<String>(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              onChanged: onAmountChanged,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: amountLabel,
                errorText: errorText,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
