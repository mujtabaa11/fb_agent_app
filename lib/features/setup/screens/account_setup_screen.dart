library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_photo_upload_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../core/widgets/am_toggle_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/countries.dart';
import '../providers/setup_provider.dart';

class AccountSetupScreen extends ConsumerStatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  ConsumerState<AccountSetupScreen> createState() =>
      _AccountSetupScreenState();
}

class _AccountSetupScreenState extends ConsumerState<AccountSetupScreen> {
  static const _totalSteps = 4;
  int _currentStep = 0;
  bool _goingForward = true;

  void _nextStep() {
    setState(() {
      _goingForward = true;
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _goingForward = false;
      _currentStep--;
    });
  }

  Future<void> _handleLogout() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    switch (result) {
      case Success():
        context.go('/login');
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              exception.message,
              style: const TextStyle(color: AppColors.onPrimary),
            ),
          ),
        );
    }
  }

  Future<void> _handleComplete() async {
    final notifier = ref.read(accountSetupNotifierProvider.notifier);
    final result = await notifier.saveProfile();
    if (!mounted) return;

    switch (result) {
      case Success():
        context.go('/dashboard');
      case Failure():
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              l10n.setupErrorGeneric,
              style: const TextStyle(color: AppColors.onPrimary),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final setupState = ref.watch(accountSetupNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SetupHeader(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              l10n: l10n,
              onLogout: _handleLogout,
            ),
            _ProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final isForward = _goingForward;
                  final offset = isForward
                      ? Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        )
                      : Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        );
                  return SlideTransition(
                    position: offset.animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  );
                },
                child: _buildStepContent(setupState, l10n),
              ),
            ),
            _NavigationButtons(
              currentStep: _currentStep,
              setupState: setupState,
              l10n: l10n,
              onNext: _nextStep,
              onBack: _previousStep,
              onComplete: _handleComplete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AccountSetupState setupState, AppLocalizations l10n) {
    return switch (_currentStep) {
      0 => _Step1PhotoContent(
          key: const ValueKey(0),
          setupState: setupState,
          l10n: l10n,
        ),
      1 => _Step2IdentityContent(
          key: const ValueKey(1),
          setupState: setupState,
          l10n: l10n,
        ),
      2 => _Step3FifaContent(
          key: const ValueKey(2),
          setupState: setupState,
          l10n: l10n,
        ),
      _ => _Step4DetailsContent(
          key: const ValueKey(3),
          setupState: setupState,
          l10n: l10n,
        ),
    };
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.l10n,
    required this.onLogout,
  });

  final int currentStep;
  final int totalSteps;
  final AppLocalizations l10n;
  final VoidCallback onLogout;

  String get _title => switch (currentStep) {
        0 => l10n.setupStep1Title,
        1 => l10n.setupStep2Title,
        2 => l10n.setupStep3Title,
        _ => l10n.setupStep4Title,
      };

  String get _subtitle => switch (currentStep) {
        0 => l10n.setupStep1Subtitle,
        1 => l10n.setupStep2Subtitle,
        2 => l10n.setupStep3Subtitle,
        _ => l10n.setupStep4Subtitle,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppTokens.space24,
        AppTokens.space16,
        AppTokens.space24,
        AppTokens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              if (currentStep == 0)
                Semantics(
                  button: true,
                  label: l10n.setupLogout,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: TextButton(
                      onPressed: onLogout,
                      child: Text(
                        l10n.setupLogout,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              Text(
                l10n.setupStepCounter(currentStep + 1, totalSteps),
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          Text(
            _title,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            _subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
        vertical: AppTokens.space8,
      ),
      child: Semantics(
        label: 'Progress: step ${currentStep + 1} of $totalSteps',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fillFraction = (currentStep + 1) / totalSteps;
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              child: Stack(
                children: [
                  Container(
                    height: AppTokens.space4,
                    width: constraints.maxWidth,
                    color: AppColors.border,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: AppTokens.space4,
                    width: constraints.maxWidth * fillFraction,
                    color: AppColors.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons({
    required this.currentStep,
    required this.setupState,
    required this.l10n,
    required this.onNext,
    required this.onBack,
    required this.onComplete,
  });

  final int currentStep;
  final AccountSetupState setupState;
  final AppLocalizations l10n;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  bool get _isNextEnabled => switch (currentStep) {
        0 => setupState.isStep1Valid,
        1 => setupState.isStep2Valid,
        2 => setupState.isStep3Valid,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppTokens.space24,
        AppTokens.space8,
        AppTokens.space24,
        AppTokens.space16,
      ),
      child: currentStep == 0
          ? SizedBox(
              width: double.infinity,
              child: AmPrimaryButton(
                label: l10n.setupNext,
                onPressed: _isNextEnabled ? onNext : null,
                isDisabled: !_isNextEnabled,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: AmSecondaryButton(
                    label: l10n.setupBack,
                    onPressed: onBack,
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: currentStep == 3
                      ? AmPrimaryButton(
                          label: l10n.setupCompleteButton,
                          onPressed: onComplete,
                          isLoading: setupState.isSaving,
                        )
                      : AmPrimaryButton(
                          label: l10n.setupNext,
                          onPressed: _isNextEnabled ? onNext : null,
                          isDisabled: !_isNextEnabled,
                        ),
                ),
              ],
            ),
    );
  }
}

class _Step1PhotoContent extends ConsumerWidget {
  const _Step1PhotoContent({
    super.key,
    required this.setupState,
    required this.l10n,
  });

  final AccountSetupState setupState;
  final AppLocalizations l10n;

  Future<void> _pickPhoto(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return;

    ref.read(accountSetupNotifierProvider.notifier).uploadPhoto(image);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AmPhotoUploadField(
                onTap: setupState.isUploading ? () {} : () => _pickPhoto(ref),
                imageUrl: setupState.photoUrl,
                imageBytes: setupState.selectedPhotoBytes,
                semanticsLabel: l10n.setupStep1Title,
                size: 160,
              ),
              if (setupState.isUploading)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (setupState.uploadError != null) ...[
            const SizedBox(height: AppTokens.space12),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space32,
              ),
              child: Text(
                setupState.uploadError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Step2IdentityContent extends ConsumerStatefulWidget {
  const _Step2IdentityContent({
    super.key,
    required this.setupState,
    required this.l10n,
  });

  final AccountSetupState setupState;
  final AppLocalizations l10n;

  @override
  ConsumerState<_Step2IdentityContent> createState() =>
      _Step2IdentityContentState();
}

class _Step2IdentityContentState extends ConsumerState<_Step2IdentityContent> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.setupState.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(accountSetupNotifierProvider.notifier);
    final state = ref.watch(accountSetupNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
        vertical: AppTokens.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmTextField(
            label: widget.l10n.setupFullName,
            controller: _nameController,
            onChanged: notifier.setFullName,
          ),
          const SizedBox(height: AppTokens.space16),
          AmDropdownField<String>(
            label: widget.l10n.setupCountry,
            items: kCountries,
            itemLabel: (c) => c,
            value: state.country.isEmpty ? null : state.country,
            onChanged: (value) {
              if (value != null) notifier.setCountry(value);
            },
          ),
        ],
      ),
    );
  }
}

class _Step3FifaContent extends ConsumerStatefulWidget {
  const _Step3FifaContent({
    super.key,
    required this.setupState,
    required this.l10n,
  });

  final AccountSetupState setupState;
  final AppLocalizations l10n;

  @override
  ConsumerState<_Step3FifaContent> createState() => _Step3FifaContentState();
}

class _Step3FifaContentState extends ConsumerState<_Step3FifaContent> {
  late final TextEditingController _licenceController;

  @override
  void initState() {
    super.initState();
    _licenceController =
        TextEditingController(text: widget.setupState.licenceNumber);
  }

  @override
  void dispose() {
    _licenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(accountSetupNotifierProvider.notifier);
    final state = ref.watch(accountSetupNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
        vertical: AppTokens.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmToggleField(
            label: widget.l10n.setupFifaRegistered,
            value: state.isFifaRegistered ?? false,
            onChanged: notifier.setIsFifaRegistered,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: AlignmentDirectional.topStart,
            child: state.isFifaRegistered == true
                ? Padding(
                    padding:
                        const EdgeInsetsDirectional.only(top: AppTokens.space16),
                    child: AmTextField(
                      label: widget.l10n.setupLicenceNumber,
                      controller: _licenceController,
                      onChanged: notifier.setLicenceNumber,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Step4DetailsContent extends ConsumerStatefulWidget {
  const _Step4DetailsContent({
    super.key,
    required this.setupState,
    required this.l10n,
  });

  final AccountSetupState setupState;
  final AppLocalizations l10n;

  @override
  ConsumerState<_Step4DetailsContent> createState() =>
      _Step4DetailsContentState();
}

class _Step4DetailsContentState extends ConsumerState<_Step4DetailsContent> {
  late final TextEditingController _bioController;
  late final TextEditingController _agencyController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.setupState.bio);
    _agencyController =
        TextEditingController(text: widget.setupState.agencyName);
    _phoneController =
        TextEditingController(text: widget.setupState.phoneNumber);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _agencyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(accountSetupNotifierProvider.notifier);
    final state = ref.watch(accountSetupNotifierProvider);
    final l10n = widget.l10n;
    final textTheme = Theme.of(context).textTheme;

    final yearItems = List.generate(30, (i) => i + 1);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.space24,
        vertical: AppTokens.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: AppTokens.space24,
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    l10n.setupOptionalNotice,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          AmTextField(
            label: l10n.setupBio,
            controller: _bioController,
            multiline: true,
            onChanged: notifier.setBio,
          ),
          const SizedBox(height: AppTokens.space16),
          AmTextField(
            label: l10n.setupAgencyName,
            controller: _agencyController,
            onChanged: notifier.setAgencyName,
          ),
          const SizedBox(height: AppTokens.space16),
          AmDropdownField<int>(
            label: l10n.setupYearsOfExperience,
            items: yearItems,
            itemLabel: (y) =>
                y == 1 ? l10n.setupYearsSingular(y) : l10n.setupYearsPlural(y),
            value: state.yearsOfExperience,
            onChanged: (value) => notifier.setYearsOfExperience(value),
          ),
          const SizedBox(height: AppTokens.space16),
          AmTextField(
            label: l10n.setupPhoneNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setPhoneNumber,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: AlignmentDirectional.topStart,
            child: state.phoneNumber.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsetsDirectional.only(top: AppTokens.space16),
                    child: AmToggleField(
                      label: l10n.setupIsPhoneOnWhatsApp,
                      value: state.isPhoneOnWhatsApp,
                      onChanged: notifier.setIsPhoneOnWhatsApp,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppTokens.space32),
        ],
      ),
    );
  }
}
