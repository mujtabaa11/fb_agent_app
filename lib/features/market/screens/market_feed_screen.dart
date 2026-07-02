/// Market tab screen — browsable feed of all active Market posts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/market_feed_provider.dart';
import '../widgets/market_filter_sheet.dart';
import '../widgets/market_post_card_item.dart';

class MarketFeedScreen extends ConsumerWidget {
  const MarketFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final feedAsync = ref.watch(marketFeedProvider);
    final filter = ref.watch(marketFeedFilterProvider);
    final activeFilterCount = filter.activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketTitle),
        actions: [
          Semantics(
            button: true,
            label: l10n.myPostsButtonLabel,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: IconButton(
                icon: const Icon(Icons.manage_accounts),
                onPressed: () => context.push('/market/my-posts'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppTokens.space8),
            child: Semantics(
              button: true,
              label: activeFilterCount > 0
                  ? l10n.marketFilterActiveCount(activeFilterCount)
                  : l10n.marketFilterButtonLabel,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => showMarketFilterSheet(context),
                    ),
                    if (activeFilterCount > 0)
                      PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsetsDirectional.all(2),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$activeFilterCount',
                              style: const TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: AppTokens.fontSizeXs,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          itemCount: 5,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppTokens.space12),
          itemBuilder: (_, __) => const AmLoadingSkeleton(),
        ),
        error: (error, _) => AmErrorState(
          message: l10n.errorLoadingData,
          onRetry: () => ref.invalidate(marketFeedProvider),
        ),
        data: (_) => _MarketFeedList(activeFilterCount: activeFilterCount),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: l10n.createPostTitle,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: () => context.push('/market/post/create'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _MarketFeedList extends ConsumerWidget {
  const _MarketFeedList({required this.activeFilterCount});

  final int activeFilterCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final allPosts = ref.watch(marketFeedProvider).valueOrNull ?? [];
    final filteredPosts = ref.watch(filteredMarketFeedProvider);

    if (allPosts.isEmpty) {
      return AmEmptyState(
        icon: Icons.storefront_outlined,
        title: l10n.marketEmptyTitle,
        subtitle: l10n.marketEmptySubtitle,
      );
    }

    if (filteredPosts.isEmpty) {
      return AmEmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: l10n.marketEmptyFilterTitle,
        subtitle: l10n.marketEmptyFilterSubtitle,
        actionLabel: l10n.marketClearFilters,
        onAction: () =>
            ref.read(marketFeedFilterProvider.notifier).clearAllFilters(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(marketFeedProvider),
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        itemCount: filteredPosts.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppTokens.space12),
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return MarketPostCardItem(key: ValueKey(post.id), post: post);
        },
      ),
    );
  }
}
