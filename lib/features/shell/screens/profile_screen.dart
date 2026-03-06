/// Profile tab screen.
///
/// Displays the authenticated user's profile loaded via
/// [ProfileViewModel]. Handles loading, success, and failure states.
/// Includes an avatar upload flow that demonstrates the
/// upload-then-update chained pattern.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../profile/presentation/delete_account_sheet.dart';
import '../../profile/presentation/profile_state.dart';
import '../../profile/presentation/profile_view_model.dart';

/// Minimum touch target dimension recommended by WCAG 2.1 SC 2.5.5.
const double _kMinTouchTarget = 44;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileViewModelProvider);

    // Show snackbar when upload error occurs.
    ref.listen<AsyncValue<ProfileState>>(profileViewModelProvider,
        (previous, next) {
      final error = next.valueOrNull?.uploadError;
      if (error != null && error != previous?.valueOrNull?.uploadError) {
        final message = _resolveErrorKey(l10n, error);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }

      // Show snackbar when a write was saved offline.
      final savedOffline = next.valueOrNull?.savedOffline ?? false;
      final wasSavedOffline = previous?.valueOrNull?.savedOffline ?? false;
      if (savedOffline && !wasSavedOffline) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.offlineSaveMessage)));
      }
    });

    return profileAsync.when(
      loading: () => Center(
        child: Semantics(
          label: l10n.loading,
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => EmptyStateWidget(
        icon: Icons.error_outline,
        title: l10n.profileLoadErrorTitle,
        body: l10n.profileLoadErrorBody,
        actionLabel: l10n.retryButton,
        onAction: () => ref.invalidate(profileViewModelProvider),
      ),
      data: (profileState) {
        final profile = profileState.profile;
        final uploadProgress = profileState.uploadProgress;
        final isUploading = uploadProgress != null;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(AppTokens.space24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: AppTokens.space16),

                // Avatar area
                Semantics(
                  label: l10n.profileAvatarLabel,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: ClipOval(
                      child: SizedBox.square(
                        dimension: 96,
                        child: profile.avatarUrl != null
                            ? Image.network(
                                profile.avatarUrl!,
                                fit: BoxFit.cover,
                                width: 96,
                                height: 96,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 48,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 48,
                                color: colorScheme.onPrimaryContainer,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space12),

                // Upload Photo button
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: _kMinTouchTarget,
                    minHeight: _kMinTouchTarget,
                  ),
                  child: isUploading
                      ? Semantics(
                          label: l10n.avatarUploadProgress,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  value: uploadProgress,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: AppTokens.space8),
                              Text(
                                l10n.avatarUploadProgress,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : Semantics(
                          button: true,
                          label: l10n.uploadPhotoButton,
                          child: TextButton.icon(
                            onPressed: () => ref
                                .read(profileViewModelProvider.notifier)
                                .uploadAvatar(),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(l10n.uploadPhotoButton),
                          ),
                        ),
                ),
                const SizedBox(height: AppTokens.space16),

                // Display name
                Semantics(
                  label:
                      '${l10n.profileDisplayNameLabel}: ${profile.displayName}',
                  child: ExcludeSemantics(
                    child: Text(
                      profile.displayName,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space8),

                // Email
                Semantics(
                  label: '${l10n.profileEmailLabel}: ${profile.email}',
                  child: ExcludeSemantics(
                    child: Text(
                      profile.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space32),

                // Retry / refresh button
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: _kMinTouchTarget,
                    minHeight: _kMinTouchTarget,
                  ),
                  child: Semantics(
                    button: true,
                    label: l10n.retryButton,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(profileViewModelProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retryButton),
                    ),
                  ),
                ),

                const SizedBox(height: AppTokens.space32),
                const Divider(),
                const SizedBox(height: AppTokens.space16),

                // Delete Account button — destructive, positioned at bottom
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: _kMinTouchTarget,
                    minHeight: _kMinTouchTarget,
                  ),
                  child: Semantics(
                    button: true,
                    label: l10n.deleteAccountButton,
                    child: OutlinedButton.icon(
                      onPressed: () => showDeleteAccountSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.deleteAccountButton),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Maps a localisation key string to the corresponding translated message.
  String _resolveErrorKey(AppLocalizations l10n, String key) {
    return switch (key) {
      'avatarImageTooLargeError' => l10n.avatarImageTooLargeError,
      'photoLibraryPermissionDenied' => l10n.photoLibraryPermissionDenied,
      'avatarUploadErrorBody' => l10n.avatarUploadErrorBody,
      _ => l10n.errorGeneric,
    };
  }
}
