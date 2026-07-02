library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/accessible_touch_target.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../../core/widgets/am_date_picker_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_photo_upload_field.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_text_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../core/widgets/am_toggle_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../players/models/player_enums.dart';
import '../../setup/data/countries.dart';
import '../models/external_link_model.dart';
import '../providers/create_post_provider.dart';
import '../widgets/link_player_bottom_sheet.dart';

class CreatePlayerAvailablePostScreen extends ConsumerStatefulWidget {
  const CreatePlayerAvailablePostScreen({super.key});

  @override
  ConsumerState<CreatePlayerAvailablePostScreen> createState() =>
      _CreatePlayerAvailablePostScreenState();
}

class _CreatePlayerAvailablePostScreenState
    extends ConsumerState<CreatePlayerAvailablePostScreen> {
  final _descriptionController = TextEditingController();
  final _leagueCountryController = TextEditingController();
  final _ageController = TextEditingController();
  final _marketValueController = TextEditingController();
  final _transfermarktUrlController = TextEditingController();

  final List<int> _externalLinkKeys = [];
  int _nextExternalLinkKey = 0;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(createPlayerAvailablePostNotifierProvider);
    _descriptionController.text = state.description;
    for (var i = 0; i < state.externalLinks.length; i++) {
      _externalLinkKeys.add(_nextExternalLinkKey++);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _leagueCountryController.dispose();
    _ageController.dispose();
    _marketValueController.dispose();
    _transfermarktUrlController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  CreatePlayerAvailablePostNotifier get _notifier =>
      ref.read(createPlayerAvailablePostNotifierProvider.notifier);

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      _notifier.setPlayerPhotoLocalPath(image.path);
      _markDirty();
    }
  }

  Future<void> _openLinkPlayerSheet() async {
    await showLinkPlayerBottomSheet(
      context,
      onPlayerSelected: (player) {
        _notifier.linkPlayer(player);
        _leagueCountryController.text = player.leagueCountry ?? '';
        _ageController.text =
            (ref.read(createPlayerAvailablePostNotifierProvider).playerAge ?? '')
                .toString();
        _marketValueController.text =
            player.estimatedMarketValue?.toString() ?? '';
        _transfermarktUrlController.text = player.transfermarktUrl ?? '';
        _markDirty();
      },
    );
  }

  void _unlinkPlayer() {
    _notifier.unlinkPlayer();
    _leagueCountryController.clear();
    _ageController.clear();
    _marketValueController.clear();
    _transfermarktUrlController.clear();
    _markDirty();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditingButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discardButton),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onSave() async {
    await _notifier.savePost();
  }

  Future<void> _addExternalLink() async {
    _notifier.addExternalLink(const ExternalLinkModel(url: '', label: ''));
    setState(() => _externalLinkKeys.add(_nextExternalLinkKey++));
    _markDirty();
  }

  void _removeExternalLink(int index) {
    _notifier.removeExternalLink(index);
    setState(() => _externalLinkKeys.removeAt(index));
    _markDirty();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;
    final state = ref.watch(createPlayerAvailablePostNotifierProvider);

    ref.listen(createPlayerAvailablePostNotifierProvider, (previous, next) {
      if (next.isSuccess && previous?.isSuccess != true) {
        context.go('/market');
        return;
      }
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            action: SnackBarAction(
              label: l10n.retryButton,
              onPressed: _onSave,
            ),
          ),
        );
      }
    });

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.createPlayerAvailableTitle)),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LinkPlayerCard(
                      linkedPlayerName: state.linkedPlayerName,
                      position: state.playerPosition?.toFirestoreValue(),
                      photoUrl: state.playerPhotoUrl,
                      onTap: _openLinkPlayerSheet,
                      onRemove: _unlinkPlayer,
                    ),
                    const SizedBox(height: AppTokens.space24),
                    Center(
                      child: AmPhotoUploadField(
                        onTap: _pickPhoto,
                        imageUrl: state.playerPhotoLocalPath == null
                            ? state.playerPhotoUrl
                            : null,
                        semanticsLabel: l10n.photoUploadLabel,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmDropdownField<PlayerPosition>(
                      label: l10n.fieldPreferredPosition,
                      items: PlayerPosition.values,
                      itemLabel: (p) => p.toFirestoreValue(),
                      value: state.playerPosition,
                      onChanged: (value) {
                        _notifier.setPlayerPosition(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmDropdownField<String>(
                      label: l10n.fieldNationality,
                      items: kCountries,
                      itemLabel: (c) => c,
                      value: state.playerNationality,
                      onChanged: (value) {
                        _notifier.setPlayerNationality(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.fieldLeagueCountry,
                      controller: _leagueCountryController,
                      onChanged: (value) {
                        _notifier.setPlayerLeagueCountry(
                          value.trim().isEmpty ? null : value.trim(),
                        );
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.fieldAge,
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _notifier.setPlayerAge(int.tryParse(value.trim()));
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.fieldMarketValue,
                      controller: _marketValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            end: AppTokens.space16),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            l10n.currencyEur,
                            style: const TextStyle(
                              fontSize: AppTokens.fontSizeMd,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _notifier.setPlayerMarketValue(
                          double.tryParse(value.trim().replaceAll(',', '')),
                        );
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmTextField(
                      label: l10n.fieldTransfermarktUrl,
                      controller: _transfermarktUrlController,
                      keyboardType: TextInputType.url,
                      onChanged: (value) {
                        _notifier.setTransfermarktUrl(
                          value.trim().isEmpty ? null : value.trim(),
                        );
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmToggleField(
                      label: l10n.postAnonymousLabel,
                      value: state.isPlayerAnonymous,
                      onChanged: (value) {
                        _notifier.setAnonymous(value);
                        _markDirty();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          top: AppTokens.space4),
                      child: Text(
                        l10n.postAnonymousSublabel,
                        style: const TextStyle(
                          fontSize: AppTokens.fontSizeSm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: AppTokens.space24),
                    AmTextField(
                      label: l10n.postDescriptionLabel,
                      controller: _descriptionController,
                      multiline: true,
                      helperText: l10n.postDescriptionHint,
                      onChanged: (value) {
                        _notifier.setDescription(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space16),
                    AmDatePickerField(
                      label: l10n.postExpiryLabel,
                      value: state.expiresAt,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onChanged: (value) {
                        _notifier.setExpiresAt(value);
                        _markDirty();
                      },
                    ),
                    const SizedBox(height: AppTokens.space24),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: AppTokens.space24),
                    Text(
                      l10n.postExternalLinksLabel,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      l10n.postExternalLinksSublabel,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    for (var i = 0; i < state.externalLinks.length; i++) ...[
                      _ExternalLinkRow(
                        key: ValueKey(_externalLinkKeys[i]),
                        link: state.externalLinks[i],
                        onUrlChanged: (url) {
                          final link = state.externalLinks[i];
                          _notifier.updateExternalLink(
                            i,
                            ExternalLinkModel(url: url, label: link.label),
                          );
                          _markDirty();
                        },
                        onLabelChanged: (label) {
                          final link = state.externalLinks[i];
                          _notifier.updateExternalLink(
                            i,
                            ExternalLinkModel(url: link.url, label: label),
                          );
                          _markDirty();
                        },
                        onRemove: () => _removeExternalLink(i),
                      ),
                      const SizedBox(height: AppTokens.space16),
                    ],
                    if (state.externalLinks.length < 5)
                      AmTextButton(
                        label: l10n.postAddLink,
                        onPressed: _addExternalLink,
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space16,
                vertical: AppTokens.space12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                border: Border(top: BorderSide(color: dividerColor)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: AmPrimaryButton(
                    label: l10n.savePost,
                    isLoading: state.isSaving,
                    isDisabled: !state.isFormValid || state.isSaving,
                    onPressed: _onSave,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkPlayerCard extends StatelessWidget {
  const _LinkPlayerCard({
    required this.linkedPlayerName,
    required this.position,
    required this.photoUrl,
    required this.onTap,
    required this.onRemove,
  });

  final String? linkedPlayerName;
  final String? position;
  final String? photoUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLinked = linkedPlayerName != null;

    if (!isLinked) {
      return AccessibleTouchTarget(
        semanticsLabel: l10n.linkPlayerPrompt,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_add, color: AppColors.primary),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  l10n.linkPlayerPrompt,
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeMd,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Row(
        children: [
          AmAvatar(imageUrl: photoUrl, name: linkedPlayerName, size: AmAvatarSize.medium),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  linkedPlayerName!,
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (position != null)
                  Text(
                    position!,
                    style: const TextStyle(
                      fontSize: AppTokens.fontSizeSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: l10n.removeLinkedPlayerLabel,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalLinkRow extends StatefulWidget {
  const _ExternalLinkRow({
    required this.link,
    required this.onUrlChanged,
    required this.onLabelChanged,
    required this.onRemove,
    super.key,
  });

  final ExternalLinkModel link;
  final ValueChanged<String> onUrlChanged;
  final ValueChanged<String> onLabelChanged;
  final VoidCallback onRemove;

  @override
  State<_ExternalLinkRow> createState() => _ExternalLinkRowState();
}

class _ExternalLinkRowState extends State<_ExternalLinkRow> {
  late final _urlController = TextEditingController(text: widget.link.url);
  late final _labelController = TextEditingController(text: widget.link.label);

  @override
  void dispose() {
    _urlController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              AmTextField(
                label: l10n.postLinkUrl,
                controller: _urlController,
                keyboardType: TextInputType.url,
                onChanged: widget.onUrlChanged,
              ),
              const SizedBox(height: AppTokens.space8),
              AmTextField(
                label: l10n.postLinkLabel,
                controller: _labelController,
                onChanged: widget.onLabelChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.space8),
        Semantics(
          button: true,
          label: l10n.postLinkUrl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onRemove,
            ),
          ),
        ),
      ],
    );
  }
}
