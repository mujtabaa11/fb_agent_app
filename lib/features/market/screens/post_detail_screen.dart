/// Post Detail screen — full read-only view of a single Market post with a
/// Message Agent CTA.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_primary_button.dart';
import '../../../core/widgets/am_secondary_button.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/agent_providers.dart';
import '../../messaging/providers/conversation_providers.dart';
import '../models/external_link_model.dart';
import '../models/market_post_enums.dart';
import '../models/market_post_model.dart';
import '../providers/market_feed_provider.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/market_post_card_item.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postAsync = ref.watch(postDetailProvider(postId));

    return postAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.postDetailTitle)),
        body: ListView(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          children: const [
            AmLoadingSkeleton(),
            SizedBox(height: AppTokens.space12),
            AmLoadingSkeleton(),
          ],
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.postDetailTitle)),
        body: AmErrorState(
          message: l10n.errorLoadingData,
          onRetry: () => ref.invalidate(postDetailProvider(postId)),
        ),
      ),
      data: (post) {
        if (post == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.postDetailTitle)),
            body: Center(child: Text(l10n.errorLoadingData)),
          );
        }
        return _PostDetailBody(post: post);
      },
    );
  }
}

class _PostDetailBody extends ConsumerWidget {
  const _PostDetailBody({required this.post});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlayerAvailable = post.type == MarketPostType.playerAvailable;
    final currentAgent = ref.watch(currentAgentProvider);
    final isOwnPost = currentAgent?.id == post.agentId;

