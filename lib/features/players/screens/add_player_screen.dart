library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/player_enums.dart';
import '../providers/add_player_provider.dart';
import '../widgets/player_form_body.dart';

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
  DateTime? _representationAgreementStart;
  DateTime? _representationAgreementExpiry;
  DateTime? _clubContractExpiry;
  String? _salaryCurrency;
  PlayerStatus? _status;

  String? _photoFilePath;
  Uint8List? _photoBytes;

  bool _isDirty = false;
  bool _submitted = false;

  String? _dobError;
  String? _nationalityError;
  String? _countryOfResidenceError;
  String? _preferredPositionError;
  String? _preferredFootError;
  String? _statusError;
  String? _fullNameError;
  String? _phoneError;
  String? _emailError;

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

    if (_nationality == null) {
      _nationalityError = l10n.validationRequired;
      isValid = false;
    } else {
      _nationalityError = null;
    }

    if (_countryOfResidence == null) {
      _countryOfResidenceError = l10n.validationRequired;
      isValid = false;
    } else {
      _countryOfResidenceError = null;
    }

    if (_preferredPosition == null) {
      _preferredPositionError = l10n.validationRequired;
      isValid = false;
    } else {
      _preferredPositionError = null;
    }

    if (_preferredFoot == null) {
      _preferredFootError = l10n.validationRequired;
      isValid = false;
    } else {
      _preferredFootError = null;
    }

    if (_phoneController.text.trim().isEmpty) {
      _phoneError = l10n.validationRequired;
      isValid = false;
    } else {
      _phoneError = null;
    }

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
      representationAgreementStart: _representationAgreementStart,
      representationAgreementExpiry: _representationAgreementExpiry,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addPlayerState = ref.watch(addPlayerNotifierProvider);
    final isSaving = addPlayerState.isSaving;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                child: PlayerFormBody(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  secondNationalityController: _secondNationalityController,
                  currentClubController: _currentClubController,
                  leagueCountryController: _leagueCountryController,
                  marketValueController: _marketValueController,
                  transfermarktUrlController: _transfermarktUrlController,
                  salaryController: _salaryController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  whatsAppController: _whatsAppController,
                  dateOfBirth: _dateOfBirth,
                  nationality: _nationality,
                  countryOfResidence: _countryOfResidence,
                  preferredPosition: _preferredPosition,
                  otherPositions: _otherPositions,
                  preferredFoot: _preferredFoot,
                  marketValueCurrency: _marketValueCurrency,
                  representationAgreementStart: _representationAgreementStart,
                  representationAgreementExpiry: _representationAgreementExpiry,
                  clubContractExpiry: _clubContractExpiry,
                  salaryCurrency: _salaryCurrency,
                  status: _status,
                  isSaving: isSaving,
                  submitted: _submitted,
                  photoBytes: _photoBytes,
                  onPickPhoto: _pickPhoto,
                  onDateOfBirthChanged: (date) {
                    setState(() => _dateOfBirth = date);
                    _markDirty();
                  },
                  onNationalityChanged: (value) {
                    setState(() => _nationality = value);
                    _markDirty();
                  },
                  onCountryOfResidenceChanged: (value) {
                    setState(() => _countryOfResidence = value);
                    _markDirty();
                  },
                  onPreferredPositionChanged: (value) {
                    setState(() => _preferredPosition = value);
                    _markDirty();
                  },
                  onOtherPositionToggled: (posValue) {
                    setState(() {
                      if (_otherPositions.contains(posValue)) {
                        _otherPositions.remove(posValue);
                      } else {
                        _otherPositions.add(posValue);
                      }
                    });
                    _markDirty();
                  },
                  onPreferredFootChanged: (value) {
                    setState(() => _preferredFoot = value);
                    _markDirty();
                  },
                  onMarketValueCurrencyChanged: (value) {
                    setState(() => _marketValueCurrency = value);
                    _markDirty();
                  },
                  onRepresentationAgreementStartChanged: (date) {
                    setState(() => _representationAgreementStart = date);
                    _markDirty();
                  },
                  onRepresentationAgreementExpiryChanged: (date) {
                    setState(() => _representationAgreementExpiry = date);
                    _markDirty();
                  },
                  onClubContractExpiryChanged: (date) {
                    setState(() => _clubContractExpiry = date);
                    _markDirty();
                  },
                  onSalaryCurrencyChanged: (value) {
                    setState(() => _salaryCurrency = value);
                    _markDirty();
                  },
                  onStatusChanged: (value) {
                    setState(() => _status = value);
                    _markDirty();
                  },
                  onFieldChanged: _markDirty,
                  fullNameError: _fullNameError,
                  dobError: _dobError,
                  nationalityError: _nationalityError,
                  countryOfResidenceError: _countryOfResidenceError,
                  preferredPositionError: _preferredPositionError,
                  preferredFootError: _preferredFootError,
                  phoneError: _phoneError,
                  emailError: _emailError,
                  statusError: _statusError,
                  photoKey: _photoKey,
                  fullNameKey: _fullNameKey,
                  dobKey: _dobKey,
                  nationalityKey: _nationalityKey,
                  countryOfResidenceKey: _countryOfResidenceKey,
                  preferredPositionKey: _preferredPositionKey,
                  preferredFootKey: _preferredFootKey,
                  phoneKey: _phoneKey,
                  emailKey: _emailKey,
                  statusKey: _statusKey,
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
}
