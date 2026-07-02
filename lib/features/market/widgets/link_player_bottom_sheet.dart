library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_player_card.dart';
import '../../../core/widgets/am_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../players/models/player_enums.dart';
import '../../players/models/player_model.dart';
import '../../players/providers/player_providers.dart';

Future<void> showLinkPlayerBottomSheet(
  BuildContext context, {
  required ValueChanged<PlayerModel> onPlayerSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.vertical(
        top: Radius.circular(AppTokens.radiusLg),
      ),
    ),
    builder: (context) => _LinkPlayerBottomSheetContent(
      onPlayerSelected: onPlayerSelected,
    ),
  );
}

class _LinkPlayerBottomSheetContent extends ConsumerStatefulWidget {
  const _LinkPlayerBottomSheetContent({required this.onPlayerSelected});

  final ValueChanged<PlayerModel> onPlayerSelected;

  @override
  ConsumerState<_LinkPlayerBottomSheetContent> createState() =>
      _LinkPlayerBottomSheetContentState();
}

class _LinkPlayerBottomSheetContentState
    extends ConsumerState<_LinkPlayerBottomSheetContent> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _statusLabel(AppLocalizations l10n, PlayerStatus status) {
    return switch (status) {
      PlayerStatus.activeClient => l10n.statusActiveClient,
      PlayerStatus.prospect => l10n.statusProspect,
      PlayerStatus.formerClient => l10n.statusFormerClient,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playersAsync = ref.watch(agentPlayersProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppTokens.space16,
          end: AppTokens.space16,
          top: AppTokens.space16,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.linkPlayerPrompt,
                style: const TextStyle(
                  fontSize: AppTokens.fontSizeXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            AmTextField(
              label: l10n.linkPlayerSearch,
              controller: _searchController,
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: AppTokens.space16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: playersAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(AppTokens.space32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => AmErrorState(
                  message: l10n.errorLoadingData,
                  onRetry: () => ref.invalidate(agentPlayersProvider),
                ),
                data: (players) {
                  if (players.isEmpty) {
                    return AmEmptyState(
                      icon: Icons.person_off_outlined,
                      title: l10n.marketEmptyTitle,
                      subtitle: l10n.marketEmptySubtitle,
                    );
                  }

                  final filtered = _query.isEmpty
                      ? players
                      : players
                          .where((p) => p.fullName.toLowerCase().contains(_query))
                          .toList();

                  if (filtered.isEmpty) {
                    return AmEmptyState(
                      icon: Icons.search_off,
                      title: l10n.marketEmptyFilterTitle,
                      subtitle: l10n.marketEmptyFilterSubtitle,
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTokens.space8),
                    itemBuilder: (context, index) {
                      final player = filtered[index];
                      return AmPlayerCard(
                        fullName: player.fullName,
                        position: player.preferredPosition.toFirestoreValue(),
                        currentClub: player.currentClub ?? '',
                        statusLabel: _statusLabel(l10n, player.status),
                        statusBackgroundColor: AppColors.primarySurface,
                        statusTextColor: AppColors.primary,
                        photoUrl: player.photoUrl,
                        onTap: () {
                          widget.onPlayerSelected(player);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