    final daysUntilExpiry = post.expiresAt.difference(DateTime.now()).inDays;
    final expiryWarningText =
        (!post.isExpired && daysUntilExpiry >= 0 && daysUntilExpiry <= 7)
            ? l10n.postExpiresInDays(daysUntilExpiry)
            : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              isPlayerAvailable
                  ? l10n.postTypePlayerAvailable
                  : l10n.postTypeNeedPlayer,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(
                    post: post,
                    isPlayerAvailable: isPlayerAvailable,
                    isDark: isDark,
                    expiryWarningText: expiryWarningText,
                  ),
                  const SizedBox(height: AppTokens.space24),
                  _AgentSection(agentId: post.agentId),
                  const SizedBox(height: AppTokens.space24),
                  if (isPlayerAvailable)
                    _PlayerSection(post: post)
                  else
                    _ProfileNeededSection(post: post),
                  const SizedBox(height: AppTokens.space24),
                  _PostDetailsSection(post: post),
                  const SizedBox(height: AppTokens.space64),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _CtaArea(post: post, isOwnPost: isOwnPost),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.post,
    required this.isPlayerAvailable,
    required this.isDark,
    required this.expiryWarningText,
  });

  final MarketPostModel post;
  final bool isPlayerAvailable;
  final bool isDark;
  final String? expiryWarningText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmStatusBadge(
          label: isPlayerAvailable
              ? l10n.postTypePlayerAvailable
              : l10n.postTypeNeedPlayer,
          backgroundColor: isPlayerAvailable
              ? (isDark
                  ? AppColors.successSurfaceDark
                  : AppColors.successSurface)
              : AppColors.primarySurface,
          textColor: isPlayerAvailable
              ? (isDark ? AppColors.successDark : AppColors.success)
              : AppColors.primary,
        ),
        if (post.isExpired) ...[
          const SizedBox(height: AppTokens.space16),
          Semantics(
            label: l10n.postExpiredBanner,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.errorSurfaceDark
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Text(
                l10n.postExpiredBanner,
                style: TextStyle(
                  color: isDark ? AppColors.errorDark : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (expiryWarningText != null) ...[
          const SizedBox(height: AppTokens.space8),
          Text(
            expiryWarningText!,
            style: TextStyle(
              color: isDark ? AppColors.warningDark : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _AgentSection extends ConsumerWidget {
  const _AgentSection({required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final agentAsync = ref.watch(marketPostAgentProvider(agentId));
    final agent = agentAsync.valueOrNull;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.postDetailAgentSection),
        const SizedBox(height: AppTokens.space8),
        Semantics(
          button: true,
          label: l10n.marketAgentNameTapLabel(agent?.fullName ?? ''),
          child: InkWell(
            onTap: () => context.push('/market/agent/$agentId'),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  AmAvatar(
                    imageUrl: agent?.avatarUrl,
                    name: agent?.fullName,
                    size: AmAvatarSize.medium,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                agent?.fullName ?? '',
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (agent?.isFifaRegistered ?? false) ...[
                              const SizedBox(width: AppTokens.space8),
                              AmStatusBadge(
                                label: l10n.postFifaRegistered,
                                backgroundColor: isDark
                                    ? AppColors.successSurfaceDark
                                    : AppColors.successSurface,
                                textColor: isDark
                                    ? AppColors.successDark
                                    : AppColors.success,
                              ),
                            ],
                          ],
                        ),
                        if (agent?.country != null)
                          Text(
                            agent!.country,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerSection extends StatelessWidget {
  const _PlayerSection({required this.post});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final showLinks = !post.isPlayerAnonymous &&
        (post.transfermarktUrl != null ||
            (post.externalLinks?.isNotEmpty ?? false));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.postDetailPlayerSection),
        const SizedBox(height: AppTokens.space12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmAvatar(
              imageUrl: post.isPlayerAnonymous ? null : post.playerPhotoUrl,
              size: AmAvatarSize.large,
            ),
            const SizedBox(width: AppTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.playerPosition != null)
                    AmStatusBadge(
                      label: post.playerPosition!.toFirestoreValue(),
                      backgroundColor: AppColors.primarySurface,
                      textColor: AppColors.primary,
                    ),
                  const SizedBox(height: AppTokens.space8),
                  if (post.playerNationality != null)
                    Text(
                      post.playerNationality!,
                      style: textTheme.bodyMedium,
                    ),
                  if (post.playerLeagueCountry != null)
                    Text(
                      post.playerLeagueCountry!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (post.playerAge != null)
                    Text(
                      l10n.marketAgeYears(post.playerAge!),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (post.playerMarketValue != null) ...[
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      formatMarketEurValue(post.playerMarketValue!),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (showLinks) ...[
          const SizedBox(height: AppTokens.space24),
          _SectionHeader(title: l10n.postDetailLinksSection),
          const SizedBox(height: AppTokens.space8),
          if (post.transfermarktUrl != null)
            _LinkRow(
              label: 'Transfermarkt',
              url: post.transfermarktUrl!,
            ),
          for (final link
              in post.externalLinks ?? const <ExternalLinkModel>[])
            _LinkRow(
              label: link.label.isNotEmpty ? link.label : link.url,
              url: link.url,
            ),
        ],
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              const Icon(Icons.open_in_new, size: AppTokens.space16),
              const SizedBox(width: AppTokens.space8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNeededSection extends StatelessWidget {
  const _ProfileNeededSection({required this.post});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final ageRangeText = post.neededMinAge != null && post.neededMaxAge != null
        ? l10n.postNeededAgeRange(post.neededMinAge!, post.neededMaxAge!)
        : post.neededMinAge != null
            ? l10n.postNeededAgeMin(post.neededMinAge!)
            : post.neededMaxAge != null
                ? l10n.postNeededAgeMax(post.neededMaxAge!)
                : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.postDetailProfileSection),
        const SizedBox(height: AppTokens.space12),
        if (post.neededPosition != null)
          AmStatusBadge(
            label: post.neededPosition!.toFirestoreValue(),
            backgroundColor: AppColors.primarySurface,
            textColor: AppColors.primary,
          ),
        if (post.neededNationalities?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppTokens.space12),
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: [
              for (final nationality in post.neededNationalities!)
                AmStatusBadge(
                  label: nationality,
                  backgroundColor: AppColors.surfaceAlt,
                  textColor: AppColors.textPrimary,
                ),
            ],
          ),
        ],
        if (ageRangeText != null) ...[
          const SizedBox(height: AppTokens.space12),
          Text(ageRangeText, style: textTheme.bodyMedium),
        ],
        if (post.neededLeagueCountry != null) ...[
          const SizedBox(height: AppTokens.space8),
          Text(
            post.neededLeagueCountry!,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (post.budget != null) ...[
          const SizedBox(height: AppTokens.space8),
          Text(
            formatMarketEurValue(post.budget!),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _PostDetailsSection extends StatelessWidget {
  const _PostDetailsSection({required this.post});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.postDetailPostSection),
        const SizedBox(height: AppTokens.space8),
        Text(post.description, style: textTheme.bodyMedium),
        const SizedBox(height: AppTokens.space16),
        if (post.createdAt != null)
          Text(
            l10n.postPostedOn(dateFormat.format(post.createdAt!)),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: AppTokens.space4),
        Text(
          l10n.postExpiresOn(dateFormat.format(post.expiresAt)),
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _CtaArea extends ConsumerWidget {
  const _CtaArea({required this.post, required this.isOwnPost});

  final MarketPostModel post;
  final bool isOwnPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (isOwnPost) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          child: AmSecondaryButton(
            label: l10n.managePostButton,
            onPressed: () => context.push('/market/my-posts'),
          ),
        ),
      );
    }

    if (post.isExpired) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          child: Text(
            l10n.postExpiredNoCta,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final messageState = ref.watch(messageAgentNotifierProvider(post.id));

    ref.listen(messageAgentNotifierProvider(post.id), (previous, next) {
      if (next.conversationId != null &&
          previous?.conversationId != next.conversationId) {
        context.push('/messages/${next.conversationId}');
      }
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: AmPrimaryButton(
          label: l10n.messageAgentButton,
          isLoading: messageState.isLoading,
          onPressed: () => _onMessageAgent(context, ref, l10n),
        ),
      ),
    );
  }

  void _onMessageAgent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final currentAgent = ref.read(currentAgentProvider);
    if (currentAgent == null) return;

    ref
        .read(messageAgentNotifierProvider(post.id).notifier)
        .initiateConversation(
          currentAgent.id,
          post.agentId,
          l10n.messageAgentOpeningMessage,
          post.id,
        );
  }
}
