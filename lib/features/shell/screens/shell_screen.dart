/// Navigation shell that wraps tab screens with a bottom nav and side drawer.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/widgets/offline_banner.dart';
import '../../messaging/providers/messaging_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_nav_bar.dart';

/// Tab definition for the navigation shell.
class _Tab {
  const _Tab({
    required this.path,
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final String path;
  final String Function(AppLocalizations) labelKey;
  final IconData icon;
  final IconData activeIcon;
}

final _tabs = [
  _Tab(
    path: '/dashboard',
    labelKey: (l10n) => l10n.navDashboard,
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
  ),
  _Tab(
    path: '/players',
    labelKey: (l10n) => l10n.navPlayers,
    icon: Icons.people_outline,
    activeIcon: Icons.people,
  ),
  _Tab(
    path: '/market',
    labelKey: (l10n) => l10n.navMarket,
    icon: Icons.storefront_outlined,
    activeIcon: Icons.storefront,
  ),
  _Tab(
    path: '/messages',
    labelKey: (l10n) => l10n.navMessages,
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
  ),
];

/// The navigation shell screen used by [ShellRoute].
///
/// Provides a [Scaffold] with a bottom [NavigationBar] and side [Drawer].
/// The [child] parameter is the routed page provided by GoRouter.
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({required this.child, super.key});

  /// The child widget provided by [ShellRoute].
  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromLocation();
  }

  @override
  void didUpdateWidget(ShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndexFromLocation();
  }

  void _updateIndexFromLocation() {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        return;
      }
    }
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      context.go(_tabs[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final unreadCount = ref.watch(unreadMessagesCountProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Exit the app on Android back button from tab screens.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Semantics(
            label: l10n.openDrawerLabel,
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          title: Text(_tabs[_currentIndex].labelKey(l10n)),
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: ExcludeSemantics(
                  child: _TabIcon(
                    icon: tab.icon,
                    isMessages: tab.path == '/messages',
                    unreadCount: unreadCount,
                  ),
                ),
                selectedIcon: ExcludeSemantics(
                  child: _TabIcon(
                    icon: tab.activeIcon,
                    isMessages: tab.path == '/messages',
                    unreadCount: unreadCount,
                  ),
                ),
                label: tab.labelKey(l10n),
              ),
          ],
        ),
        drawer: AppDrawer(currentPath: location),
      ),
    );
  }
}

/// A bottom-nav tab icon, optionally decorated with an unread-count badge.
///
/// Only the Messages tab passes [isMessages] as `true` — the badge is shown
/// whenever [unreadCount] is greater than zero.
class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.isMessages,
    required this.unreadCount,
  });

  final IconData icon;
  final bool isMessages;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon);
    if (!isMessages || unreadCount <= 0) return iconWidget;

    return Badge(
      label: Text('$unreadCount'),
      child: iconWidget,
    );
  }
}
