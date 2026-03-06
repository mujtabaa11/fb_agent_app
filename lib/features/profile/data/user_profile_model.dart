/// Firestore-backed user profile model.
///
/// [id] is the Firestore document ID — it is not written back in [toJson]
/// because the repository layer manages it as the document key.
///
/// [createdAt] and [updatedAt] are server-managed timestamps — they are
/// read via [fromJson] but excluded from [toJson] so that
/// [FirestoreRepository] can inject `FieldValue.serverTimestamp()`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable profile document stored in the `users` Firestore collection.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Deserialises a Firestore document map into a [UserProfileModel].
  ///
  /// Handles missing keys gracefully — no field will throw on a null value.
  /// Firestore [Timestamp] values are converted to [DateTime].
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Serialises this model for Firestore writes.
  ///
  /// Excludes [id] (document key), [createdAt], and [updatedAt]
  /// (server-managed timestamps).
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  /// Returns a copy of this model with the given fields replaced.
  UserProfileModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts a Firestore [Timestamp] or a [DateTime] to [DateTime].
  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
