library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../../core/widgets/am_destructive_button.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_family_contact_list_item.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_note_list_item.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/data/result.dart';
import '../models/player_enums.dart';
import '../models/player_model.dart';
import '../providers/player_profile_provider.dart';
import '../providers/player_providers.dart';
import '../widgets/documents_section.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({required this.playerId, super.key});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProfileProvider(playerId));
    final l10n = AppLocalizations.of(context)!;

    return playerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.playerProfileTitle)),
        body: const _ProfileLoadingSkeleton(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.playerProfileTitle)),
        body: AmErrorState(
          message: l10n.errorLoadingData,
          onRetry: () => ref.invalidate(playerProfileProvider(playerId)),
        ),
      ),
      data: (player) {
        if (player == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.playerProfileTitle)),
            body: AmEmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.playerNotFound,
              subtitle: l10n.playerNotFoundBody,
              actionLabel: l10n.playerProfileBack,
              onAction: () => context.go('/players'),
            ),
          );
        }

        return _PlayerProfileBody(
          player: player,
          playerId: playerId,
        );
      },
    );
  }
}

class _PlayerProfileBody extends ConsumerWidget {
  const _PlayerProfileBody({
    required this.player,
    required this.playerId,
  });

  final PlayerModel player;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderArea(context, textTheme, l10n),
                  const SizedBox(height: AppTokens.space24),
                  _IdentitySection(player: player),
                  _FootballDetailsSection(player: player),
                  _RepresentationSection(player: player),
                  _ContractFinancialSection(player: player),
                  _ContactSection(player: player),
                  _FamilyContactsSection(playerId: playerId),
                  DocumentsSection(playerId: playerId),
                  _NotesSection(playerId: playerId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final hasPhoto = player.photoUrl != null && player.photoUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      title: Text(player.fullName),
      actions: [
        Semantics(
          button: true,
          label: l10n.playerProfileEdit,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.playerProfileEdit,
              onPressed: () => context.go('/players/$playerId/edit'),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: l10n.playerProfileDelete,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.playerProfileDelete,
              onPressed: () => _showDeleteDialog(context, ref, l10n),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasPhoto
            ? Image.network(
                player.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _avatarFallback(),
              )
            : _avatarFallback(),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.primarySurface,
      alignment: Alignment.center,
      child: AmAvatar(
        name: player.fullName,
        size: AmAvatarSize.large,
      ),
    );
  }

  Widget _buildHeaderArea(
      BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player.fullName,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTokens.space8),
        Wrap(
          spacing: AppTokens.space8,
          runSpacing: AppTokens.space8,
          children: [
            _buildStatusBadge(player.status, l10n),
            AmStatusBadge(
              label: player.preferredPosition.toFirestoreValue(),
              backgroundColor: AppColors.primarySurface,
              textColor: AppColors.primary,
            ),
          ],
        ),
        if (player.currentClub != null || player.leagueCountry != null) ...[
          const SizedBox(height: AppTokens.space8),
          Text(
            [player.currentClub, player.leagueCountry]
                .where((e) => e != null && e.isNotEmpty)
                .join(' · '),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  AmStatusBadge _buildStatusBadge(PlayerStatus status, AppLocalizations l10n) {
    return switch (status) {
      PlayerStatus.activeClient => AmStatusBadge(
          label: l10n.statusActiveClient,
          backgroundColor: AppColors.successSurface,
          textColor: AppColors.success,
        ),
      PlayerStatus.prospect => AmStatusBadge(
          label: l10n.statusProspect,
          backgroundColor: AppColors.primarySurface,
          textColor: AppColors.primary,
        ),
      PlayerStatus.formerClient => AmStatusBadge(
          label: l10n.statusFormerClient,
          backgroundColor: AppColors.surfaceAlt,
          textColor: AppColors.textSecondary,
        ),
    };
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.playerDeleteTitle),
        content: Text(l10n.playerDeleteConfirmation),
        actions: [
          AmTextButton(
            label: l10n.playerDeleteCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AmDestructiveButton(
            label: l10n.playerDeleteConfirm,
            filled: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.deletePlayer(playerId);

    if (!context.mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.playerDeleteSuccess)),
        );
        context.go('/players');
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Profile sections
// ---------------------------------------------------------------------------

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border),
        const SizedBox(height: AppTokens.space12),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        ...children,
        const SizedBox(height: AppTokens.space16),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppTokens.space4),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 1 — Identity
// ---------------------------------------------------------------------------

class _IdentitySection extends StatelessWidget {
  const _IdentitySection({required this.player});

  final PlayerModel player;

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');
    final age = _calculateAge(player.dateOfBirth);

    return _ProfileSection(
      title: l10n.playerSectionIdentity,
      children: [
        _DetailRow(
          label: l10n.fieldFullName,
          value: player.fullName,
        ),
        _DetailRow(
          label: l10n.fieldDateOfBirth,
          value: dateFormat.format(player.dateOfBirth),
        ),
        _DetailRow(
          label: '',
          value: l10n.playerAgeYears(age),
        ),
        _DetailRow(
          label: l10n.fieldNationality,
          value: player.nationality,
        ),
        if (player.secondNationality != null &&
            player.secondNationality!.isNotEmpty)
          _DetailRow(
            label: l10n.fieldSecondNationality,
            value: player.secondNationality!,
          ),
        _DetailRow(
          label: l10n.fieldCountryOfResidence,
          value: player.countryOfResidence,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 2 — Football Details
// ---------------------------------------------------------------------------

class _FootballDetailsSection extends StatelessWidget {
  const _FootballDetailsSection({required this.player});

  final PlayerModel player;

  String _formatMarketValue(double value, String? currency) {
    final symbol = switch (currency) {
      'EUR' => '€',
      'GBP' => '£',
      'USD' => '\$',
      _ => currency ?? '€',
    };
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol${formatter.format(value)}';
  }

  String _footLabel(PreferredFoot foot, AppLocalizations l10n) {
    return switch (foot) {
      PreferredFoot.left => l10n.footLeft,
      PreferredFoot.right => l10n.footRight,
      PreferredFoot.both => l10n.footBoth,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ProfileSection(
      title: l10n.playerSectionFootball,
      children: [
        _DetailRow(
          label: l10n.fieldPreferredPosition,
          value: player.preferredPosition.toFirestoreValue(),
        ),
        if (player.otherPositions != null &&
            player.otherPositions!.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsetsDirectional.only(bottom: AppTokens.space8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    l10n.fieldOtherPositions,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space4,
                    children: player.otherPositions!
                        .map((pos) => AmStatusBadge(
                              label: pos,
                              backgroundColor: AppColors.primarySurface,
                              textColor: AppColors.primary,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
        _DetailRow(
          label: l10n.fieldPreferredFoot,
          value: _footLabel(player.preferredFoot, l10n),
        ),
        if (player.currentClub != null && player.currentClub!.isNotEmpty)
          _DetailRow(
            label: l10n.fieldCurrentClub,
            value: player.currentClub!,
          ),
        if (player.leagueCountry != null && player.leagueCountry!.isNotEmpty)
          _DetailRow(
            label: l10n.fieldLeagueCountry,
            value: player.leagueCountry!,
          ),
        if (player.estimatedMarketValue != null)
          _DetailRow(
            label: l10n.fieldMarketValue,
            value: _formatMarketValue(
                player.estimatedMarketValue!, player.marketValueCurrency),
          ),
        if (player.transfermarktUrl != null &&
            player.transfermarktUrl!.isNotEmpty)
          _TransfermarktLink(url: player.transfermarktUrl!),
      ],
    );
  }
}

class _TransfermarktLink extends StatelessWidget {
  const _TransfermarktLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.space8),
      child: Semantics(
        button: true,
        label: l10n.playerProfileOpenTransfermarkt,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: InkWell(
            onTap: () => launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                const SizedBox(width: AppTokens.space4),
                Text(
                  l10n.playerProfileOpenTransfermarkt,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
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

// ---------------------------------------------------------------------------
// Section 3 — Representation
// ---------------------------------------------------------------------------

class _RepresentationSection extends StatelessWidget {
  const _RepresentationSection({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    if (player.agentContractStart == null &&
        player.agentContractExpiry == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return _ProfileSection(
      title: l10n.playerSectionRepresentation,
      children: [
        if (player.agentContractStart != null)
          _DetailRow(
            label: l10n.fieldAgentContractStart,
            value: dateFormat.format(player.agentContractStart!),
          ),
        if (player.agentContractExpiry != null)
          _DetailRow(
            label: l10n.fieldAgentContractExpiry,
            value: dateFormat.format(player.agentContractExpiry!),
            trailing: _isExpiringSoon(player.agentContractExpiry!)
                ? _ExpiringWarning()
                : null,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 4 — Contract & Financial
// ---------------------------------------------------------------------------

class _ContractFinancialSection extends StatelessWidget {
  const _ContractFinancialSection({required this.player});

  final PlayerModel player;

  String _formatSalary(double value, String? currency) {
    final symbol = switch (currency) {
      'EUR' => '€',
      'GBP' => '£',
      'USD' => '\$',
      _ => currency ?? '€',
    };
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    if (player.clubContractExpiry == null && player.salary == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return _ProfileSection(
      title: l10n.playerSectionContract,
      children: [
        if (player.clubContractExpiry != null)
          _DetailRow(
            label: l10n.fieldClubContractExpiry,
            value: dateFormat.format(player.clubContractExpiry!),
            trailing: _isExpiringSoon(player.clubContractExpiry!)
                ? _ExpiringWarning()
                : null,
          ),
        if (player.salary != null)
          _DetailRow(
            label: l10n.fieldSalary,
            value: _formatSalary(player.salary!, player.salaryCurrency),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 5 — Contact
// ---------------------------------------------------------------------------

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ProfileSection(
      title: l10n.playerSectionContact,
      children: [
        _ContactRow(
          label: l10n.fieldPhoneNumber,
          value: player.phoneNumber,
          icon: Icons.phone_outlined,
          semanticsLabel: l10n.playerProfileCallNumber,
          onTap: () => launchUrl(Uri.parse('tel:${player.phoneNumber}')),
        ),
        _ContactRow(
          label: l10n.fieldEmail,
          value: player.email,
          icon: Icons.email_outlined,
          semanticsLabel: l10n.playerProfileSendEmail,
          onTap: () => launchUrl(Uri.parse('mailto:${player.email}')),
        ),
        if (player.whatsAppNumber != null &&
            player.whatsAppNumber!.isNotEmpty)
          _ContactRow(
            label: l10n.fieldWhatsAppNumber,
            value: player.whatsAppNumber!,
            icon: Icons.chat_outlined,
            semanticsLabel: l10n.playerProfileWhatsApp,
            onTap: () {
              final number =
                  player.whatsAppNumber!.replaceAll(RegExp(r'[^\d+]'), '');
              launchUrl(
                Uri.parse('https://wa.me/$number'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: '$semanticsLabel: $value',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: AppColors.primary),
                      const SizedBox(width: AppTokens.space4),
                      Flexible(
                        child: Text(
                          value,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 6 — Family Contacts
// ---------------------------------------------------------------------------

class _FamilyContactsSection extends ConsumerWidget {
  const _FamilyContactsSection({required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contactsAsync = ref.watch(familyContactsProvider(playerId));

    return _ProfileSection(
      title: l10n.playerSectionFamily,
      children: [
        contactsAsync.when(
          loading: () => const AmLoadingSkeleton(
            variant: AmSkeletonVariant.listItem,
          ),
          error: (_, __) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () =>
                ref.invalidate(familyContactsProvider(playerId)),
          ),
          data: (contacts) {
            if (contacts.isEmpty) {
              return AmEmptyState(
                icon: Icons.people_outline,
                title: l10n.playerNoFamilyContacts,
                subtitle: '',
              );
            }
            return Column(
              children: contacts
                  .map((contact) => AmFamilyContactListItem(
                        name: contact.name,
                        relationship: contact.relationship,
                        phoneNumber: contact.phoneNumber,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 8 — Notes
// ---------------------------------------------------------------------------

class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notesAsync = ref.watch(playerNotesProvider(playerId));
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return _ProfileSection(
      title: l10n.playerSectionNotes,
      children: [
        notesAsync.when(
          loading: () => const AmLoadingSkeleton(
            variant: AmSkeletonVariant.listItem,
          ),
          error: (_, __) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () =>
                ref.invalidate(playerNotesProvider(playerId)),
          ),
          data: (notes) {
            if (notes.isEmpty) {
              return AmEmptyState(
                icon: Icons.note_outlined,
                title: l10n.playerNoNotes,
                subtitle: '',
              );
            }
            return Column(
              children: notes
                  .map((note) => AmNoteListItem(
                        content: note.content,
                        timestamp: note.createdAt != null
                            ? dateFormat.format(note.createdAt!)
                            : '',
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _ProfileLoadingSkeleton extends StatelessWidget {
  const _ProfileLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppTokens.space16),
      child: Column(
        children: [
          const AmLoadingSkeleton(variant: AmSkeletonVariant.card),
          const SizedBox(height: AppTokens.space16),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
          const SizedBox(height: AppTokens.space8),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
          const SizedBox(height: AppTokens.space8),
          const AmLoadingSkeleton(variant: AmSkeletonVariant.listItem),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

bool _isExpiringSoon(DateTime date) {
  final daysUntilExpiry = date.difference(DateTime.now()).inDays;
  return daysUntilExpiry >= 0 && daysUntilExpiry <= 90;
}

class _ExpiringWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.playerContractExpiringSoon,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
          const SizedBox(width: AppTokens.space4),
          Text(
            l10n.playerContractExpiringSoon,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
