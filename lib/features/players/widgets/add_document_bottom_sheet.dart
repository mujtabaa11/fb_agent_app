library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_document_upload_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../models/document_label.dart';
import '../providers/documents_provider.dart';

class AddDocumentBottomSheet extends ConsumerStatefulWidget {
  const AddDocumentBottomSheet({required this.playerId, super.key});

  final String playerId;

  @override
  ConsumerState<AddDocumentBottomSheet> createState() =>
      _AddDocumentBottomSheetState();
}

class _AddDocumentBottomSheetState
    extends ConsumerState<AddDocumentBottomSheet> {
  final _customLabelController = TextEditingController();

  DocumentLabel? _selectedLabel;
  File? _selectedFile;
  String? _selectedFileExtension;
  String? _selectedFileName;

  String? _labelError;
  String? _customLabelError;
  String? _fileError;

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(documentsNotifierProvider(widget.playerId), (previous, next) {
      if (next.uploadSuccess && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final documentsState = ref.watch(documentsNotifierProvider(widget.playerId));
    final isUploading = documentsState.isUploading;

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
              l10n.addDocumentTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.space16),
            AmDropdownField<DocumentLabel>(
              label: l10n.documentLabelField,
              items: DocumentLabel.selectableOptions,
              itemLabel: (label) => _displayNameFor(l10n, label),
              value: _selectedLabel,
              errorText: _labelError,
              enabled: !isUploading,
              onChanged: (value) => setState(() {
                _selectedLabel = value;
                _labelError = null;
              }),
            ),
            if (_selectedLabel == DocumentLabel.other) ...[
              const SizedBox(height: AppTokens.space16),
              AmTextField(
                label: l10n.documentCustomLabelField,
                controller: _customLabelController,
                helperText: l10n.documentCustomLabelHint,
                errorText: _customLabelError,
                enabled: !isUploading,
                onChanged: (_) => setState(() => _customLabelError = null),
              ),
            ],
            const SizedBox(height: AppTokens.space16),
            AmDocumentUploadField(
              label: l10n.documentFileField,
              fileName: _selectedFileName,
              onTap: isUploading ? () {} : _pickFile,
              onRemove: isUploading
                  ? null
                  : () => setState(() {
                        _selectedFile = null;
                        _selectedFileExtension = null;
                        _selectedFileName = null;
                      }),
            ),
            if (_fileError != null) ...[
              const SizedBox(height: AppTokens.space4),
              Text(
                _fileError!,
                style: TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppTokens.space24),
            AmPrimaryButton(
              label: l10n.uploadDocument,
              isLoading: isUploading,
              onPressed: isUploading ? null : _submit,
            ),
            if (documentsState.errorMessage != null) ...[
              const SizedBox(height: AppTokens.space8),
              Text(
                _resolveErrorMessage(l10n, documentsState.errorMessage!),
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _displayNameFor(AppLocalizations l10n, DocumentLabel label) {
    return switch (label) {
      DocumentLabel.passport => l10n.labelPassport,
      DocumentLabel.contract => l10n.labelContract,
      DocumentLabel.representationAgreement =>
        l10n.labelRepresentationAgreement,
      DocumentLabel.medicalCertificate => l10n.labelMedicalCertificate,
      DocumentLabel.workPermit => l10n.labelWorkPermit,
      DocumentLabel.visa => l10n.labelVisa,
      DocumentLabel.transferAgreement => l10n.labelTransferAgreement,
      DocumentLabel.releaseLetter => l10n.labelReleaseLetter,
      DocumentLabel.insurance => l10n.labelInsurance,
      DocumentLabel.other => l10n.labelOther,
    };
  }

  String _resolveErrorMessage(AppLocalizations l10n, String errorMessage) {
    return switch (errorMessage) {
      'documentFileTypeInvalid' => l10n.documentFileTypeInvalid,
      'documentFileTooLarge' => l10n.documentFileTooLarge,
      _ => l10n.documentUploadError,
    };
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    final fileName = result!.files.single.name;
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    setState(() {
      _selectedFile = File(path);
      _selectedFileExtension = extension;
      _selectedFileName = fileName;
      _fileError = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    var isValid = true;

    setState(() {
      _labelError = null;
      _customLabelError = null;
      _fileError = null;

      if (_selectedLabel == null) {
        _labelError = l10n.documentLabelField;
        isValid = false;
      }

      if (_selectedLabel == DocumentLabel.other &&
          _customLabelController.text.trim().isEmpty) {
        _customLabelError = l10n.documentCustomLabelField;
        isValid = false;
      }

      if (_selectedFile == null || _selectedFileExtension == null) {
        _fileError = l10n.documentFileField;
        isValid = false;
      }
    });

    if (!isValid) return;

    ref.read(documentsNotifierProvider(widget.playerId).notifier).uploadDocument(
          playerId: widget.playerId,
          selectedLabel: _selectedLabel!,
          customLabel: _customLabelController.text.trim(),
          file: _selectedFile!,
          fileExtension: _selectedFileExtension!,
        );
  }
}
