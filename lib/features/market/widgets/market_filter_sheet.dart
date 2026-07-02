library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../players/models/player_enums.dart';
import '../../setup/data/countries.dart';
import '../models/market_post_enums.dart';
import '../providers/market_feed_provider.dart';

const List<int> kMarketMaxAgeOptions = [21, 23, 25, 28, 30];
const List<double> kMarketMaxValueOptions = [
  500000,
  1000000,
  2000000,
  5000000,
  10000000,
];

String marketMaxValueChipLabel(double value) {
  if (value >= 1000000) {
    final millions = value / 1000000;
    final formatted =
        millions == millions.roundToDouble() ? millions.toInt() : millions;
    return '€${formatted}M';
  }
  return '€${(value / 1000).toInt()}K';
}

Future<void> showMarketFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.vertical(
        top: Radius.circular(AppTokens.radiusLg),
      ),
    ),
    builder: (context) => const _MarketFilterSheetContent(),
  );
}

class _MarketFilterSheetContent extends ConsumerWidget {
  const _MarketFilterSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(marketFeedFilterProvider);
    final notifier = ref.read(marketFeedFilterProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppTokens.space16,
          end: AppTokens.space16,
          top: AppTokens.space16,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.space16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.marketFilterTitle,
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeXl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space24),
              _FilterSectionLabel(text: l10n.marketFilterPostType),
              const SizedBox(height: AppTokens.space8),
              _ChipRow(
                children: [
                  _FilterChip(
                    label: l10n.marketFilterAny,
                    isSelected: filter.postType == null,
                    onTap: () => notifier.setPostType(null),
                  ),
                  _FilterChip(
                    label: l10n.postTypePlayerAvailable,
                    isSelected: filter.postType == MarketPostType.playerAvailable,
                    onTap: () =>
                        notifier.setPostType(MarketPostType.playerAvailable),
                  ),
                  _FilterChip(
                    label: l10n.postTypeNeedPlayer,
                    isSelected: filter.postType == MarketPostType.needAPlayer,
                    onTap: () =>
                        notifier.setPostType(MarketPostType.needAPlayer),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),
              _FilterSectionLabel(text: l10n.marketFilterPosition),
              const SizedBox(height: AppTokens.space8),
              _ChipRow(
                children: [
                  _FilterChip(
                    label: l10n.marketFilterAny,
                    isSelected: filter.position == null,
                    onTap: () => notifier.setPosition(null),
                  ),
                  for (final position in PlayerPosition.values)
                    _FilterChip(
                      label: position.toFirestoreValue(),
                      isSelected: filter.position == position,
                      onTap: () => notifier.setPosition(position),
                    ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),
              AmDropdownField<String>(
                label: l10n.marketFilterNationality,
                items: [l10n.marketFilterAny, ...kCountries],
                itemLabel: (c) => c,
                value: filter.nationality ?? l10n.marketFilterAny,
                onChanged: (value) => notifier.setNationality(
                  value == l10n.marketFilterAny ? null : value,
                ),
              ),
              const SizedBox(height: AppTokens.space24),
              _FilterSectionLabel(text: l10n.marketFilterMaxAge),
              const SizedBox(height: AppTokens.space8),
              _ChipRow(
                children: [
                  for (final age in kMarketMaxAgeOptions)
                    _FilterChip(
                      label: l10n.marketFilterMaxAgeOption(age),
                      isSelected: filter.maxAge == age,
                      onTap: () => notifier.setMaxAge(age),
                    ),
                  _FilterChip(
                    label: l10n.marketFilterAny,
                    isSelected: filter.maxAge == null,
                    onTap: () => notifier.setMaxAge(null),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),
              _FilterSectionLabel(text: l10n.marketFilterMaxValue),
              const SizedBox(height: AppTokens.space8),
              _ChipRow(
                children: [
                  for (final value in kMarketMaxValueOptions)
                    _FilterChip(
                      label: marketMaxValueChipLabel(value),
                      isSelected: filter.maxMarketValue == value,
                      onTap: () => notifier.setMaxMarketValue(value),
                    ),
                  _FilterChip(
                    label: l10n.marketFilterAny,
                    isSelected: filter.maxMarketValue == null,
                    onTap: () => notifier.setMaxMarketValue(null),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space24),
              Row(
                children: [
                  AmTextButton(
                    label: l10n.marketFilterClearAll,
                    onPressed: () {
                      notifier.clearAllFilters();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  AmPrimaryButton(
                    label: l10n.marketFilterApply,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSectionLabel extends StatelessWidget {
  const _FilterSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppTokens.fontSizeMd,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTokens.space8,
      runSpacing: AppTokens.space8,
      children: children,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AccessibleTouchTarget(
      semanticsLabel: label,
      onTap: onTap,
      child: AmStatusBadge(
        label: label,
        backgroundColor:
            isSelected ? AppColors.primary : AppColors.surfaceAlt,
        textColor: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
      ),
    );
  }
}
