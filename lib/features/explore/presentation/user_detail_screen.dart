/// Minimal user detail screen showing all [UserProfileModel] fields.
///
/// Navigated to by tapping a user card in the Explore list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../../../core/data/base_repository.dart';
import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../profile/data/user_profile_model.dart';

/// Detail screen for a single user profile.
class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({required this.userId, super.key});

  /// The Firestore document ID of the user to display.
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final BaseRepository<UserProfileModel> repository =
        ref.watch(userProfileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userDetailTitle)),
      body: FutureBuilder<Result<UserProfileModel>>(
        future: repository.read(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Semantics(
                label: l10n.loading,
                child: const CircularProgressIndicator(),
              ),
            );
          }

          final result = snapshot.data;
          if (result == null || result is Failure<UserProfileModel>) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: l10n.exploreLoadError,
              body: l10n.exploreLoadErrorBody,
            );
          }

          final profile = (result as Success<UserProfileModel>).value;
          return _UserDetailContent(profile: profile);
        },
      ),
    );
  }
}

class _UserDetailContent extends StatelessWidget {
  const _UserDetailContent({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(AppTokens.space24),
      child: Column(
        children: [
          const SizedBox(height: AppTokens.space16),

          // Avatar
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
          const SizedBox(height: AppTokens.space24),

          _DetailRow(
            label: l10n.userDetailDisplayName,
            value: profile.displayName,
          ),
          _DetailRow(
            label: l10n.userDetailEmail,
            value: profile.email,
          ),
          _DetailRow(
            label: l10n.userDetailCreatedAt,
            value: _formatDate(profile.createdAt, l10n),
          ),
          _DetailRow(
            label: l10n.userDetailUpdatedAt,
            value: _formatDate(profile.updatedAt, l10n),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.userDetailNoDate;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppTokens.space8,
      ),
      child: Semantics(
        label: '$label: $value',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
