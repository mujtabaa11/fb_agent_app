library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/edit_player_provider.dart';
import '../widgets/player_form_body.dart';

class EditPlayerScreen extends ConsumerStatefulWidget {
  const EditPlayerScreen({required this.playerId, super.key});

  final String playerId;

  @override
  ConsumerState<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends ConsumerState<EditPlayerScreen> {
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

  bool _submitted = false;
  bool _controllersInitialized = false;
  Uint8List? _photoBytes;

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

  void _initControllers(EditPlayerState editState) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    _fullNameController.text = editState.fullName;
    _secondNationalityController.text = editState.secondNationality ?? '';
    _currentClubController.text = editState.currentClub ?? '';
    _leagueCountryController.text = editState.leagueCountry ?? '';
    _transfermarktUrlController.text = editState.transfermarktUrl ?? '';
    _whatsAppController.text = editState.whatsAppNumber ?? '';
    _phoneController.text = editState.phoneNumber;
    _emailController.text = editState.email;

    if (editState.estimatedMarketValue != null) {
      _marketValueController.text =
          editState.estimatedMarketValue!.toStringAsFixed(0);
    }
    if (editState.salary != null) {
      _salaryController.text = editState.salary!.toStringAsFixed(0);
    }
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
      setState(() => _photoBytes = bytes);
      ref
          .read(editPlayerNotifierProvider(widget.playerId).notifier)
          .setNewPhoto(image.path);
    }
  }

  bool _validateForm() {
    final l10n = AppLocalizations.of(context)!;
    final editState =
        ref.read(editPlayerNotifierProvider(widget.playerId));
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

    if (editState.dateOfBirth == null) {
      _dobError = l10n.validationRequired;
      isValid = false;
    } else {
      final now = DateTime.now();
      final age = now.year - editState.dateOfBirth!.year;
      final hadBirthdayThisYear = now.month > editState.dateOfBirth!.month ||
          (now.month == editState.dateOfBirth!.month &&
              now.day >= editState.dateOfBirth!.day);
      final actualAge = hadBirthdayThisYear ? age : age - 1;
      if (actualAge < 15) {
        _dobError = l10n.validationPlayerTooYoung;
        isValid = false;
      } else {
        _dobError = null;
      }
    }

    if (editState.nationality == null) {
      _nationalityError = l10n.validationRequired;
      isValid = false;
    } else {
      _nationalityError = null;
    }

    if (editState.countryOfResidence == null) {
      _countryOfResidenceError = l10n.validationRequired;
      isValid = false;
    } else {
      _countryOfResidenceError = null;
    }

    if (editState.preferredPosition == null) {
      _preferredPositionError = l10n.validationRequired;
      isValid = false;
    } else {
      _preferredPositionError = null;
    }

    if (editState.preferredFoot == null) {
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

    if (editState.status == null) {
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

    final notifier =
        ref.read(editPlayerNotifierProvider(widget.playerId).notifier);

    notifier.updateFullName(_fullNameController.text.trim());
    notifier.updateSecondNationality(
      _secondNationalityController.text.trim().isEmpty
          ? null
          : _secondNationalityController.text.trim(),
    );
    notifier.updateCurrentClub(
      _currentClubController.text.trim().isEmpty
          ? null
          : _currentClubController.text.trim(),
    );
    notifier.updateLeagueCountry(
      _leagueCountryController.text.trim().isEmpty
          ? null
          : _leagueCountryController.text.trim(),
    );
    notifier.updateEstimatedMarketValue(
      _marketValueController.text.trim().isEmpty
          ? null
          : double.tryParse(
              _marketValueController.text.trim().replaceAll(',', '')),
    );
    notifier.updateTransfermarktUrl(
      _transfermarktUrlController.text.trim().isEmpty
          ? null
          : _transfermarktUrlController.text.trim(),
    );
    notifier.updateSalary(
      _salaryController.text.trim().isEmpty
          ? null
          : double.tryParse(
              _salaryController.text.trim().replaceAll(',', '')),
    );
    notifier.updatePhoneNumber(_phoneController.text.trim());
    notifier.updateEmail(_emailController.text.trim());
    notifier.updateWhatsAppNumber(
      _whatsAppController.text.trim().isEmpty
          ? null
          : _whatsAppController.text.trim(),
    );

    final isValid = _validateForm();
    setState(() {});

    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
      return;
    }

    await notifier.saveChanges();
  }

  Future<bool> _onWillPop() async {
    final editState =
        ref.read(editPlayerNotifierProvider(widget.playerId));
    if (!editState.isDirty) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editPlayerDiscardTitle),
        content: Text(l10n.editPlayerDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.editPlayerDiscardCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.editPlayerDiscardConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editState =
        ref.watch(editPlayerNotifierProvider(widget.playerId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;

    ref.listen(editPlayerNotifierProvider(widget.playerId),
        (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.editPlayerSuccess)),
        );
        context.pop();
        return;
      }
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? l10n.editPlayerError),
            action: SnackBarAction(
              label: l10n.retryButton,
              onPressed: _onSave,
            ),
          ),
        );
      }
    });

    if (editState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editPlayerTitle)),
        body: const Padding(
          padding: EdgeInsetsDirectional.all(AppTokens.space16),
          child: AmLoadingSkeleton(variant: AmSkeletonVariant.card),
        ),
      );
    }

    if (editState.loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editPlayerTitle)),
        body: AmErrorState(
          message: editState.loadError!,
          onRetry: () => ref
              .read(editPlayerNotifierProvider(widget.playerId).notifier)
              .retry(),
        ),
      );
    }

    if (!_controllersInitialized) {
      _initControllers(editState);
    }

    final isDirty = editState.isDirty;

    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editPlayerTitle),
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
                  dateOfBirth: editState.dateOfBirth,
                  nationality: editState.nationality,
                  countryOfResidence: editState.countryOfResidence,
                  preferredPosition: editState.preferredPosition,
                  otherPositions: editState.otherPositions,
                  preferredFoot: editState.preferredFoot,
                  representationAgreementStart:
                      editState.representationAgreementStart,
                  representationAgreementExpiry:
                      editState.representationAgreementExpiry,
                  clubContractExpiry: editState.clubContractExpiry,
                  salaryCurrency: editState.salaryCurrency,
                  status: editState.status,
                  isSaving: editState.isSaving,
                  submitted: _submitted,
                  photoBytes: _photoBytes,
                  photoUrl: editState.newPhotoFilePath == null
                      ? editState.photoUrl
                      : null,
                  onPickPhoto: _pickPhoto,
                  onDateOfBirthChanged: (date) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateDateOfBirth(date);
                  },
                  onNationalityChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateNationality(value);
                  },
                  onCountryOfResidenceChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateCountryOfResidence(value);
                  },
                  onPreferredPositionChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updatePreferredPosition(value);
                  },
                  onOtherPositionToggled: (posValue) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .toggleOtherPosition(posValue);
                  },
                  onPreferredFootChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updatePreferredFoot(value);
                  },
                  onRepresentationAgreementStartChanged: (date) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateRepresentationAgreementStart(date);
                  },
                  onRepresentationAgreementExpiryChanged: (date) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateRepresentationAgreementExpiry(date);
                  },
                  onClubContractExpiryChanged: (date) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateClubContractExpiry(date);
                  },
                  onSalaryCurrencyChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateSalaryCurrency(value);
                  },
                  onStatusChanged: (value) {
                    ref
                        .read(editPlayerNotifierProvider(widget.playerId)
                            .notifier)
                        .updateStatus(value);
                  },
                  onFieldChanged: () {
                    final notifier = ref.read(
                        editPlayerNotifierProvider(widget.playerId)
                            .notifier);
                    notifier
                        .updateFullName(_fullNameController.text.trim());
                    notifier.updateSecondNationality(
                      _secondNationalityController.text.trim().isEmpty
                          ? null
                          : _secondNationalityController.text.trim(),
                    );
                    notifier.updateCurrentClub(
                      _currentClubController.text.trim().isEmpty
                          ? null
                          : _currentClubController.text.trim(),
                    );
                    notifier.updateLeagueCountry(
                      _leagueCountryController.text.trim().isEmpty
                          ? null
                          : _leagueCountryController.text.trim(),
                    );
                    notifier.updateTransfermarktUrl(
                      _transfermarktUrlController.text.trim().isEmpty
                          ? null
                          : _transfermarktUrlController.text.trim(),
                    );
                    notifier.updatePhoneNumber(
                        _phoneController.text.trim());
                    notifier.updateEmail(_emailController.text.trim());
                    notifier.updateWhatsAppNumber(
                      _whatsAppController.text.trim().isEmpty
                          ? null
                          : _whatsAppController.text.trim(),
                    );
                  },
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
                    label: l10n.editPlayerSave,
                    isLoading: editState.isSaving,
                    isDisabled: editState.isSaving || !isDirty,
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
