/// Side drawer with user info, navigation, theme toggle, and logout.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/data/result.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/widgets/am_avatar.dart';
import '../../auth/providers/agent_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../biometric/providers/biometric_preference_notifier.dart';
import '../../biometric/providers/biometric_providers.dart';

/// Application side drawer.
///
/// Displays the current user's info, navigation links matching the bottom nav
/// tabs, a theme mode toggle, and a logout action.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    required this.currentPath,
    super.key,
  });

  /// The current route path, used to highlight the active nav item.
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final agent = ref.watch(currentAgentProvider);
    final currentMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------
            // Agent header
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.space16,
                AppTokens.space24,
                AppTokens.space16,
                AppTokens.space16,
              ),
              child: Row(
                children: [
                  AmAvatar(
                    imageUrl: agent?.avatarUrl,
                    name: agent?.fullName,
                    size: AmAvatarSize.large,
                    semanticsLabel: l10n.userAvatarLabel,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (agent?.fullName != null)
                          Text(
                            agent!.fullName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (agent?.country != null)
                          Text(
                            agent!.country,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ----------------------------------------------------------
            // Navigation links
            // ----------------------------------------------------------
            if (agent != null)
              _NavTile(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: l10n.drawerViewProfile,
                path: '/market/agent/${agent.id}',
                currentPath: currentPath,
                onTap: () =>
                    _navigateTo(context, '/market/agent/${agent.id}'),
              ),
            _NavTile(
              icon: Icons.edit_outlined,
              activeIcon: Icons.edit,
              label: l10n.drawerEditProfile,
              path: '/profile/edit',
              currentPath: currentPath,
              onTap: () => _navigateTo(context, '/profile/edit'),
            ),

            if (kDebugMode)
              _NavTile(
                icon: Icons.widgets_outlined,
                activeIcon: Icons.widgets,
                label: l10n.showcaseTitle,
                path: '/dev/showcase',
                currentPath: currentPath,
                onTap: () => _navigateTo(context, '/dev/showcase'),
              ),

            const Divider(height: 1),

            // ----------------------------------------------------------
            // Settings section
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppTokens.space16,
                top: AppTokens.space12,
                bottom: AppTokens.space4,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.settingsSection,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // Theme toggle
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.palette_outlined),
              ),
              title: Text(l10n.themeLabel),
              subtitle: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: AppTokens.space8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: l10n.themeSwitcherLabel,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      selected: {currentMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .setThemeMode(selection.first);
                      },
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeModeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeModeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeModeDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Locale switcher
            _LocaleSwitcherTile(ref: ref),

            // Biometric toggle — hidden when biometrics not available
            const _BiometricToggleTile(),

            const Spacer(),

            // ----------------------------------------------------------
            // Logout
            // ----------------------------------------------------------
            const Divider(height: 1),
            Semantics(
              button: true,
              label: l10n.logoutButton,
              child: ListTile(
                leading: const ExcludeSemantics(
                  child: Icon(Icons.logout),
                ),
                title: Text(l10n.logoutButton),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space16,
                ),
                onTap: () => _handleLogout(context, ref),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String path) {
    Navigator.of(context).pop(); // close drawer
    if (path != currentPath) {
      context.go(path);
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // close drawer
    final result = await ref.read(authRepositoryProvider).signOut();
    switch (result) {
      case Success():
        if (context.mounted) context.go('/login');
      case Failure(:final exception):
        if (kDebugMode) debugPrint('Sign-out failed: $exception');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorGeneric),
            ),
          );
        }
    }
  }
}

/// Locale switcher tile with bottom sheet picker.
class _LocaleSwitcherTile extends StatelessWidget {
  const _LocaleSwitcherTile({required this.ref});

  final WidgetRef ref;

