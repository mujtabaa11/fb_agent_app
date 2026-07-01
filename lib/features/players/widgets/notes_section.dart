library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_note_list_item.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/player_note_model.dart';
import '../providers/notes_provider.dart';
import '../providers/player_profile_provider.dart';
import 'add_edit_note_bottom_sheet.dart';

class NotesSection extends ConsumerWidget {
  const NotesSection({required this.playerId, super.key});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final notesAsync = ref.watch(playerNotesProvider(playerId));
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    ref.listen(notesNotifierProvider(playerId), (previous, next) {
      final deleteFailed = previous?.isDeleting == true &&
          !next.isDeleting &&
          next.errorMessage != null;
      if (deleteFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noteDeleteError)),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border),
        const SizedBox(height: AppTokens.space12),
        Text(
          l10n.notesSection,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        notesAsync.when(
          loading: () => const AmLoadingSkeleton(
            variant: AmSkeletonVariant.listItem,
          ),
          error: (_, __) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () => ref.invalidate(playerNotesProvider(playerId)),
          ),
          data: (notes) {
            if (notes.isEmpty) {
              return AmEmptyState(
                icon: Icons.note_outlined,
                title: l10n.emptyNotesTitle,
                subtitle: l10n.emptyNotesMessage,
              );
            }
            return Column(
              children: notes
                  .map(
                    (note) => AmNoteListItem(
                      content: note.content,
                      timestamp: note.createdAt != null
                          ? dateFormat.format(note.createdAt!)
                          : '',
                      isEdited: note.isEdited,
                      onEdit: () => _openEditNoteSheet(context, note),
                      onDelete: () =>
                          _confirmDelete(context, ref, l10n, note),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppTokens.space12),
        AmSecondaryButton(
          label: l10n.addNote,
          onPressed: () => _openAddNoteSheet(context),
        ),
        const SizedBox(height: AppTokens.space16),
      ],
    );
  }

  void _openAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditNoteBottomSheet(playerId: playerId),
    );
  }

  void _openEditNoteSheet(BuildContext context, PlayerNoteModel note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AddEditNoteBottomSheet(playerId: playerId, existingNote: note),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    PlayerNoteModel note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNoteTitle),
        content: Text(l10n.deleteNoteMessage),
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
        .read(notesNotifierProvider(playerId).notifier)
        .deleteNote(playerId: playerId, noteId: note.id);
  }
}
