library;

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerNoteModel {
  const PlayerNoteModel({
    required this.id,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerNoteModel.fromJson(Map<String, dynamic> json) {
    return PlayerNoteModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isEdited =>
      createdAt != null && updatedAt != null && updatedAt != createdAt;

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  PlayerNoteModel copyWith({String? content, DateTime? updatedAt}) {
    return PlayerNoteModel(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
