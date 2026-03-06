/// Immutable application-level user model.
///
/// Decoupled from Firebase — the repository layer maps Firebase [User] objects
/// to [AuthUser] so the rest of the app never depends on Firebase types.
library;

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
    this.phoneNumber,
  });

  final String uid;
  final String email;
  final bool emailVerified;
  final String? displayName;
  final String? phoneNumber;
}
