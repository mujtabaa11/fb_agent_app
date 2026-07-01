library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../models/family_contact_model.dart';
import '../providers/family_contacts_provider.dart';

class AddEditContactBottomSheet extends ConsumerStatefulWidget {
  const AddEditContactBottomSheet({
    required this.playerId,
    this.existingContact,
    super.key,
  });

  final String playerId;
  final FamilyContactModel? existingContact;

  bool get isEditMode => existingContact != null;

  @override
  ConsumerState<AddEditContactBottomSheet> createState() =>
      _AddEditContactBottomSheetState();
}

class _AddEditContactBottomSheetState
    extends ConsumerState<AddEditContactBottomSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.existingContact?.name ?? '');
  late final TextEditingController _relationshipController =
      TextEditingController(text: widget.existingContact?.relationship ?? '');
  late final TextEditingController _phoneController =
      TextEditingController(text: widget.existingContact?.phoneNumber ?? '');
  late final TextEditingController _emailController =
      TextEditingController(text: widget.existingContact?.email ?? '');

  String? _nameError;
  String? _relationshipError;
  String? _phoneError;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(familyContactsNotifierProvider(widget.playerId),
        (previous, next) {
      if (next.saveSuccess && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final contactsState =
        ref.watch(familyContactsNotifierProvider(widget.playerId));
    final isSaving = contactsState.isSaving;

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
              widget.isEditMode ? l10n.editContactTitle : l10n.addContactTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.fieldName,
              controller: _nameController,
              errorText: _nameError,
              enabled: !isSaving,
              onChanged: (_) => setState(() => _nameError = null),
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.fieldRelationship,
              helperText: l10n.fieldRelationshipHint,
              controller: _relationshipController,
              errorText: _relationshipError,
              enabled: !isSaving,
              onChanged: (_) => setState(() => _relationshipError = null),
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.fieldPhoneNumber,
              controller: _phoneController,
              errorText: _phoneError,
              keyboardType: TextInputType.phone,
              enabled: !isSaving,
              onChanged: (_) => setState(() => _phoneError = null),
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.fieldEmail,
              controller: _emailController,
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
              enabled: !isSaving,
              onChanged: (_) => setState(() => _emailError = null),
            ),
            const SizedBox(height: AppTokens.space24),
            AmPrimaryButton(
              label: widget.isEditMode ? l10n.updateContact : l10n.saveContact,
              isLoading: isSaving,
              onPressed: isSaving ? null : _submit,
            ),
            if (contactsState.errorMessage != null) ...[
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
    return widget.isEditMode ? l10n.contactUpdateError : l10n.contactAddError;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final relationship = _relationshipController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final email = _emailController.text.trim();

    var hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = l10n.validationRequired);
      hasError = true;
    }
    if (relationship.isEmpty) {
      setState(() => _relationshipError = l10n.validationRequired);
      hasError = true;
    }
    if (phoneNumber.isEmpty) {
      setState(() => _phoneError = l10n.validationRequired);
      hasError = true;
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _emailError = l10n.validationEmailInvalid);
      hasError = true;
    }

    if (hasError) return;

    final notifier =
        ref.read(familyContactsNotifierProvider(widget.playerId).notifier);
    if (widget.isEditMode) {
      notifier.updateContact(
        playerId: widget.playerId,
        existingContact: widget.existingContact!,
        name: name,
        relationship: relationship,
        phoneNumber: phoneNumber,
        email: email.isEmpty ? null : email,
      );
    } else {
      notifier.addContact(
        playerId: widget.playerId,
        name: name,
        relationship: relationship,
        phoneNumber: phoneNumber,
        email: email.isEmpty ? null : email,
      );
    }
  }
}
