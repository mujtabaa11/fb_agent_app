/// Explore tab screen — paginated list reference example.
///
/// Demonstrates infinite scroll with pull-to-refresh, first-page error/empty
/// states, inline next-page error, and end-of-list indicator. All data flows
/// through [BaseRepository<UserProfileModel>] via DI.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../explore/presentation/explore_state.dart';
import '../../explore/presentation/explore_view_model.dart';
import '../../profile/data/user_profile_model.dart';

/// Minimum touch target dimension recommended by WCAG 2.1 SC 2.5.5.
const double _kMinTouchTarget = 44;

/// Scroll threshold (fraction of max extent) to trigger next page fetch.
const double _kScrollThreshold = 0.8;

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * _kScrollThreshold) {
      ref.read(exploreViewModelProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(exploreViewModelProvider);

    // First page loading.
    if (state.isLoadingFirstPage) {
      return Center(
        child: Semantics(
          label: l10n.loading,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    // First page error.
    if (state.firstPageError != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: l10n.exploreLoadError,
        body: l10n.exploreLoadErrorBody,
        actionLabel: l10n.retryButton,
        onAction: () =>
            ref.read(exploreViewModelProvider.notifier).loadInitialPage(),
      );
    }

    // Empty collection.
    if (state.items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: l10n.exploreEmptyTitle,
        body: l10n.exploreEmptyBody,
      );
    }

    // List with items.
    return Semantics(
      label: l10n.exploreRefreshLabel,
      child: RefreshIndicator(
        onRefresh: ref.read(exploreViewModelProvider.notifier).refresh,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppTokens.space8,
          ),
          itemCount: _itemCount(state),
          itemBuilder: (context, index) {
            // Regular item.
            if (index < state.items.length) {
              return _UserListItem(profile: state.items[index]);
            }

            // Footer: loading, error, or end-of-list.
            return _ListFooter(state: state);
          },
        ),
      ),
    );
  }

  /// Computes total item count including footer slot.
  int _itemCount(ExploreState state) {
    if (state.items.isEmpty) return 0;
    // +1 for the footer (loading indicator, error, or end-of-list).
    return state.items.length + 1;
  }
}

/// A single user profile card in the list.
class _UserListItem extends StatelessWidget {
  const _UserListItem({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.exploreUserItemLabel(profile.displayName, profile.email),
      child: Card(
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space4,
        ),
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space4,
          ),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: profile.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: colorScheme.onPrimaryContainer,
                  ),
          ),
          title: Text(profile.displayName),
          subtitle: Text(profile.email),
          onTap: () => context.push('/explore/${profile.id}'),
        ),
      ),
    );
  }
}

/// Footer widget shown below the last list item.
class _ListFooter extends ConsumerWidget {
  const _ListFooter({required this.state});

  final ExploreState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Loading next page.
    if (state.isLoadingNextPage) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: Center(
          child: Semantics(
            label: l10n.loading,
            child: const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    // Next page error — items remain visible with inline retry.
    if (state.nextPageError != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: Column(
          children: [
            Text(
              l10n.explorePageError,
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _kMinTouchTarget,
                minHeight: _kMinTouchTarget,
              ),
              child: Semantics(
                button: true,
                label: l10n.retryButton,
                child: TextButton(
                  onPressed: () => ref
                      .read(exploreViewModelProvider.notifier)
                      .loadNextPage(),
                  child: Text(l10n.retryButton),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // End of list.
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: Center(
          child: Text(
            l10n.exploreNoMoreResults,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
