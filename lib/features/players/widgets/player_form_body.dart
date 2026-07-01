library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../../../core/widgets/am_currency_amount_field.dart';
import '../../../core/widgets/am_date_picker_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_photo_upload_field.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../setup/data/countries.dart';
import '../models/player_enums.dart';

const List<String> kPlayerFormCurrencies = ['EUR', 'GBP', 'USD', 'SAR', 'AED'];

class PlayerFormBody extends StatelessWidget {
  const PlayerFormBody({
    required this.formKey,
    required this.fullNameController,
    required this.secondNationalityController,
    required this.currentClubController,
    required this.leagueCountryController,
    required this.marketValueController,
    required this.transfermarktUrlController,
    required this.salaryController,
    required this.phoneController,
    required this.emailController,
    required this.whatsAppController,
    required this.dateOfBirth,
    required this.nationality,
    required this.countryOfResidence,
    required this.preferredPosition,
    required this.otherPositions,
    required this.preferredFoot,
    required this.marketValueCurrency,
    required this.representationAgreementStart,
    required this.representationAgreementExpiry,
    required this.clubContractExpiry,
    required this.salaryCurrency,
    required this.status,
    required this.isSaving,
    required this.submitted,
    required this.onPickPhoto,
    required this.onDateOfBirthChanged,
    required this.onNationalityChanged,
    required this.onCountryOfResidenceChanged,
    required this.onPreferredPositionChanged,
    required this.onOtherPositionToggled,
    required this.onPreferredFootChanged,
    required this.onMarketValueCurrencyChanged,
    required this.onRepresentationAgreementStartChanged,
    required this.onRepresentationAgreementExpiryChanged,
    required this.onClubContractExpiryChanged,
    required this.onSalaryCurrencyChanged,
    required this.onStatusChanged,
    required this.onFieldChanged,
    this.photoBytes,
    this.photoUrl,
    this.fullNameError,
    this.dobError,
    this.nationalityError,
    this.countryOfResidenceError,
    this.preferredPositionError,
    this.preferredFootError,
    this.phoneError,
    this.emailError,
    this.statusError,
    this.photoKey,
    this.fullNameKey,
    this.dobKey,
    this.nationalityKey,
    this.countryOfResidenceKey,
    this.preferredPositionKey,
    this.preferredFootKey,
    this.phoneKey,
    this.emailKey,
    this.statusKey,
    super.key,
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController fullNameController;
  final TextEditingController secondNationalityController;
  final TextEditingController currentClubController;
  final TextEditingController leagueCountryController;
  final TextEditingController marketValueController;
  final TextEditingController transfermarktUrlController;
  final TextEditingController salaryController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController whatsAppController;

  final DateTime? dateOfBirth;
  final String? nationality;
  final String? countryOfResidence;
  final PlayerPosition? preferredPosition;
  final Set<String> otherPositions;
  final PreferredFoot? preferredFoot;
  final String? marketValueCurrency;
  final DateTime? representationAgreementStart;
  final DateTime? representationAgreementExpiry;
  final DateTime? clubContractExpiry;
  final String? salaryCurrency;
  final PlayerStatus? status;

  final bool isSaving;
  final bool submitted;

  final Uint8List? photoBytes;
  final String? photoUrl;

  final VoidCallback onPickPhoto;
  final ValueChanged<DateTime?> onDateOfBirthChanged;
  final ValueChanged<String?> onNationalityChanged;
  final ValueChanged<String?> onCountryOfResidenceChanged;
  final ValueChanged<PlayerPosition?> onPreferredPositionChanged;
  final ValueChanged<String> onOtherPositionToggled;
  final ValueChanged<PreferredFoot?> onPreferredFootChanged;
  final ValueChanged<String?> onMarketValueCurrencyChanged;
  final ValueChanged<DateTime?> onRepresentationAgreementStartChanged;
  final ValueChanged<DateTime?> onRepresentationAgreementExpiryChanged;
  final ValueChanged<DateTime?> onClubContractExpiryChanged;
  final ValueChanged<String?> onSalaryCurrencyChanged;
  final ValueChanged<PlayerStatus?> onStatusChanged;
  final VoidCallback onFieldChanged;

  final String? fullNameError;
  final String? dobError;
  final String? nationalityError;
  final String? countryOfResidenceError;
  final String? preferredPositionError;
  final String? preferredFootError;
  final String? phoneError;
  final String? emailError;
  final String? statusError;

  final GlobalKey? photoKey;
  final GlobalKey? fullNameKey;
  final GlobalKey? dobKey;
  final GlobalKey? nationalityKey;
  final GlobalKey? countryOfResidenceKey;
  final GlobalKey? preferredPositionKey;
  final GlobalKey? preferredFootKey;
  final GlobalKey? phoneKey;
  final GlobalKey? emailKey;
  final GlobalKey? statusKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.sectionIdentity, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildIdentitySection(context, l10n),
          const SizedBox(height: AppTokens.space32),
          _buildSectionHeader(
              l10n.sectionFootballDetails, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildFootballDetailsSection(context, l10n),
          const SizedBox(height: AppTokens.space32),
          _buildSectionHeader(
              l10n.sectionRepresentation, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildRepresentationSection(l10n),
          const SizedBox(height: AppTokens.space32),
          _buildSectionHeader(
              l10n.sectionContractFinancial, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildContractFinancialSection(l10n),
          const SizedBox(height: AppTokens.space32),
          _buildSectionHeader(
              l10n.sectionContact, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildContactSection(l10n),
          const SizedBox(height: AppTokens.space32),
          _buildSectionHeader(
              l10n.sectionStatus, sectionColor, dividerColor),
          const SizedBox(height: AppTokens.space16),
          _buildStatusSection(l10n),
          const SizedBox(height: AppTokens.space24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, Color textColor, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppTokens.space8),
        Divider(color: dividerColor, height: 1),
      ],
    );
  }

  Widget _buildIdentitySection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          key: photoKey,
          child: AmPhotoUploadField(
            onTap: isSaving ? () {} : onPickPhoto,
            imageBytes: photoBytes,
            imageUrl: photoUrl,
            semanticsLabel: l10n.photoUploadLabel,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: fullNameKey,
          child: AmTextField(
            label: l10n.fieldFullName,
            controller: fullNameController,
            errorText: submitted ? fullNameError : null,
            enabled: !isSaving,
            onChanged: (_) => onFieldChanged(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: dobKey,
          child: AmDatePickerField(
            label: l10n.fieldDateOfBirth,
            value: dateOfBirth,
            lastDate: DateTime.now(),
            firstDate: DateTime(1950),
            errorText: submitted ? dobError : null,
            enabled: !isSaving,
            onChanged: onDateOfBirthChanged,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: nationalityKey,
          child: AmDropdownField<String>(
            label: l10n.fieldNationality,
            items: kCountries,
            itemLabel: (c) => c,
            value: nationality,
            errorText: submitted ? nationalityError : null,
            enabled: !isSaving,
            onChanged: onNationalityChanged,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldSecondNationality,
          controller: secondNationalityController,
          enabled: !isSaving,
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: countryOfResidenceKey,
          child: AmDropdownField<String>(
            label: l10n.fieldCountryOfResidence,
            items: kCountries,
            itemLabel: (c) => c,
            value: countryOfResidence,
            errorText: submitted ? countryOfResidenceError : null,
            enabled: !isSaving,
            onChanged: onCountryOfResidenceChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFootballDetailsSection(
      BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: preferredPositionKey,
          child: AmDropdownField<PlayerPosition>(
            label: l10n.fieldPreferredPosition,
            items: PlayerPosition.values,
            itemLabel: (p) => p.toFirestoreValue(),
            value: preferredPosition,
            errorText: submitted ? preferredPositionError : null,
            enabled: !isSaving,
            onChanged: onPreferredPositionChanged,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Text(
          l10n.fieldOtherPositions,
          style: TextStyle(
            fontSize: AppTokens.fontSizeSm,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTokens.space8),
        Semantics(
          label: l10n.fieldOtherPositions,
          child: Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: PlayerPosition.values.map((position) {
              final posValue = position.toFirestoreValue();
              final isSelected = otherPositions.contains(posValue);
              return AccessibleTouchTarget(
                semanticsLabel: posValue,
                onTap: isSaving
                    ? null
                    : () => onOtherPositionToggled(posValue),
                child: AmStatusBadge(
                  label: posValue,
                  backgroundColor:
                      isSelected ? AppColors.primary : AppColors.surfaceAlt,
                  textColor: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: preferredFootKey,
          child: AmDropdownField<PreferredFoot>(
            label: l10n.fieldPreferredFoot,
            items: PreferredFoot.values,
            itemLabel: (foot) {
              return switch (foot) {
                PreferredFoot.left => l10n.footLeft,
                PreferredFoot.right => l10n.footRight,
                PreferredFoot.both => l10n.footBoth,
              };
            },
            value: preferredFoot,
            errorText: submitted ? preferredFootError : null,
            enabled: !isSaving,
            onChanged: onPreferredFootChanged,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldCurrentClub,
          controller: currentClubController,
          enabled: !isSaving,
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldLeagueCountry,
          controller: leagueCountryController,
          enabled: !isSaving,
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmCurrencyAmountField(
          amountLabel: l10n.fieldMarketValue,
          currencies: kPlayerFormCurrencies,
          amountController: marketValueController,
          selectedCurrency: marketValueCurrency,
          enabled: !isSaving,
          onCurrencyChanged: onMarketValueCurrencyChanged,
          onAmountChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldTransfermarktUrl,
          controller: transfermarktUrlController,
          keyboardType: TextInputType.url,
          enabled: !isSaving,
          onChanged: (_) => onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildRepresentationSection(AppLocalizations l10n) {
    return Column(
      children: [
        AmDatePickerField(
          label: l10n.fieldRepresentationAgreementStart,
          value: representationAgreementStart,
          enabled: !isSaving,
          onChanged: onRepresentationAgreementStartChanged,
        ),
        const SizedBox(height: AppTokens.space16),
        AmDatePickerField(
          label: l10n.fieldRepresentationAgreementExpiry,
          value: representationAgreementExpiry,
          enabled: !isSaving,
          onChanged: onRepresentationAgreementExpiryChanged,
        ),
      ],
    );
  }

  Widget _buildContractFinancialSection(AppLocalizations l10n) {
    return Column(
      children: [
        AmDatePickerField(
          label: l10n.fieldClubContractExpiry,
          value: clubContractExpiry,
          enabled: !isSaving,
          onChanged: onClubContractExpiryChanged,
        ),
        const SizedBox(height: AppTokens.space16),
        AmCurrencyAmountField(
          amountLabel: l10n.fieldSalary,
          currencies: kPlayerFormCurrencies,
          amountController: salaryController,
          selectedCurrency: salaryCurrency,
          enabled: !isSaving,
          onCurrencyChanged: onSalaryCurrencyChanged,
          onAmountChanged: (_) => onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildContactSection(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          key: phoneKey,
          child: AmTextField(
            label: l10n.fieldPhoneNumber,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            errorText: submitted ? phoneError : null,
            enabled: !isSaving,
            onChanged: (_) => onFieldChanged(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: emailKey,
          child: AmTextField(
            label: l10n.fieldEmail,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: submitted ? emailError : null,
            enabled: !isSaving,
            onChanged: (_) => onFieldChanged(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldWhatsAppNumber,
          controller: whatsAppController,
          keyboardType: TextInputType.phone,
          enabled: !isSaving,
          onChanged: (_) => onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildStatusSection(AppLocalizations l10n) {
    return Container(
      key: statusKey,
      child: AmDropdownField<PlayerStatus>(
        label: l10n.fieldClientStatus,
        items: PlayerStatus.values,
        itemLabel: (status) {
          final l10n = AppLocalizations.of(statusKey?.currentContext ??
              formKey.currentContext!)!;
          return switch (status) {
            PlayerStatus.activeClient => l10n.statusActiveClient,
            PlayerStatus.prospect => l10n.statusProspect,
            PlayerStatus.formerClient => l10n.statusFormerClient,
          };
        },
        value: status,
        errorText: submitted ? statusError : null,
        enabled: !isSaving,
        onChanged: onStatusChanged,
      ),
    );
  }
}
