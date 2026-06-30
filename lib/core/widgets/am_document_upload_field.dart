import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AmDocumentUploadField extends StatelessWidget {
  const AmDocumentUploadField({
    required this.label,
    required this.onTap,
    this.fileName,
    this.onRemove,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final String? fileName;
  final VoidCallback? onRemove;

  IconData get _fileIcon {
    if (fileName == null) return Icons.upload_file;
    final ext = fileName!.split('.').last.toLowerCase();
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    if (fileName != null) {
      return Semantics(
        label: l10n.documentSelectedLabel(fileName!),
        child: Container(
          padding: const EdgeInsetsDirectional.all(AppTokens.space12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
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
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      fileName!,
                      style: textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                Semantics(
                  button: true,
                  label: l10n.removeDocumentLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: l10n.uploadDocumentLabel(label),
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Container(
            padding: const EdgeInsetsDirectional.all(AppTokens.space16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: colorScheme.primary),
                const SizedBox(width: AppTokens.space8),
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
