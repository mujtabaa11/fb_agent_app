library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../players/models/player_enums.dart';
import 'external_link_model.dart';
import 'market_post_enums.dart';

class MarketPostModel {
  const MarketPostModel({
    required this.id,
    required this.agentId,
    required this.type,
    required this.status,
    required this.description,
    required this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.playerId,
    this.playerPhotoUrl,
    this.playerPosition,
    this.playerNationality,
    this.playerLeagueCountry,
    this.playerAge,
    this.playerMarketValue,
    this.transfermarktUrl,
    this.isPlayerAnonymous = false,
    this.externalLinks,
    this.neededPosition,
    this.neededNationalities,
    this.neededMinAge,
    this.neededMaxAge,
    this.neededLeagueCountry,
    this.budget,
  });

  factory MarketPostModel.fromJson(Map<String, dynamic> json) {
    return MarketPostModel(
      id: json['id'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      type: json['type'] is String
          ? MarketPostType.fromFirestoreValue(json['type'] as String)
          : MarketPostType.playerAvailable,
      status: json['status'] is String
          ? MarketPostStatus.fromFirestoreValue(json['status'] as String)
          : MarketPostStatus.active,
      description: json['description'] as String? ?? '',
      expiresAt: _timestampToDateTime(json['expiresAt']) ?? DateTime.now(),
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
      playerId: json['playerId'] as String?,
      playerPhotoUrl: json['playerPhotoUrl'] as String?,
      playerPosition: json['playerPosition'] is String
          ? PlayerPosition.fromFirestoreValue(json['playerPosition'] as String)
          : null,
      playerNationality: json['playerNationality'] as String?,
      playerLeagueCountry: json['playerLeagueCountry'] as String?,
      playerAge: json['playerAge'] as int?,
      playerMarketValue: (json['playerMarketValue'] as num?)?.toDouble(),
      transfermarktUrl: json['transfermarktUrl'] as String?,
      isPlayerAnonymous: json['isPlayerAnonymous'] as bool? ?? false,
      externalLinks: (json['externalLinks'] as List<dynamic>?)
          ?.map((e) => ExternalLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      neededPosition: json['neededPosition'] is String
          ? PlayerPosition.fromFirestoreValue(json['neededPosition'] as String)
          : null,
      neededNationalities: (json['neededNationalities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      neededMinAge: json['neededMinAge'] as int?,
      neededMaxAge: json['neededMaxAge'] as int?,
      neededLeagueCountry: json['neededLeagueCountry'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String agentId;
  final MarketPostType type;
  final MarketPostStatus status;
  final String description;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Player Available fields
  final String? playerId;
  final String? playerPhotoUrl;
  final PlayerPosition? playerPosition;
  final String? playerNationality;
  final String? playerLeagueCountry;
  final int? playerAge;
  final double? playerMarketValue;
  final String? transfermarktUrl;
  final bool isPlayerAnonymous;
  final List<ExternalLinkModel>? externalLinks;

  // Need a Player fields
  final PlayerPosition? neededPosition;
  final List<String>? neededNationalities;
  final int? neededMinAge;
  final int? neededMaxAge;
  final String? neededLeagueCountry;
  final double? budget;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'type': type.toFirestoreValue(),
      'status': status.toFirestoreValue(),
      'description': description,
      'expiresAt': Timestamp.fromDate(expiresAt),
      if (playerId != null) 'playerId': playerId,
      if (playerPhotoUrl != null) 'playerPhotoUrl': playerPhotoUrl,
      if (playerPosition != null)
        'playerPosition': playerPosition!.toFirestoreValue(),
      if (playerNationality != null) 'playerNationality': playerNationality,
      if (playerLeagueCountry != null)
        'playerLeagueCountry': playerLeagueCountry,
      if (playerAge != null) 'playerAge': playerAge,
      if (playerMarketValue != null) 'playerMarketValue': playerMarketValue,
      if (transfermarktUrl != null) 'transfermarktUrl': transfermarktUrl,
      'isPlayerAnonymous': isPlayerAnonymous,
      if (externalLinks != null)
        'externalLinks': externalLinks!.map((e) => e.toJson()).toList(),
      if (neededPosition != null)
        'neededPosition': neededPosition!.toFirestoreValue(),
      if (neededNationalities != null)
        'neededNationalities': neededNationalities,
      if (neededMinAge != null) 'neededMinAge': neededMinAge,
      if (neededMaxAge != null) 'neededMaxAge': neededMaxAge,
      if (neededLeagueCountry != null)
        'neededLeagueCountry': neededLeagueCountry,
      if (budget != null) 'budget': budget,
    };
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
