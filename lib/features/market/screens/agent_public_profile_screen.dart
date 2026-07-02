/// Agent Public Profile screen — a read-only public-facing view of any
/// agent's profile, accessible from Market posts and the side drawer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../auth/models/user_model.dart';
import '../models/market_post_model.dart';
import '../providers/agent_profile_provider.dart';
import '../widgets/market_post_card_item.dart';

class AgentPublicProfileScreen extends ConsumerWidget {
  const AgentPublicProfileScreen({required this.agentId, super.key});

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final agentAsync = ref.watch(agentProfileProvider(agentId));

    return agentAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.agentPublicProfileTitle)),
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
        appBar: AppBar(title: Text(l10n.agentPublicProfileTitle)),
        body: AmErrorState(
          message: l10n.errorLoadingData,
          onRetry: () => ref.invalidate(agentProfileProvider(agentId)),
        ),
      ),
      data: (agent) {
        if (agent == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.agentPublicProfileTitle)),
            body: AmEmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.agentProfileNotFound,
              subtitle: '',
              actionLabel: l10n.goBackButton,
              onAction: () => context.pop(),
            ),
          );
        }
        return _AgentProfileBody(agent: agent);
      },
    );
  }
}

class _AgentProfileBody extends StatelessWidget {
  const _AgentProfileBody({required this.agent});

  final UserModel agent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(agent.fullName),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                alignment: Alignment.center,
                padding: const EdgeInsetsDirectional.only(
                  top: AppTokens.space32,
                ),
                child: Container(
                  width: AmAvatarSize.large.diameter * 2,
                  height: AmAvatarSize.large.diameter * 2,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AmAvatar(
                    imageUrl: agent.avatarUrl,
                    name: agent.fullName,
                    size: AmAvatarSize.large,
                    semanticsLabel: agent.fullName,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppTokens.space16),
              child: _ProfileSection(agent: agent),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space16,
              ),
              child: _ActivePostsSection(agentId: agent.id),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTokens.space32),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.agent});

  final UserModel agent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isFifaRegistered = agent.isFifaRegistered ?? false;
    final hasAgencyName = agent.agencyName?.isNotEmpty ?? false;
    final hasBio = agent.bio?.isNotEmpty ?? false;

    return Column(
      children: [
        Text(
          agent.fullName,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        AmStatusBadge(
          label:
              isFifaRegistered ? l10n.fifaLicensedAgent : l10n.unlicensedAgent,
          backgroundColor: isFifaRegistered
              ? (isDark
                  ? AppColors.successSurfaceDark
                  : AppColors.successSurface)
              : (isDark ? AppColors.surfaceAltDark : AppColors.surfaceAlt),
          textColor: isFifaRegistered
              ? (isDark ? AppColors.successDark : AppColors.success)
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
        ),
        const SizedBox(height: AppTokens.space12),
        Text(
          agent.country,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        if (hasAgencyName) ...[
          const SizedBox(height: AppTokens.space4),
          Text(
            agent.agencyName!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
        if (agent.yearsOfExperience != null) ...[
          const SizedBox(height: AppTokens.space4),
          Text(
            l10n.yearsExperience(agent.yearsOfExperience!),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
        if (hasBio) ...[
          const SizedBox(height: AppTokens.space16),
          const Divider(),
          const SizedBox(height: AppTokens.space16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              agent.bio!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivePostsSection extends ConsumerWidget {
  const _ActivePostsSection({required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final postsAsync = ref.watch(agentActivePostsProvider(agentId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: AppTokens.space16),
        Text(
          l10n.agentActivePostsTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTokens.space12),
        postsAsync.when(
          loading: () => const Column(
            children: [
              AmLoadingSkeleton(),
              SizedBox(height: AppTokens.space12),
              AmLoadingSkeleton(),
            ],
          ),
          error: (error, _) => AmErrorState(
            message: l10n.errorLoadingData,
            onRetry: () => ref.invalidate(agentActivePostsProvider(agentId)),
          ),
          data: (posts) => _ActivePostsList(posts: posts),
        ),
      ],
    );
  }
}

class _ActivePostsList extends StatelessWidget {
  const _ActivePostsList({required this.posts});

  final List<MarketPostModel> posts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (posts.isEmpty) {
      return AmEmptyState(
        icon: Icons.post_add,
        title: l10n.agentNoActivePostsTitle,
        subtitle: l10n.agentNoActivePostsSubtitle,
      );
    }

    return Column(
      children: [
        for (final post in posts) ...[
          MarketPostCardItem(key: ValueKey(post.id), post: post),
          const SizedBox(height: AppTokens.space12),
        ],
      ],
    );
  }
}
