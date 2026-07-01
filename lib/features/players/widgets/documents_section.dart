library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_document_list_item.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/player_document_model.dart';
import '../providers/documents_provider.dart';
import '../providers/player_profile_provider.dart';
import 'add_document_bottom_sheet.dart';

class DocumentsSection extends ConsumerWidget {
  const DocumentsSection({required this.playerId, super.key});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final docsAsync = ref.watch(playerDocumentsProvider(playerId));
    final dateFormat = DateFormat('dd MMM yyyy');

    ref.listen(documentsNotifierProvider(playerId), (previous, next) {
      final deleteFailed = previous?.isDeleting == true &&
          !next.isDeleting &&
          next.errorMessage != null;
      if (deleteFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.documentDeleteError)),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border),
        const SizedBox(height: AppTokens.space12),
        Text(
          l10n.documentsSection,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        docsAsync.when(
          loading: () => const AmLoadingSkeleton(
            variant: AmSkeletonVariant.listItem,
          ),
          error: (_, __) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () => ref.invalidate(playerDocumentsProvider(playerId)),
          ),
          data: (docs) {
            if (docs.isEmpty) {
              return AmEmptyState(
                icon: Icons.folder_outlined,
                title: l10n.emptyDocumentsTitle,
                subtitle: l10n.emptyDocumentsMessage,
              );
            }
            return Column(
              children: docs
                  .map(
                    (doc) => AmDocumentListItem(
                      label: doc.label,
                      uploadDate: dateFormat.format(doc.uploadedAt),
                      fileType: doc.fileType,
                      onView: () => launchUrl(
                        Uri.parse(doc.fileUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      onDelete: () =>
                          _confirmDelete(context, ref, l10n, doc),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: AppTokens.space12),
        AmSecondaryButton(
          label: l10n.addDocument,
          onPressed: () => _openAddDocumentSheet(context),
        ),
        const SizedBox(height: AppTokens.space16),
      ],
    );
  }

  void _openAddDocumentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddDocumentBottomSheet(playerId: playerId),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    PlayerDocumentModel document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteDocumentTitle),
        content: Text(l10n.deleteDocumentMessage),
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
        .read(documentsNotifierProvider(playerId).notifier)
        .deleteDocument(playerId: playerId, document: document);
  }
}
