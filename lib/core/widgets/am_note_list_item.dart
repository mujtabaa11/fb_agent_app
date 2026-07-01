import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_tokens.dart';

class AmNoteListItem extends StatelessWidget {
  const AmNoteListItem({
    required this.content,
    required this.timestamp,
    this.isEdited = false,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final String content;
  final String timestamp;
  final bool isEdited;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.noteItemLabel(content),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppTokens.space8,
            horizontal: AppTokens.space16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      isEdited ? '$timestamp · ${l10n.noteEditedLabel}' : timestamp,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                Semantics(
                  button: true,
                  label: l10n.editLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
              if (onDelete != null)
                Semantics(
                  button: true,
                  label: l10n.deleteLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
