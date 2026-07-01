library;

import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyContactModel {
  const FamilyContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.createdAt,
  });

  factory FamilyContactModel.fromJson(Map<String, dynamic> json) {
    return FamilyContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']),
    );
  }

  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final DateTime? createdAt;

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
