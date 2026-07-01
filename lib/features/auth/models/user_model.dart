/// Application-level agent/user model.
///
/// Placeholder shape for Phase 0 — will be backed by the Firestore `users`
/// collection (see `currentAgentProvider`) once account setup is built.
library;

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.country,
    required this.isProfileComplete,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String country;
  final bool isProfileComplete;
  final String? avatarUrl;
}