  /// Native language names — proper nouns, not translated.
  static const _localeNames = {
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        ref.watch(localeNotifierProvider).valueOrNull;
    final displayName = currentLocale != null
        ? _localeNames[currentLocale.languageCode] ??
            currentLocale.languageCode
        : l10n.deviceDefaultLanguage;

    return Semantics(
      button: true,
      label: '${l10n.languageLabel}: $displayName',
      child: ListTile(
        leading: const ExcludeSemantics(
          child: Icon(Icons.language),
        ),
        title: Text(l10n.languageLabel),
        trailing: Text(displayName),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.space16,
        ),
        onTap: () => _showLocalePicker(context, currentLocale),
      ),
    );
  }

  void _showLocalePicker(BuildContext context, Locale? currentLocale) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Text(
                  l10n.selectLanguageTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),

              // Device Default option
              Semantics(
                button: true,
                label: l10n.deviceDefaultLanguage,
                selected: currentLocale == null,
                child: ListTile(
                  title: Text(l10n.deviceDefaultLanguage),
                  trailing: currentLocale == null
                      ? const Icon(Icons.check)
                      : null,
                  minTileHeight: 48,
                  onTap: () {
                    ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(null);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),

              // One tile per supported locale
              ...AppLocalizations.supportedLocales.map((locale) {
                final name =
                    _localeNames[locale.languageCode] ?? locale.languageCode;
                final isSelected =
                    currentLocale?.languageCode == locale.languageCode;

                return Semantics(
                  button: true,
                  label: name,
                  selected: isSelected,
                  child: ListTile(
                    title: Text(name),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    minTileHeight: 48,
                    onTap: () {
                      ref
                          .read(localeNotifierProvider.notifier)
                          .setLocale(locale);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Biometric authentication toggle tile.
///
/// Hidden entirely when biometrics are not available on the device (AC #8).
/// Enable triggers verify-to-enable flow. Disable is immediate.
class _BiometricToggleTile extends ConsumerStatefulWidget {
  const _BiometricToggleTile();

  @override
  ConsumerState<_BiometricToggleTile> createState() =>
      _BiometricToggleTileState();
}

class _BiometricToggleTileState extends ConsumerState<_BiometricToggleTile> {
  bool? _biometricAvailable;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  Future<void> _onToggle(bool enable) async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    if (enable) {
      final l10n = AppLocalizations.of(context)!;
      final result = await ref
          .read(biometricPreferenceNotifierProvider.notifier)
          .enable(l10n.biometricEnableReason);

      if (!mounted) return;

      switch (result) {
        case BiometricEnableResult.notAvailable:
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.biometricNotAvailable)),
            );
        case BiometricEnableResult.verificationFailed:
          // User knowingly cancelled — no snackbar needed.
          break;
        case BiometricEnableResult.success:
          break;
      }
    } else {
      await ref
          .read(biometricPreferenceNotifierProvider.notifier)
          .disable();
    }

    if (mounted) {
      setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely when biometrics are not available or not yet checked.
    if (_biometricAvailable != true) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final prefAsync = ref.watch(biometricPreferenceNotifierProvider);
    final isEnabled = prefAsync.valueOrNull ?? false;

    return Semantics(
      toggled: isEnabled,
      label: isEnabled ? l10n.biometricEnabledLabel : l10n.biometricDisabledLabel,
      child: SwitchListTile(
        secondary: const ExcludeSemantics(
          child: Icon(Icons.fingerprint),
        ),
        title: Text(l10n.biometricSettingsTitle),
        subtitle: Text(l10n.biometricSettingsSubtitle),
        value: isEnabled,
        onChanged: _isToggling ? null : _onToggle,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.space16,
        ),
      ),
    );
  }
}

/// A single navigation tile in the drawer.
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final String currentPath;
  final VoidCallback onTap;

  bool get _isActive => currentPath == path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      selected: _isActive,
      child: ListTile(
        leading: ExcludeSemantics(
          child: Icon(_isActive ? activeIcon : icon),
        ),
        title: Text(
          label,
          style: _isActive
              ? theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.primary)
              : null,
        ),
        selected: _isActive,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.space16,
        ),
        onTap: onTap,
      ),
    );
  }
}
