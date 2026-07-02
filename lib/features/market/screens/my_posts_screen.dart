/// My Posts screen — the agent's own Market posts with close/delete actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_destructive_button.dart';
import '../../../core/widgets/am_empty_state.dart';
import '../../../core/widgets/am_error_state.dart';
import '../../../core/widgets/am_loading_skeleton.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../core/widgets/am_text_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/market_post_enums.dart';
import '../models/market_post_model.dart';
import '../providers/my_posts_provider.dart';
import '../widgets/market_post_card_item.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(myPostsProvider);

    ref.listen(myPostsActionsNotifierProvider, (previous, next) {
      final closeFailed = previous?.isClosing == true &&
          !next.isClosing &&
          next.errorMessage != null;
      final deleteFailed = previous?.isDeleting == true &&
          !next.isDeleting &&
          next.errorMessage != null;
      if (closeFailed || deleteFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myPostsTitle)),
      body: postsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppTokens.space12),
          itemBuilder: (_, __) => const AmLoadingSkeleton(),
        ),
        error: (error, _) => AmErrorState(
          message: l10n.errorLoadingData,
          onRetry: () => ref.invalidate(myPostsProvider),
        ),
        data: (posts) => _MyPostsList(posts: posts),
      ),
    );
  }
}

class _MyPostsList extends StatelessWidget {
  const _MyPostsList({required this.posts});

  final List<MarketPostModel> posts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (posts.isEmpty) {
      return AmEmptyState(
        icon: Icons.post_add,
        title: l10n.myPostsEmptyTitle,
        subtitle: l10n.myPostsEmptySubtitle,
        actionLabel: l10n.myPostsEmptyCta,
        onAction: () => context.push('/market/post/create'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(AppTokens.space16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _MyPostCard(key: ValueKey(post.id), post: post);
      },
    );
  }
}

class _MyPostCard extends ConsumerWidget {
  const _MyPostCard({required this.post, super.key});

  final MarketPostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionsState = ref.watch(myPostsActionsNotifierProvider);
    final isBusy = actionsState.isClosing || actionsState.isDeleting;

    final isClosed = post.status == MarketPostStatus.closed;
    final isExpired = !isClosed && post.isExpired;
    final isActive = !isClosed && !isExpired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarketPostCardItem(post: post),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppTokens.space16,
            end: AppTokens.space16,
            top: AppTokens.space8,
          ),
          child: Row(
            children: [
              _statusBadge(
                l10n,
                isDark,
                isActive: isActive,
                isExpired: isExpired,
              ),
            ],
          ),
        ),
        if (isActive)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppTokens.space16,
              end: AppTokens.space16,
              top: AppTokens.space4,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _daysRemainingText(l10n),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.space16),
          child: Row(
            children: [
              if (isActive) ...[
                AmTextButton(
                  label: l10n.closePostConfirm,
                  isDisabled: isBusy,
                  onPressed: () => _confirmClose(context, ref, l10n),
                ),
                const SizedBox(width: AppTokens.space8),
              ],
              AmDestructiveButton(
                label: l10n.deletePostConfirm,
                isDisabled: isBusy,
                onPressed: () => _confirmDelete(context, ref, l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(
    AppLocalizations l10n,
    bool isDark, {
    required bool isActive,
    required bool isExpired,
  }) {
    if (isActive) {
      return AmStatusBadge(
        label: l10n.postStatusActive,
        backgroundColor:
            isDark ? AppColors.successSurfaceDark : AppColors.successSurface,
        textColor: isDark ? AppColors.successDark : AppColors.success,
      );
    }
    if (isExpired) {
      return AmStatusBadge(
        label: l10n.postStatusExpired,
        backgroundColor:
            isDark ? AppColors.warningSurfaceDark : AppColors.warningSurface,
        textColor: isDark ? AppColors.warningDark : AppColors.warning,
      );
    }
    return AmStatusBadge(
      label: l10n.postStatusClosed,
      backgroundColor:
          isDark ? AppColors.surfaceAltDark : AppColors.surfaceAlt,
      textColor:
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }

  String _daysRemainingText(AppLocalizations l10n) {
    final now = DateTime.now();
    final expiresAt = post.expiresAt;
    final days = DateTime(expiresAt.year, expiresAt.month, expiresAt.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (days <= 0) return l10n.postExpiresToday;
    if (days == 1) return l10n.postOneDayRemaining;
    return l10n.postDaysRemaining(days);
  }

  Future<void> _confirmClose(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.closePostTitle),
        content: Text(l10n.closePostConfirmation),
        actions: [
          AmTextButton(
            label: l10n.closePostCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppTokens.space8,
              bottom: AppTokens.space8,
            ),
            child: FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(l10n.closePostConfirm),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(myPostsActionsNotifierProvider.notifier)
        .closePost(post.id);
    if (result is! Success || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.closePostSuccess)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePostTitle),
        content: Text(l10n.deletePostConfirmation),
        actions: [
          AmTextButton(
            label: l10n.deletePostCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppTokens.space8,
              bottom: AppTokens.space8,
            ),
            child: AmDestructiveButton(
              label: l10n.deletePostConfirm,
              filled: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(myPostsActionsNotifierProvider.notifier)
        .deletePost(post.id);
    if (result is! Success || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deletePostSuccess)),
    );
  }
}
