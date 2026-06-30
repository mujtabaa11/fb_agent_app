import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_tokens.dart';

class AmDocumentListItem extends StatelessWidget {
  const AmDocumentListItem({
    required this.label,
    required this.uploadDate,
    this.fileType,
    this.onView,
    this.onDelete,
    super.key,
  });

  final String label;
  final String uploadDate;
  final String? fileType;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  IconData get _fileIcon {
    final ext = (fileType ?? '').toLowerCase();
    return switch (ext) {
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' => Icons.description,
      'jpg' || 'jpeg' || 'png' => Icons.image,
      _ => Icons.insert_drive_file,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.documentItemLabel(label, uploadDate),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppTokens.space8,
            horizontal: AppTokens.space16,
          ),
          child: Row(
            children: [
              Icon(_fileIcon, color: colorScheme.primary),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      uploadDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onView != null)
                Semantics(
                  button: true,
                  label: l10n.viewLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility_outlined),
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
