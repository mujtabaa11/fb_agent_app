/// Navigation shell that wraps tab screens with a bottom nav and side drawer.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/widgets/offline_banner.dart';
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
    path: '/home',
    labelKey: (l10n) => l10n.navHome,
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  _Tab(
    path: '/explore',
    labelKey: (l10n) => l10n.navExplore,
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
  ),
  _Tab(
    path: '/profile',
    labelKey: (l10n) => l10n.navProfile,
    icon: Icons.person_outlined,
    activeIcon: Icons.person,
  ),
];

/// The navigation shell screen used by [ShellRoute].
///
/// Provides a [Scaffold] with a bottom [NavigationBar] and side [Drawer].
/// The [child] parameter is the routed page provided by GoRouter.
class ShellScreen extends StatefulWidget {
  const ShellScreen({required this.child, super.key});

  /// The child widget provided by [ShellRoute].
  final Widget child;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
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
                icon: ExcludeSemantics(child: Icon(tab.icon)),
                selectedIcon: ExcludeSemantics(child: Icon(tab.activeIcon)),
                label: tab.labelKey(l10n),
              ),
          ],
        ),
        drawer: AppDrawer(currentPath: location),
      ),
    );
  }
}
