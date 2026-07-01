library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../../../core/widgets/am_currency_amount_field.dart';
import '../../../core/widgets/am_date_picker_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_photo_upload_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../setup/data/countries.dart';
import '../models/player_enums.dart';
import '../providers/add_player_provider.dart';

const List<String> _kCurrencies = ['EUR', 'GBP', 'USD', 'SAR', 'AED'];

class AddPlayerScreen extends ConsumerStatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _fullNameController = TextEditingController();
  final _secondNationalityController = TextEditingController();
  final _currentClubController = TextEditingController();
  final _leagueCountryController = TextEditingController();
  final _marketValueController = TextEditingController();
  final _transfermarktUrlController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsAppController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _nationality;
  String? _countryOfResidence;
  PlayerPosition? _preferredPosition;
  final Set<String> _otherPositions = {};
  PreferredFoot? _preferredFoot;
  String? _marketValueCurrency;
  DateTime? _agentContractStart;
  DateTime? _agentContractExpiry;
  DateTime? _clubContractExpiry;
  String? _salaryCurrency;
  PlayerStatus? _status;

  String? _photoFilePath;
  Uint8List? _photoBytes;

  bool _isDirty = false;
  bool _submitted = false;

  // Error tracking for non-TextField fields
  String? _dobError;
  String? _nationalityError;
  String? _countryOfResidenceError;
  String? _preferredPositionError;
  String? _preferredFootError;
  String? _statusError;
  String? _fullNameError;
  String? _phoneError;
  String? _emailError;

  // Keys for scrolling to first error
  final _photoKey = GlobalKey();
  final _fullNameKey = GlobalKey();
  final _dobKey = GlobalKey();
  final _nationalityKey = GlobalKey();
  final _countryOfResidenceKey = GlobalKey();
  final _preferredPositionKey = GlobalKey();
  final _preferredFootKey = GlobalKey();
  final _phoneKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _statusKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _secondNationalityController.dispose();
    _currentClubController.dispose();
    _leagueCountryController.dispose();
    _marketValueController.dispose();
    _transfermarktUrlController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _whatsAppController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _photoFilePath = image.path;
        _photoBytes = bytes;
      });
      _markDirty();
    }
  }

  bool _validateForm() {
    final l10n = AppLocalizations.of(context)!;
    var isValid = true;

    // Full Name
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      _fullNameError = l10n.validationRequired;
      isValid = false;
    } else if (name.length < 2) {
      _fullNameError = l10n.validationNameTooShort;
      isValid = false;
    } else {
      _fullNameError = null;
    }

    // Date of Birth
    if (_dateOfBirth == null) {
      _dobError = l10n.validationRequired;
      isValid = false;
    } else {
      final now = DateTime.now();
      final age = now.year - _dateOfBirth!.year;
      final hadBirthdayThisYear = now.month > _dateOfBirth!.month ||
          (now.month == _dateOfBirth!.month && now.day >= _dateOfBirth!.day);
      final actualAge = hadBirthdayThisYear ? age : age - 1;
      if (actualAge < 15) {
        _dobError = l10n.validationPlayerTooYoung;
        isValid = false;
      } else {
        _dobError = null;
      }
    }

    // Nationality
    if (_nationality == null) {
      _nationalityError = l10n.validationRequired;
      isValid = false;
    } else {
      _nationalityError = null;
    }

    // Country of Residence
    if (_countryOfResidence == null) {
      _countryOfResidenceError = l10n.validationRequired;
      isValid = false;
    } else {
      _countryOfResidenceError = null;
    }

    // Preferred Position
    if (_preferredPosition == null) {
      _preferredPositionError = l10n.validationRequired;
      isValid = false;
    } else {
      _preferredPositionError = null;
    }

    // Preferred Foot
    if (_preferredFoot == null) {
      _preferredFootError = l10n.validationRequired;
      isValid = false;
    } else {
      _preferredFootError = null;
    }

    // Phone Number
    if (_phoneController.text.trim().isEmpty) {
      _phoneError = l10n.validationRequired;
      isValid = false;
    } else {
      _phoneError = null;
    }

    // Email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _emailError = l10n.validationRequired;
      isValid = false;
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _emailError = l10n.validationEmailInvalid;
      isValid = false;
    } else {
      _emailError = null;
    }

    // Status
    if (_status == null) {
      _statusError = l10n.validationRequired;
      isValid = false;
    } else {
      _statusError = null;
    }

    return isValid;
  }

  void _scrollToFirstError() {
    GlobalKey? firstErrorKey;
    if (_fullNameError != null) {
      firstErrorKey = _fullNameKey;
    } else if (_dobError != null) {
      firstErrorKey = _dobKey;
    } else if (_nationalityError != null) {
      firstErrorKey = _nationalityKey;
    } else if (_countryOfResidenceError != null) {
      firstErrorKey = _countryOfResidenceKey;
    } else if (_preferredPositionError != null) {
      firstErrorKey = _preferredPositionKey;
    } else if (_preferredFootError != null) {
      firstErrorKey = _preferredFootKey;
    } else if (_phoneError != null) {
      firstErrorKey = _phoneKey;
    } else if (_emailError != null) {
      firstErrorKey = _emailKey;
    } else if (_statusError != null) {
      firstErrorKey = _statusKey;
    }

    if (firstErrorKey?.currentContext != null) {
      Scrollable.ensureVisible(
        firstErrorKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  Future<void> _onSave() async {
    setState(() => _submitted = true);

    final isValid = _validateForm();
    setState(() {});

    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
      return;
    }

    final notifier = ref.read(addPlayerNotifierProvider.notifier);
    await notifier.savePlayer(
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      nationality: _nationality!,
      secondNationality: _secondNationalityController.text.trim().isEmpty
          ? null
          : _secondNationalityController.text.trim(),
      countryOfResidence: _countryOfResidence!,
      photoFilePath: _photoFilePath,
      preferredPosition: _preferredPosition!,
      otherPositions: _otherPositions.isEmpty ? null : _otherPositions.toList(),
      preferredFoot: _preferredFoot!,
      currentClub: _currentClubController.text.trim().isEmpty
          ? null
          : _currentClubController.text.trim(),
      leagueCountry: _leagueCountryController.text.trim().isEmpty
          ? null
          : _leagueCountryController.text.trim(),
      estimatedMarketValue: _marketValueController.text.trim().isEmpty
          ? null
          : double.tryParse(
              _marketValueController.text.trim().replaceAll(',', '')),
      marketValueCurrency: _marketValueCurrency,
      transfermarktUrl: _transfermarktUrlController.text.trim().isEmpty
          ? null
          : _transfermarktUrlController.text.trim(),
      agentContractStart: _agentContractStart,
      agentContractExpiry: _agentContractExpiry,
      clubContractExpiry: _clubContractExpiry,
      salary: _salaryController.text.trim().isEmpty
          ? null
          : double.tryParse(_salaryController.text.trim().replaceAll(',', '')),
      salaryCurrency: _salaryCurrency,
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      whatsAppNumber: _whatsAppController.text.trim().isEmpty
          ? null
          : _whatsAppController.text.trim(),
      status: _status!,
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditingButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discardButton),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _positionLabel(PlayerPosition position) {
    return position.toFirestoreValue();
  }

  String _footLabel(PreferredFoot foot) {
    final l10n = AppLocalizations.of(context)!;
    return switch (foot) {
      PreferredFoot.left => l10n.footLeft,
      PreferredFoot.right => l10n.footRight,
      PreferredFoot.both => l10n.footBoth,
    };
  }

  String _statusLabel(PlayerStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      PlayerStatus.activeClient => l10n.statusActiveClient,
      PlayerStatus.prospect => l10n.statusProspect,
      PlayerStatus.formerClient => l10n.statusFormerClient,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addPlayerState = ref.watch(addPlayerNotifierProvider);
    final isSaving = addPlayerState.isSaving;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;

    ref.listen(addPlayerNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        context.pop();
        return;
      }
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? l10n.errorSavePlayer),
            action: SnackBarAction(
              label: l10n.retryButton,
              onPressed: _onSave,
            ),
          ),
        );
      }
    });

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addPlayerTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsetsDirectional.all(AppTokens.space16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          l10n.sectionIdentity, sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildIdentitySection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space32),
                      _buildSectionHeader(l10n.sectionFootballDetails,
                          sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildFootballDetailsSection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space32),
                      _buildSectionHeader(l10n.sectionRepresentation,
                          sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildRepresentationSection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space32),
                      _buildSectionHeader(l10n.sectionContractFinancial,
                          sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildContractFinancialSection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space32),
                      _buildSectionHeader(
                          l10n.sectionContact, sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildContactSection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space32),
                      _buildSectionHeader(
                          l10n.sectionStatus, sectionColor, dividerColor),
                      const SizedBox(height: AppTokens.space16),
                      _buildStatusSection(l10n, isSaving),
                      const SizedBox(height: AppTokens.space24),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space16,
                vertical: AppTokens.space12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                border: Border(
                  top: BorderSide(color: dividerColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: AmPrimaryButton(
                    label: l10n.savePlayer,
                    isLoading: isSaving,
                    isDisabled: isSaving,
                    onPressed: _onSave,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildIdentitySection(AppLocalizations l10n, bool isSaving) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          key: _photoKey,
          child: AmPhotoUploadField(
            onTap: isSaving ? () {} : _pickPhoto,
            imageBytes: _photoBytes,
            semanticsLabel: l10n.photoUploadLabel,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: _fullNameKey,
          child: AmTextField(
            label: l10n.fieldFullName,
            controller: _fullNameController,
            errorText: _submitted ? _fullNameError : null,
            enabled: !isSaving,
            onChanged: (_) => _markDirty(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: _dobKey,
          child: AmDatePickerField(
            label: l10n.fieldDateOfBirth,
            value: _dateOfBirth,
            lastDate: DateTime.now(),
            firstDate: DateTime(1950),
            errorText: _submitted ? _dobError : null,
            enabled: !isSaving,
            onChanged: (date) {
              setState(() => _dateOfBirth = date);
              _markDirty();
            },
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: _nationalityKey,
          child: AmDropdownField<String>(
            label: l10n.fieldNationality,
            items: kCountries,
            itemLabel: (c) => c,
            value: _nationality,
            errorText: _submitted ? _nationalityError : null,
            enabled: !isSaving,
            onChanged: (value) {
              setState(() => _nationality = value);
              _markDirty();
            },
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldSecondNationality,
          controller: _secondNationalityController,
          enabled: !isSaving,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: _countryOfResidenceKey,
          child: AmDropdownField<String>(
            label: l10n.fieldCountryOfResidence,
            items: kCountries,
            itemLabel: (c) => c,
            value: _countryOfResidence,
            errorText: _submitted ? _countryOfResidenceError : null,
            enabled: !isSaving,
            onChanged: (value) {
              setState(() => _countryOfResidence = value);
              _markDirty();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFootballDetailsSection(AppLocalizations l10n, bool isSaving) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _preferredPositionKey,
          child: AmDropdownField<PlayerPosition>(
            label: l10n.fieldPreferredPosition,
            items: PlayerPosition.values,
            itemLabel: _positionLabel,
            value: _preferredPosition,
            errorText: _submitted ? _preferredPositionError : null,
            enabled: !isSaving,
            onChanged: (value) {
              setState(() => _preferredPosition = value);
              _markDirty();
            },
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Text(
          l10n.fieldOtherPositions,
          style: TextStyle(
            fontSize: AppTokens.fontSizeSm,
            color: Theme.of(context).brightness == Brightness.dark
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
              final isSelected = _otherPositions.contains(posValue);
              return AccessibleTouchTarget(
                semanticsLabel: posValue,
                onTap: isSaving
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _otherPositions.remove(posValue);
                          } else {
                            _otherPositions.add(posValue);
                          }
                        });
                        _markDirty();
                      },
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
          key: _preferredFootKey,
          child: AmDropdownField<PreferredFoot>(
            label: l10n.fieldPreferredFoot,
            items: PreferredFoot.values,
            itemLabel: _footLabel,
            value: _preferredFoot,
            errorText: _submitted ? _preferredFootError : null,
            enabled: !isSaving,
            onChanged: (value) {
              setState(() => _preferredFoot = value);
              _markDirty();
            },
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldCurrentClub,
          controller: _currentClubController,
          enabled: !isSaving,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldLeagueCountry,
          controller: _leagueCountryController,
          enabled: !isSaving,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmCurrencyAmountField(
          amountLabel: l10n.fieldMarketValue,
          currencies: _kCurrencies,
          amountController: _marketValueController,
          selectedCurrency: _marketValueCurrency,
          enabled: !isSaving,
          onCurrencyChanged: (value) {
            setState(() => _marketValueCurrency = value);
            _markDirty();
          },
          onAmountChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldTransfermarktUrl,
          controller: _transfermarktUrlController,
          keyboardType: TextInputType.url,
          enabled: !isSaving,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildRepresentationSection(AppLocalizations l10n, bool isSaving) {
    return Column(
      children: [
        AmDatePickerField(
          label: l10n.fieldAgentContractStart,
          value: _agentContractStart,
          enabled: !isSaving,
          onChanged: (date) {
            setState(() => _agentContractStart = date);
            _markDirty();
          },
        ),
        const SizedBox(height: AppTokens.space16),
        AmDatePickerField(
          label: l10n.fieldAgentContractExpiry,
          value: _agentContractExpiry,
          enabled: !isSaving,
          onChanged: (date) {
            setState(() => _agentContractExpiry = date);
            _markDirty();
          },
        ),
      ],
    );
  }

  Widget _buildContractFinancialSection(
      AppLocalizations l10n, bool isSaving) {
    return Column(
      children: [
        AmDatePickerField(
          label: l10n.fieldClubContractExpiry,
          value: _clubContractExpiry,
          enabled: !isSaving,
          onChanged: (date) {
            setState(() => _clubContractExpiry = date);
            _markDirty();
          },
        ),
        const SizedBox(height: AppTokens.space16),
        AmCurrencyAmountField(
          amountLabel: l10n.fieldSalary,
          currencies: _kCurrencies,
          amountController: _salaryController,
          selectedCurrency: _salaryCurrency,
          enabled: !isSaving,
          onCurrencyChanged: (value) {
            setState(() => _salaryCurrency = value);
            _markDirty();
          },
          onAmountChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildContactSection(AppLocalizations l10n, bool isSaving) {
    return Column(
      children: [
        Container(
          key: _phoneKey,
          child: AmTextField(
            label: l10n.fieldPhoneNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            errorText: _submitted ? _phoneError : null,
            enabled: !isSaving,
            onChanged: (_) => _markDirty(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        Container(
          key: _emailKey,
          child: AmTextField(
            label: l10n.fieldEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _submitted ? _emailError : null,
            enabled: !isSaving,
            onChanged: (_) => _markDirty(),
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        AmTextField(
          label: l10n.fieldWhatsAppNumber,
          controller: _whatsAppController,
          keyboardType: TextInputType.phone,
          enabled: !isSaving,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildStatusSection(AppLocalizations l10n, bool isSaving) {
    return Container(
      key: _statusKey,
      child: AmDropdownField<PlayerStatus>(
        label: l10n.fieldClientStatus,
        items: PlayerStatus.values,
        itemLabel: _statusLabel,
        value: _status,
        errorText: _submitted ? _statusError : null,
        enabled: !isSaving,
        onChanged: (value) {
          setState(() => _status = value);
          _markDirty();
        },
      ),
    );
  }
}
