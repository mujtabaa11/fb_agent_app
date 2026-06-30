import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../../core/widgets/am_conversation_card.dart';
import '../../../core/widgets/am_currency_amount_field.dart';
import '../../../core/widgets/am_date_picker_field.dart';
import '../../../core/widgets/am_destructive_button.dart';
import '../../../core/widgets/am_document_list_item.dart';
import '../../../core/widgets/am_document_upload_field.dart';
import '../../../core/widgets/am_dropdown_field.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_family_contact_list_item.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_note_list_item.dart';
import '../../../core/widgets/am_photo_upload_field.dart';
import '../../../core/widgets/am_player_card.dart';
import '../../../core/widgets/am_post_card.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_button.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../core/widgets/am_toggle_field.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  String? _selectedPosition;
  DateTime? _selectedDate;
  String _selectedCurrency = 'EUR';
  bool _toggleValue = false;
  bool _toggle2Value = true;
  String? _selectedDocFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.showcaseTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        children: [
          _sectionHeader(textTheme, l10n.showcaseCards),

          AmPlayerCard(
            fullName: 'Mohamed Salah',
            position: 'Forward',
            currentClub: 'Liverpool FC',
            statusLabel: l10n.statusActiveClient,
            statusBackgroundColor:
                isDark ? AppColors.successSurfaceDark : AppColors.successSurface,
            statusTextColor: isDark ? AppColors.successDark : AppColors.success,
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space12),

          AmPlayerCard(
            fullName: 'Achraf Hakimi',
            position: 'Right Back',
            currentClub: 'Paris Saint-Germain',
            statusLabel: l10n.statusProspect,
            statusBackgroundColor:
                isDark ? AppColors.warningSurfaceDark : AppColors.warningSurface,
            statusTextColor: isDark ? AppColors.warningDark : AppColors.warning,
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space12),

          AmPlayerCard(
            fullName: 'Sadio Mané',
            position: 'Forward',
            currentClub: 'Al Nassr',
            statusLabel: l10n.statusFormerClient,
            statusBackgroundColor:
                isDark ? AppColors.errorSurfaceDark : AppColors.errorSurface,
            statusTextColor: isDark ? AppColors.errorDark : AppColors.error,
          ),
          const SizedBox(height: AppTokens.space24),

          AmPostCard(
            postTypeBadgeLabel: l10n.postTypePlayerAvailable,
            postTypeBadgeBackgroundColor:
                isDark ? AppColors.successSurfaceDark : AppColors.successSurface,
            postTypeBadgeTextColor:
                isDark ? AppColors.successDark : AppColors.success,
            detailsLine: 'Striker · Nigerian · 24 years',
            descriptionPreview:
                'Talented young striker looking for a move to a top European league. Currently playing in the Belgian Pro League with 15 goals this season.',
            agentName: 'Ahmed Hassan',
            postedDate: '2 days ago',
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space12),

          AmPostCard(
            postTypeBadgeLabel: l10n.postTypeNeedPlayer,
            postTypeBadgeBackgroundColor:
                isDark ? AppColors.primarySurface.withAlpha(40) : AppColors.primarySurface,
            postTypeBadgeTextColor: AppColors.primary,
            detailsLine: 'Central Midfielder · Budget €5M',
            descriptionPreview:
                'Looking for an experienced central midfielder for a La Liga club. Must have European experience and be under 28.',
            agentName: 'Carlos Rodriguez',
            postedDate: '5 hours ago',
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space24),

          AmConversationCard(
            agentName: 'Ahmed Hassan',
            lastMessage: 'Yes, the player is available for a loan deal.',
            timestamp: '10:30 AM',
            unreadCount: 3,
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space12),

          AmConversationCard(
            agentName: 'Carlos Rodriguez',
            lastMessage: 'Thank you for the information. I will get back to you.',
            timestamp: 'Yesterday',
            onTap: () {},
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseFormElements),

          AmTextField(
            label: 'Player Name',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: AppTokens.space16),

          AmTextField(
            label: 'Notes',
            helperText: 'Optional scouting notes',
            multiline: true,
          ),
          const SizedBox(height: AppTokens.space16),

          AmTextField(
            label: 'Email',
            errorText: 'Please enter a valid email address',
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: AppTokens.space16),

          AmDropdownField<String>(
            label: 'Position',
            value: _selectedPosition,
            items: const ['Forward', 'Midfielder', 'Defender', 'Goalkeeper'],
            itemLabel: (p) => p,
            onChanged: (v) => setState(() => _selectedPosition = v),
          ),
          const SizedBox(height: AppTokens.space16),

          AmDatePickerField(
            label: 'Date of Birth',
            value: _selectedDate,
            onChanged: (d) => setState(() => _selectedDate = d),
            lastDate: DateTime.now(),
          ),
          const SizedBox(height: AppTokens.space16),

          AmCurrencyAmountField(
            amountLabel: 'Market Value',
            currencies: const ['EUR', 'USD', 'GBP', 'SAR'],
            selectedCurrency: _selectedCurrency,
            onCurrencyChanged: (c) =>
                setState(() => _selectedCurrency = c ?? _selectedCurrency),
          ),
          const SizedBox(height: AppTokens.space16),

          Center(
            child: AmPhotoUploadField(
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppTokens.space16),

          AmDocumentUploadField(
            label: 'Upload Contract',
            onTap: () =>
                setState(() => _selectedDocFile = 'player_contract.pdf'),
          ),
          const SizedBox(height: AppTokens.space12),

          AmDocumentUploadField(
            label: 'Upload Contract',
            fileName: _selectedDocFile,
            onTap: () {},
            onRemove: () => setState(() => _selectedDocFile = null),
          ),
          const SizedBox(height: AppTokens.space16),

          AmToggleField(
            label: 'FIFA Registered',
            value: _toggleValue,
            onChanged: (v) => setState(() => _toggleValue = v),
          ),
          AmToggleField(
            label: 'Available on WhatsApp',
            value: _toggle2Value,
            onChanged: (v) => setState(() => _toggle2Value = v),
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseButtons),

          AmPrimaryButton(
            label: 'Save Player',
            onPressed: () {},
          ),
          const SizedBox(height: AppTokens.space12),
          AmPrimaryButton(
            label: 'Saving...',
            onPressed: () {},
            isLoading: true,
          ),
          const SizedBox(height: AppTokens.space12),
          AmPrimaryButton(
            label: 'Save Player',
            onPressed: () {},
            isDisabled: true,
          ),
          const SizedBox(height: AppTokens.space16),

          AmSecondaryButton(
            label: 'Add to Watchlist',
            onPressed: () {},
          ),
          const SizedBox(height: AppTokens.space12),
          AmSecondaryButton(
            label: 'Add to Watchlist',
            onPressed: () {},
            isDisabled: true,
          ),
          const SizedBox(height: AppTokens.space16),

          AmDestructiveButton(
            label: 'Remove Player',
            onPressed: () {},
          ),
          const SizedBox(height: AppTokens.space12),
          AmDestructiveButton(
            label: 'Delete Account',
            onPressed: () {},
            filled: true,
          ),
          const SizedBox(height: AppTokens.space16),

          AmTextButton(
            label: 'Cancel',
            onPressed: () {},
          ),
          const SizedBox(height: AppTokens.space12),
          AmTextButton(
            label: 'Skip for now',
            onPressed: () {},
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseListItems),

          AmFamilyContactListItem(
            name: 'Sarah Johnson',
            relationship: 'Mother',
            phoneNumber: '+44 7700 900000',
            onEdit: () {},
            onDelete: () {},
          ),
          const Divider(height: 1),
          AmFamilyContactListItem(
            name: 'James Johnson',
            relationship: 'Brother',
            phoneNumber: '+44 7700 900001',
            onEdit: () {},
            onDelete: () {},
          ),
          const SizedBox(height: AppTokens.space16),

          AmDocumentListItem(
            label: 'Player Contract 2024',
            uploadDate: 'Jun 15, 2024',
            fileType: 'pdf',
            onView: () {},
            onDelete: () {},
          ),
          const Divider(height: 1),
          AmDocumentListItem(
            label: 'Medical Certificate',
            uploadDate: 'May 20, 2024',
            fileType: 'jpg',
            onView: () {},
            onDelete: () {},
          ),
          const SizedBox(height: AppTokens.space16),

          AmNoteListItem(
            content:
                'Met with the player today. He is very interested in a move to the Premier League. Will follow up next week.',
            timestamp: 'Jun 28, 2024 · 3:45 PM',
            onEdit: () {},
            onDelete: () {},
          ),
          const Divider(height: 1),
          AmNoteListItem(
            content: 'Contract negotiations ongoing with Club X.',
            timestamp: 'Jun 25, 2024 · 11:00 AM',
            onEdit: () {},
            onDelete: () {},
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseAvatars),

          Wrap(
            spacing: AppTokens.space16,
            runSpacing: AppTokens.space16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmAvatar(size: AmAvatarSize.small, name: 'MS'),
                  const SizedBox(height: AppTokens.space4),
                  Text('Small', style: textTheme.bodySmall),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmAvatar(size: AmAvatarSize.medium, name: 'Ahmed Hassan'),
                  const SizedBox(height: AppTokens.space4),
                  Text('Medium', style: textTheme.bodySmall),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmAvatar(size: AmAvatarSize.large, name: 'Carlos R'),
                  const SizedBox(height: AppTokens.space4),
                  Text('Large', style: textTheme.bodySmall),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmAvatar(size: AmAvatarSize.medium),
                  const SizedBox(height: AppTokens.space4),
                  Text('No name', style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseBadges),

          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: [
              AmStatusBadge(
                label: l10n.statusActiveClient,
                backgroundColor: isDark
                    ? AppColors.successSurfaceDark
                    : AppColors.successSurface,
                textColor: isDark ? AppColors.successDark : AppColors.success,
              ),
              AmStatusBadge(
                label: l10n.statusProspect,
                backgroundColor: isDark
                    ? AppColors.warningSurfaceDark
                    : AppColors.warningSurface,
                textColor: isDark ? AppColors.warningDark : AppColors.warning,
              ),
              AmStatusBadge(
                label: l10n.statusFormerClient,
                backgroundColor:
                    isDark ? AppColors.errorSurfaceDark : AppColors.errorSurface,
                textColor: isDark ? AppColors.errorDark : AppColors.error,
              ),
              AmStatusBadge(
                label: l10n.postTypePlayerAvailable,
                backgroundColor: isDark
                    ? AppColors.successSurfaceDark
                    : AppColors.successSurface,
                textColor: isDark ? AppColors.successDark : AppColors.success,
              ),
              AmStatusBadge(
                label: l10n.postTypeNeedPlayer,
                backgroundColor: isDark
                    ? AppColors.primarySurface.withAlpha(40)
                    : AppColors.primarySurface,
                textColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseEmptyStates),

          AmEmptyState(
            icon: Icons.people_outline,
            title: l10n.emptyPlayersTitle,
            subtitle: l10n.emptyPlayersSubtitle,
            actionLabel: 'Add Player',
            onAction: () {},
          ),
          const SizedBox(height: AppTokens.space32),

          _sectionHeader(textTheme, l10n.showcaseFeedback),

          Text('Loading Skeleton — Card',
              style: textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.card),
          const SizedBox(height: AppTokens.space16),

          Text('Loading Skeleton — List Item',
              style: textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
          const SizedBox(height: AppTokens.space8),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
          const SizedBox(height: AppTokens.space16),

          Text('Error State', style: textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () {},
          ),

          const SizedBox(height: AppTokens.space64),
        ],
      ),
    );
  }

  Widget _sectionHeader(TextTheme textTheme, String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: AppTokens.space16,
        top: AppTokens.space8,
      ),
      child: Text(
        title,
        style: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
