library;

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyContactModel {
  const FamilyContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.createdAt,
  });

  factory FamilyContactModel.fromJson(Map<String, dynamic> json) {
    return FamilyContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
    );
  }

  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  FamilyContactModel copyWith({
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
  }) {
    return FamilyContactModel(
      id: id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
