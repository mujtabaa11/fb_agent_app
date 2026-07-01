library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../models/player_note_model.dart';
import '../providers/notes_provider.dart';

class AddEditNoteBottomSheet extends ConsumerStatefulWidget {
  const AddEditNoteBottomSheet({
    required this.playerId,
    this.existingNote,
    super.key,
  });

  final String playerId;
  final PlayerNoteModel? existingNote;

  bool get isEditMode => existingNote != null;

  @override
  ConsumerState<AddEditNoteBottomSheet> createState() =>
      _AddEditNoteBottomSheetState();
}

class _AddEditNoteBottomSheetState
    extends ConsumerState<AddEditNoteBottomSheet> {
  late final TextEditingController _contentController =
      TextEditingController(text: widget.existingNote?.content ?? '');

  String? _contentError;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(notesNotifierProvider(widget.playerId), (previous, next) {
      if (next.saveSuccess && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final notesState = ref.watch(notesNotifierProvider(widget.playerId));
    final isSaving = notesState.isSaving;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppTokens.space16,
        end: AppTokens.space16,
        top: AppTokens.space12,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.space16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              widget.isEditMode ? l10n.editNoteTitle : l10n.addNoteTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.noteContentField,
              helperText: l10n.noteContentHint,
              controller: _contentController,
              errorText: _contentError,
              multiline: true,
              enabled: !isSaving,
              onChanged: (_) => setState(() => _contentError = null),
            ),
            const SizedBox(height: AppTokens.space24),
            AmPrimaryButton(
              label: widget.isEditMode ? l10n.updateNote : l10n.saveNote,
              isLoading: isSaving,
              onPressed: isSaving ? null : _submit,
            ),
            if (notesState.errorMessage != null) ...[
              const SizedBox(height: AppTokens.space8),
              Text(
                _resolveErrorMessage(l10n),
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resolveErrorMessage(AppLocalizations l10n) {
    return widget.isEditMode ? l10n.noteUpdateError : l10n.noteAddError;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      setState(() => _contentError = l10n.validationNoteEmpty);
      return;
    }

    final notifier = ref.read(notesNotifierProvider(widget.playerId).notifier);
    if (widget.isEditMode) {
      notifier.updateNote(
        playerId: widget.playerId,
        existingNote: widget.existingNote!,
        newContent: content,
      );
    } else {
      notifier.addNote(playerId: widget.playerId, content: content);
    }
  }
}
