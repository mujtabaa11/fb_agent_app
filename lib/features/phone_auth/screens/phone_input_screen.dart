/// Phone number input screen for phone authentication.
///
/// Allows the user to select a country code and enter a phone number.
/// Validates the number format (7–15 digits) and triggers SMS verification.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../l10n/app_localizations.dart';
import '../models/country_code.dart';
import '../providers/phone_auth_providers.dart';
import '../widgets/country_code_picker.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  late CountryCode _selectedCountry;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _defaultCountryFromLocale();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  CountryCode _defaultCountryFromLocale() {
    final localeCountry =
        ui.PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
    if (localeCountry != null) {
      for (final country in CountryCode.all) {
        if (country.code == localeCountry) return country;
      }
    }
    // Fallback to UAE.
    return CountryCode.all.first;
  }

  String _sanitizeNumber(String raw) {
    // Strip spaces, dashes, parentheses, and leading zeros.
    return raw.replaceAll(RegExp(r'[\s\-\(\)]'), '').replaceFirst(RegExp(r'^0+'), '');
  }

  bool _validate(AppLocalizations l10n) {
    final sanitized = _sanitizeNumber(_phoneController.text);
    final fullNumber = '${_selectedCountry.dialCode}$sanitized';
    // Dial code digits + local number should total 7–15 digits.
    final digitsOnly = fullNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      setState(() => _errorText = l10n.phoneInvalidNumberError);
      return false;
    }
    setState(() => _errorText = null);
    return true;
  }

  Future<void> _onSendCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

    final sanitized = _sanitizeNumber(_phoneController.text);
    final fullNumber = '${_selectedCountry.dialCode}$sanitized';

    final verificationId = await ref
        .read(phoneVerificationProvider.notifier)
        .verifyPhoneNumber(fullNumber);

    if (!mounted) return;

    if (verificationId != null) {
      if (verificationId == 'auto-verified') {
        // Android auto-verify signed the user in — auth state change
        // will trigger router navigation to home.
        return;
      }
      context.go('/otp', extra: {
        'verificationId': verificationId,
        'phoneNumber': fullNumber,
      });
    }
  }

  Future<void> _onPickCountry() async {
    final picked = await showCountryCodePicker(
      context: context,
      selected: _selectedCountry,
    );
    if (picked != null) {
      setState(() => _selectedCountry = picked);
    }
  }

  String _localizedError(AppException error, AppLocalizations l10n) {
    if (error is AuthException) {
      return switch (error.code) {
        'invalid-phone-number' => l10n.phoneInvalidNumberError,
        'too-many-requests' => l10n.phoneTooManyRequestsError,
        _ => l10n.errorGeneric,
      };
    }
    if (error is NetworkException) {
      return l10n.phoneNetworkError;
    }
    return l10n.errorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verificationState = ref.watch(phoneVerificationProvider);
    final isLoading = verificationState.isLoading;

    ref.listen(phoneVerificationProvider, (previous, next) {
      if (next.hasError && next.error is AppException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localizedError(next.error! as AppException, l10n),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phoneInputTitle),
        leading: Semantics(
          label: l10n.backToLogin,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Country code picker + phone number input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code button
                  Semantics(
                    label: '${_selectedCountry.name}, ${_selectedCountry.dialCode}',
                    button: true,
                    child: InkWell(
                      onTap: _onPickCountry,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCountry.dialCode,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Phone number text field
                  Expanded(
                    child: Semantics(
                      label: l10n.phoneNumberHint,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onSendCode(),
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumberHint,
                          errorText: _errorText,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Send verification code button
              Semantics(
                label: l10n.phoneSendCodeButton,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _onSendCode,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.phoneSendCodeButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
