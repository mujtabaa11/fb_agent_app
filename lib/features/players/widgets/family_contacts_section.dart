library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_family_contact_list_item.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/family_contact_model.dart';
import '../providers/family_contacts_provider.dart';
import '../providers/player_profile_provider.dart';
import 'add_edit_contact_bottom_sheet.dart';

class FamilyContactsSection extends ConsumerWidget {
  const FamilyContactsSection({required this.playerId, super.key});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final contactsAsync = ref.watch(familyContactsProvider(playerId));

    ref.listen(familyContactsNotifierProvider(playerId), (previous, next) {
      final deleteFailed = previous?.isDeleting == true &&
          !next.isDeleting &&
          next.errorMessage != null;
      if (deleteFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactDeleteError)),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border),
        const SizedBox(height: AppTokens.space12),
        Text(
          l10n.playerSectionFamily,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        contactsAsync.when(
          loading: () => const AmLoadingSkeleton(
            variant: AmSkeletonVariant.listItem,
          ),
          error: (_, __) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () => ref.invalidate(familyContactsProvider(playerId)),
          ),
          data: (contacts) {
            if (contacts.isEmpty) {
              return AmEmptyState(
                icon: Icons.people_outline,
                title: l10n.playerNoFamilyContacts,
                subtitle: '',
              );
            }
            return Column(
              children: contacts
                  .map(
                    (contact) => AmFamilyContactListItem(
                      name: contact.name,
                      relationship: contact.relationship,
                      phoneNumber: contact.phoneNumber,
                      onEdit: () => _openEditContactSheet(context, contact),
                      onDelete: () =>
                          _confirmDelete(context, ref, l10n, contact),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppTokens.space12),
        AmSecondaryButton(
          label: l10n.addContact,
          onPressed: () => _openAddContactSheet(context),
        ),
        const SizedBox(height: AppTokens.space16),
      ],
    );
  }

  void _openAddContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditContactBottomSheet(playerId: playerId),
    );
  }

  void _openEditContactSheet(
    BuildContext context,
    FamilyContactModel contact,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditContactBottomSheet(
        playerId: playerId,
        existingContact: contact,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FamilyContactModel contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteContactTitle),
        content: Text(l10n.deleteContactMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(familyContactsNotifierProvider(playerId).notifier)
        .deleteContact(playerId: playerId, contactId: contact.id);
  }
}
