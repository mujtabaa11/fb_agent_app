library;

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.country,
    required this.isProfileComplete,
    this.avatarUrl,
    this.isFifaRegistered,
    this.licenceNumber,
    this.bio,
    this.agencyName,
    this.yearsOfExperience,
    this.phoneNumber,
    this.isPhoneOnWhatsApp,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      isFifaRegistered: json['isFifaRegistered'] as bool?,
      licenceNumber: json['licenceNumber'] as String?,
      bio: json['bio'] as String?,
      agencyName: json['agencyName'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
      isPhoneOnWhatsApp: json['isPhoneOnWhatsApp'] as bool?,
      email: json['email'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String fullName;
  final String country;
  final bool isProfileComplete;
  final String? avatarUrl;
  final bool? isFifaRegistered;
  final String? licenceNumber;
  final String? bio;
  final String? agencyName;
  final int? yearsOfExperience;
  final String? phoneNumber;
  final bool? isPhoneOnWhatsApp;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'country': country,
      'isProfileComplete': isProfileComplete,
      'avatarUrl': avatarUrl,
      'isFifaRegistered': isFifaRegistered,
      'licenceNumber': licenceNumber,
      'bio': bio,
      'agencyName': agencyName,
      'yearsOfExperience': yearsOfExperience,
      'phoneNumber': phoneNumber,
      'isPhoneOnWhatsApp': isPhoneOnWhatsApp,
      'email': email,
    };
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
