library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'player_enums.dart';

class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.agentId,
    required this.status,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.countryOfResidence,
    required this.preferredPosition,
    required this.preferredFoot,
    required this.phoneNumber,
    required this.email,
    this.secondNationality,
    this.photoUrl,
    this.otherPositions,
    this.currentClub,
    this.leagueCountry,
    this.estimatedMarketValue,
    this.transfermarktUrl,
    this.representationAgreementStart,
    this.representationAgreementExpiry,
    this.clubContractExpiry,
    this.salary,
    this.salaryCurrency,
    this.whatsAppNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      status: json['status'] is String
          ? PlayerStatus.fromFirestoreValue(json['status'] as String)
          : PlayerStatus.prospect,
      fullName: json['fullName'] as String? ?? '',
      dateOfBirth: _timestampToDateTime(json['dateOfBirth']) ?? DateTime(1970),
      nationality: json['nationality'] as String? ?? '',
      secondNationality: json['secondNationality'] as String?,
      countryOfResidence: json['countryOfResidence'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      preferredPosition: json['preferredPosition'] is String
          ? PlayerPosition.fromFirestoreValue(
              json['preferredPosition'] as String)
          : PlayerPosition.cm,
      otherPositions: (json['otherPositions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredFoot: json['preferredFoot'] is String
          ? PreferredFoot.fromFirestoreValue(json['preferredFoot'] as String)
          : PreferredFoot.right,
      currentClub: json['currentClub'] as String?,
      leagueCountry: json['leagueCountry'] as String?,
      estimatedMarketValue: (json['estimatedMarketValue'] as num?)?.toDouble(),
      transfermarktUrl: json['transfermarktUrl'] as String?,
      representationAgreementStart:
          _timestampToDateTime(json['representationAgreementStart']),
      representationAgreementExpiry:
          _timestampToDateTime(json['representationAgreementExpiry']),
      clubContractExpiry: _timestampToDateTime(json['clubContractExpiry']),
      salary: (json['salary'] as num?)?.toDouble(),
      salaryCurrency: json['salaryCurrency'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      whatsAppNumber: json['whatsAppNumber'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String agentId;
  final PlayerStatus status;
  final String fullName;
  final DateTime dateOfBirth;
  final String nationality;
  final String? secondNationality;
  final String countryOfResidence;
  final String? photoUrl;
  final PlayerPosition preferredPosition;
  final List<String>? otherPositions;
  final PreferredFoot preferredFoot;
  final String? currentClub;
  final String? leagueCountry;
  final double? estimatedMarketValue;
  final String? transfermarktUrl;
  final DateTime? representationAgreementStart;
  final DateTime? representationAgreementExpiry;
  final DateTime? clubContractExpiry;
  final double? salary;
  final String? salaryCurrency;
  final String phoneNumber;
  final String email;
  final String? whatsAppNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'status': status.toFirestoreValue(),
      'fullName': fullName,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'nationality': nationality,
      if (secondNationality != null) 'secondNationality': secondNationality,
      'countryOfResidence': countryOfResidence,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'preferredPosition': preferredPosition.toFirestoreValue(),
      if (otherPositions != null) 'otherPositions': otherPositions,
      'preferredFoot': preferredFoot.toFirestoreValue(),
      if (currentClub != null) 'currentClub': currentClub,
      if (leagueCountry != null) 'leagueCountry': leagueCountry,
      if (estimatedMarketValue != null)
        'estimatedMarketValue': estimatedMarketValue,
      if (transfermarktUrl != null) 'transfermarktUrl': transfermarktUrl,
      if (representationAgreementStart != null)
        'representationAgreementStart':
            Timestamp.fromDate(representationAgreementStart!),
      if (representationAgreementExpiry != null)
        'representationAgreementExpiry':
            Timestamp.fromDate(representationAgreementExpiry!),
      if (clubContractExpiry != null)
        'clubContractExpiry': Timestamp.fromDate(clubContractExpiry!),
      if (salary != null) 'salary': salary,
      if (salaryCurrency != null) 'salaryCurrency': salaryCurrency,
      'phoneNumber': phoneNumber,
      'email': email,
      if (whatsAppNumber != null) 'whatsAppNumber': whatsAppNumber,
    };
  }

  PlayerModel copyWith({
    String? id,
    String? agentId,
    PlayerStatus? status,
    String? fullName,
    DateTime? dateOfBirth,
    String? nationality,
    String? Function()? secondNationality,
    String? countryOfResidence,
    String? Function()? photoUrl,
    PlayerPosition? preferredPosition,
    List<String>? Function()? otherPositions,
    PreferredFoot? preferredFoot,
    String? Function()? currentClub,
    String? Function()? leagueCountry,
    double? Function()? estimatedMarketValue,
    String? Function()? transfermarktUrl,
    DateTime? Function()? representationAgreementStart,
    DateTime? Function()? representationAgreementExpiry,
    DateTime? Function()? clubContractExpiry,
    double? Function()? salary,
    String? Function()? salaryCurrency,
    String? phoneNumber,
    String? email,
    String? Function()? whatsAppNumber,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      secondNationality: secondNationality != null
          ? secondNationality()
          : this.secondNationality,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      otherPositions:
          otherPositions != null ? otherPositions() : this.otherPositions,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      currentClub: currentClub != null ? currentClub() : this.currentClub,
      leagueCountry:
          leagueCountry != null ? leagueCountry() : this.leagueCountry,
      estimatedMarketValue: estimatedMarketValue != null
          ? estimatedMarketValue()
          : this.estimatedMarketValue,
      transfermarktUrl:
          transfermarktUrl != null ? transfermarktUrl() : this.transfermarktUrl,
      representationAgreementStart: representationAgreementStart != null
          ? representationAgreementStart()
          : this.representationAgreementStart,
      representationAgreementExpiry: representationAgreementExpiry != null
          ? representationAgreementExpiry()
          : this.representationAgreementExpiry,
      clubContractExpiry: clubContractExpiry != null
          ? clubContractExpiry()
          : this.clubContractExpiry,
      salary: salary != null ? salary() : this.salary,
      salaryCurrency:
          salaryCurrency != null ? salaryCurrency() : this.salaryCurrency,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      whatsAppNumber:
          whatsAppNumber != null ? whatsAppNumber() : this.whatsAppNumber,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
