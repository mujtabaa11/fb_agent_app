library;

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerDocumentModel {
  const PlayerDocumentModel({
    required this.id,
    required this.label,
    required this.fileUrl,
    this.fileType,
    this.uploadedAt,
  });

  factory PlayerDocumentModel.fromJson(Map<String, dynamic> json) {
    return PlayerDocumentModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      fileType: json['fileType'] as String?,
      uploadedAt: _timestampToDateTime(json['uploadedAt']),
    );
  }

  final String id;
  final String label;
  final String fileUrl;
  final String? fileType;
  final DateTime? uploadedAt;

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
