library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../../../core/widgets/am_date_picker_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../players/models/player_enums.dart';
import '../../setup/data/countries.dart';
import '../providers/create_post_provider.dart';

class CreateNeedAPlayerPostScreen extends ConsumerStatefulWidget {
  const CreateNeedAPlayerPostScreen({super.key});

  @override
  ConsumerState<CreateNeedAPlayerPostScreen> createState() =>
      _CreateNeedAPlayerPostScreenState();
}

class _CreateNeedAPlayerPostScreenState
    extends ConsumerState<CreateNeedAPlayerPostScreen> {
  final _leagueCountryController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isDirty = false;

  @override
  void dispose() {
    _leagueCountryController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  CreateNeedAPlayerPostNotifier get _notifier =>
      ref.read(createNeedAPlayerPostNotifierProvider.notifier);

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

  Future<void> _onSave() async {
    await _notifier.savePost();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;
    final state = ref.watch(createNeedAPlayerPostNotifierProvider);

    ref.listen(createNeedAPlayerPostNotifierProvider, (previous, next) {
      if (next.isSuccess && previous?.isSuccess != true) {
        context.go('/market');
        return;
      }
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            action: SnackBarAction(
              label: l10n.retryButton,
              onPressed: _onSave,
            ),
          ),
        );
      }
    });

    final ageRangeError =
        state.isAgeRangeValid ? null : l10n.postAgeRangeError;

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
        appBar: AppBar(title: Text(l10n.createNeedAPlayerTitle)),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmDropdownField<PlayerPosition?>(
                      label: l10n.postNeededPosition,
                      items: <PlayerPosition?>[
                        null,
                        ...PlayerPosition.values,
                      ],
                      itemLabel: (p) =>
                          p == null ? l10n.postAnyPosition : p.toFirestoreValue(),
                      value: state.neededPosition,
                      onChanged: (value) {
                        _notifier.setNeededPosition(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      l10n.postNeededNationalities,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      l10n.postNeededNationalitiesSublabel,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (state.neededNationalities.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.space12),
                      Wrap(
                        spacing: AppTokens.space8,
                        runSpacing: AppTokens.space8,
                        children: [
                          for (final nationality in state.neededNationalities)
                            _RemovableChip(
                              label: nationality,
                              onRemove: () {
                                _notifier.removeNationality(nationality);
                                _markDirty();
                              },
                            ),
                        ],
                      ),
                    ],
                    if (state.neededNationalities.length < 5) ...[
                      const SizedBox(height: AppTokens.space12),
                      AmDropdownField<String>(
                        label: l10n.postNeededNationalities,
                        items: kCountries
                            .where((c) =>
                                !state.neededNationalities.contains(c))
                            .toList(),
                        itemLabel: (c) => c,
                        onChanged: (value) {
                          if (value == null) return;
                          _notifier.addNationality(value);
                          _markDirty();
                        },
                      ),
                    ],
                    const SizedBox(height: AppTokens.space16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AmTextField(
                            label: l10n.postNeededMinAge,
                            controller: _minAgeController,
                            keyboardType: TextInputType.number,
                            errorText: ageRangeError,
                            onChanged: (value) {
                              _notifier
                                  .setNeededMinAge(int.tryParse(value.trim()));
                              _markDirty();
                            },
                          ),
                        ),
                        const SizedBox(width: AppTokens.space16),
                        Expanded(
                          child: AmTextField(
                            label: l10n.postNeededMaxAge,
                            controller: _maxAgeController,
                            keyboardType: TextInputType.number,
                            errorText: ageRangeError,
                            onChanged: (value) {
                              _notifier
                                  .setNeededMaxAge(int.tryParse(value.trim()));
                              _markDirty();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.postNeededLeagueCountry,
                      controller: _leagueCountryController,
                      onChanged: (value) {
                        _notifier.setNeededLeagueCountry(
                          value.trim().isEmpty ? null : value.trim(),
                        );
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.postNeededBudget,
                      controller: _budgetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            end: AppTokens.space16),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            l10n.currencyEurSymbol,
                            style: const TextStyle(
                              fontSize: AppTokens.fontSizeMd,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _notifier.setBudget(
                          double.tryParse(value.trim().replaceAll(',', '')),
                        );
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space24),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: AppTokens.space24),
                    AmTextField(
                      label: l10n.postDescriptionLabel,
                      controller: _descriptionController,
                      multiline: true,
                      helperText: l10n.postNeedAPlayerDescriptionHint,
                      onChanged: (value) {
                        _notifier.setDescription(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmDatePickerField(
                      label: l10n.postExpiryLabel,
                      value: state.expiresAt,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        _notifier.setExpiresAt(value);
                        _markDirty();
                      },
                    ),
                  ],
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
                border: Border(top: BorderSide(color: dividerColor)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: AmPrimaryButton(
                    label: l10n.savePost,
                    isLoading: state.isSaving,
                    isDisabled: !state.isFormValid || state.isSaving,
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

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppTokens.space12,
        end: AppTokens.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTokens.fontSizeXs,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          AccessibleTouchTarget(
            semanticsLabel: l10n.postRemoveNationalityLabel(label),
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: AppTokens.fontSizeLg,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
