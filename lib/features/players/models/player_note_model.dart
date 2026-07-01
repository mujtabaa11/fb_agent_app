library;

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerNoteModel {
  const PlayerNoteModel({
    required this.id,
    required this.content,
    this.createdAt,
  });

  factory PlayerNoteModel.fromJson(Map<String, dynamic> json) {
    return PlayerNoteModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']),
    );
  }

  final String id;
  final String content;
  final DateTime? createdAt;

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
