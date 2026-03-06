/// Immutable state for the Profile screen.
///
/// Combines the [UserProfileModel] with transient UI state such as
/// [uploadProgress] so that the ViewModel can drive both data display
/// and upload feedback from a single [AsyncValue].
library;

import '../data/user_profile_model.dart';

/// Profile screen state.
class ProfileState {
  const ProfileState({
    required this.profile,
    this.uploadProgress,
    this.uploadError,
    this.savedOffline = false,
  });

  /// The user's profile data.
  final UserProfileModel profile;

  /// Upload progress — `null` when no upload is active, 0.0–1.0 during
  /// an active upload.
  final double? uploadProgress;

  /// A localisation key surfaced when the upload fails. `null` when there
  /// is no error.
  final String? uploadError;

  /// `true` when a write succeeded while the device was offline.
  /// The UI should show a snackbar and reset this flag.
  final bool savedOffline;

  /// Returns a copy with the given fields replaced.
  ProfileState copyWith({
    UserProfileModel? profile,
    double? Function()? uploadProgress,
    String? Function()? uploadError,
    bool? savedOffline,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      uploadProgress:
          uploadProgress != null ? uploadProgress() : this.uploadProgress,
      uploadError: uploadError != null ? uploadError() : this.uploadError,
      savedOffline: savedOffline ?? this.savedOffline,
    );
  }
}
