/// Searchable bottom sheet for selecting a country code.
///
/// Displays flag emoji, country name, and dial code for each entry.
/// Filters by name or dial code. RTL-compatible with 44x44pt touch targets.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/country_code.dart';

/// Shows a modal bottom sheet with a searchable list of countries.
///
/// Returns the selected [CountryCode] or `null` if dismissed.
Future<CountryCode?> showCountryCodePicker({
  required BuildContext context,
  required CountryCode selected,
}) {
  return showModalBottomSheet<CountryCode>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CountryCodePickerSheet(selected: selected),
  );
}

class _CountryCodePickerSheet extends StatefulWidget {
  const _CountryCodePickerSheet({required this.selected});

  final CountryCode selected;

  @override
  State<_CountryCodePickerSheet> createState() =>
      _CountryCodePickerSheetState();
}

class _CountryCodePickerSheetState extends State<_CountryCodePickerSheet> {
  final _searchController = TextEditingController();
  List<CountryCode> _filtered = CountryCode.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = CountryCode.all;
      } else {
        _filtered = CountryCode.all.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 12, bottom: 8),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Semantics(
                label: l10n.phoneCountrySearchHint,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.phoneCountrySearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Country list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = country.code == widget.selected.code;

                  return Semantics(
                    label: '${country.name}, ${country.dialCode}',
                    selected: isSelected,
                    child: ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country.name),
                      trailing: Text(
                        country.dialCode,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      selected: isSelected,
                      minVerticalPadding: 12,
                      onTap: () => Navigator.of(context).pop(country),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
