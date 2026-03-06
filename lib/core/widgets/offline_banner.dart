/// A dismissible banner that appears when the device loses connectivity.
///
/// Listens to [connectivityStatusProvider] and animates in/out with
/// [AnimatedSize]. Pushes content down (not overlay). Uses theme warning
/// colors and localized strings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../services/connectivity_service.dart';
import '../theme/app_tokens.dart';

/// Offline connectivity banner.
///
/// Place this above the page content inside a [Column] so it pushes content
/// down when visible. It uses [AnimatedSize] for smooth expand/collapse.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(connectivityStatusProvider);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final isOffline = statusAsync.whenOrNull(
          data: (status) => status == ConnectivityStatus.offline,
        ) ??
        false;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isOffline
          ? Semantics(
              label: l10n.offlineBannerSemanticsLabel,
              liveRegion: true,
              child: MaterialBanner(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
                leading: Icon(
                  Icons.cloud_off,
                  color: colorScheme.onErrorContainer,
                ),
                content: Text(
                  l10n.offlineBannerMessage,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
                backgroundColor: colorScheme.errorContainer,
                actions: const [SizedBox.shrink()],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
