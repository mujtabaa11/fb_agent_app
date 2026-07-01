library;

import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../models/player_enums.dart';
import '../models/player_model.dart';
import 'player_providers.dart';

part 'edit_player_provider.g.dart';

class EditPlayerState {
  const EditPlayerState({
    this.isLoading = true,
    this.isSaving = false,
    this.isSuccess = false,
    this.errorMessage,
    this.loadError,
    this.player,
    this.fullName = '',
    this.dateOfBirth,
    this.nationality,
    this.secondNationality,
    this.countryOfResidence,
    this.photoUrl,
    this.preferredPosition,
    this.otherPositions = const {},
    this.preferredFoot,
    this.currentClub,
    this.leagueCountry,
    this.estimatedMarketValue,
    this.marketValueCurrency,
    this.transfermarktUrl,
    this.agentContractStart,
    this.agentContractExpiry,
    this.clubContractExpiry,
    this.salary,
    this.salaryCurrency,
    this.phoneNumber = '',
    this.email = '',
    this.whatsAppNumber,
    this.status,
    this.newPhotoFilePath,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isSuccess;
  final String? errorMessage;
  final String? loadError;
  final PlayerModel? player;

  final String fullName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? secondNationality;
  final String? countryOfResidence;
  final String? photoUrl;
  final PlayerPosition? preferredPosition;
  final Set<String> otherPositions;
  final PreferredFoot? preferredFoot;
  final String? currentClub;
  final String? leagueCountry;
  final double? estimatedMarketValue;
  final String? marketValueCurrency;
  final String? transfermarktUrl;
  final DateTime? agentContractStart;
  final DateTime? agentContractExpiry;
  final DateTime? clubContractExpiry;
  final double? salary;
  final String? salaryCurrency;
  final String phoneNumber;
  final String email;
  final String? whatsAppNumber;
  final PlayerStatus? status;
  final String? newPhotoFilePath;

  bool get isDirty {
    final p = player;
    if (p == null) return false;
    return fullName != p.fullName ||
        dateOfBirth != p.dateOfBirth ||
        nationality != p.nationality ||
        (secondNationality ?? '') != (p.secondNationality ?? '') ||
        countryOfResidence != p.countryOfResidence ||
        preferredPosition != p.preferredPosition ||
        !_setsEqual(otherPositions, (p.otherPositions ?? []).toSet()) ||
        preferredFoot != p.preferredFoot ||
        (currentClub ?? '') != (p.currentClub ?? '') ||
        (leagueCountry ?? '') != (p.leagueCountry ?? '') ||
        estimatedMarketValue != p.estimatedMarketValue ||
        marketValueCurrency != p.marketValueCurrency ||
        (transfermarktUrl ?? '') != (p.transfermarktUrl ?? '') ||
        agentContractStart != p.agentContractStart ||
        agentContractExpiry != p.agentContractExpiry ||
        clubContractExpiry != p.clubContractExpiry ||
        salary != p.salary ||
        salaryCurrency != p.salaryCurrency ||
        phoneNumber != p.phoneNumber ||
        email != p.email ||
        (whatsAppNumber ?? '') != (p.whatsAppNumber ?? '') ||
        status != p.status ||
        newPhotoFilePath != null;
  }

  static bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  EditPlayerState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSuccess,
    String? Function()? errorMessage,
    String? Function()? loadError,
    PlayerModel? Function()? player,
    String? fullName,
    DateTime? Function()? dateOfBirth,
    String? Function()? nationality,
    String? Function()? secondNationality,
    String? Function()? countryOfResidence,
    String? Function()? photoUrl,
    PlayerPosition? Function()? preferredPosition,
    Set<String>? otherPositions,
    PreferredFoot? Function()? preferredFoot,
    String? Function()? currentClub,
    String? Function()? leagueCountry,
    double? Function()? estimatedMarketValue,
    String? Function()? marketValueCurrency,
    String? Function()? transfermarktUrl,
    DateTime? Function()? agentContractStart,
    DateTime? Function()? agentContractExpiry,
    DateTime? Function()? clubContractExpiry,
    double? Function()? salary,
    String? Function()? salaryCurrency,
    String? phoneNumber,
    String? email,
    String? Function()? whatsAppNumber,
    PlayerStatus? Function()? status,
    String? Function()? newPhotoFilePath,
  }) {
    return EditPlayerState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      loadError: loadError != null ? loadError() : this.loadError,
      player: player != null ? player() : this.player,
      fullName: fullName ?? this.fullName,
      dateOfBirth:
          dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
      nationality:
          nationality != null ? nationality() : this.nationality,
      secondNationality: secondNationality != null
          ? secondNationality()
          : this.secondNationality,
      countryOfResidence: countryOfResidence != null
          ? countryOfResidence()
          : this.countryOfResidence,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      preferredPosition: preferredPosition != null
          ? preferredPosition()
          : this.preferredPosition,
      otherPositions: otherPositions ?? this.otherPositions,
      preferredFoot:
          preferredFoot != null ? preferredFoot() : this.preferredFoot,
      currentClub:
          currentClub != null ? currentClub() : this.currentClub,
      leagueCountry:
          leagueCountry != null ? leagueCountry() : this.leagueCountry,
      estimatedMarketValue: estimatedMarketValue != null
          ? estimatedMarketValue()
          : this.estimatedMarketValue,
      marketValueCurrency: marketValueCurrency != null
          ? marketValueCurrency()
          : this.marketValueCurrency,
      transfermarktUrl: transfermarktUrl != null
          ? transfermarktUrl()
          : this.transfermarktUrl,
      agentContractStart: agentContractStart != null
          ? agentContractStart()
          : this.agentContractStart,
      agentContractExpiry: agentContractExpiry != null
          ? agentContractExpiry()
          : this.agentContractExpiry,
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
      status: status != null ? status() : this.status,
      newPhotoFilePath: newPhotoFilePath != null
          ? newPhotoFilePath()
          : this.newPhotoFilePath,
    );
  }
}

@riverpod
class EditPlayerNotifier extends _$EditPlayerNotifier {
  @override
  EditPlayerState build(String playerId) {
    _loadPlayer();
    return const EditPlayerState();
  }

  Future<void> _loadPlayer() async {
    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.getPlayer(playerId);
    switch (result) {
      case Success(:final value):
        state = EditPlayerState(
          isLoading: false,
          player: value,
          fullName: value.fullName,
          dateOfBirth: value.dateOfBirth,
          nationality: value.nationality,
          secondNationality: value.secondNationality,
          countryOfResidence: value.countryOfResidence,
          photoUrl: value.photoUrl,
          preferredPosition: value.preferredPosition,
          otherPositions: (value.otherPositions ?? []).toSet(),
          preferredFoot: value.preferredFoot,
          currentClub: value.currentClub,
          leagueCountry: value.leagueCountry,
          estimatedMarketValue: value.estimatedMarketValue,
          marketValueCurrency: value.marketValueCurrency,
          transfermarktUrl: value.transfermarktUrl,
          agentContractStart: value.agentContractStart,
          agentContractExpiry: value.agentContractExpiry,
          clubContractExpiry: value.clubContractExpiry,
          salary: value.salary,
          salaryCurrency: value.salaryCurrency,
          phoneNumber: value.phoneNumber,
          email: value.email,
          whatsAppNumber: value.whatsAppNumber,
          status: value.status,
        );
      case Failure(:final exception):
        state = EditPlayerState(
          isLoading: false,
          loadError: exception.message,
        );
    }
  }

  Future<void> retry() async {
    state = const EditPlayerState();
    await _loadPlayer();
  }

  void updateFullName(String value) {
    state = state.copyWith(fullName: value);
  }

  void updateDateOfBirth(DateTime? value) {
    state = state.copyWith(dateOfBirth: () => value);
  }

  void updateNationality(String? value) {
    state = state.copyWith(nationality: () => value);
  }

  void updateSecondNationality(String? value) {
    state = state.copyWith(secondNationality: () => value);
  }

  void updateCountryOfResidence(String? value) {
    state = state.copyWith(countryOfResidence: () => value);
  }

  void updatePreferredPosition(PlayerPosition? value) {
    state = state.copyWith(preferredPosition: () => value);
  }

  void toggleOtherPosition(String posValue) {
    final positions = Set<String>.from(state.otherPositions);
    if (positions.contains(posValue)) {
      positions.remove(posValue);
    } else {
      positions.add(posValue);
    }
    state = state.copyWith(otherPositions: positions);
  }

  void updatePreferredFoot(PreferredFoot? value) {
    state = state.copyWith(preferredFoot: () => value);
  }

  void updateCurrentClub(String? value) {
    state = state.copyWith(currentClub: () => value);
  }

  void updateLeagueCountry(String? value) {
    state = state.copyWith(leagueCountry: () => value);
  }

  void updateEstimatedMarketValue(double? value) {
    state = state.copyWith(estimatedMarketValue: () => value);
  }

  void updateMarketValueCurrency(String? value) {
    state = state.copyWith(marketValueCurrency: () => value);
  }

  void updateTransfermarktUrl(String? value) {
    state = state.copyWith(transfermarktUrl: () => value);
  }

  void updateAgentContractStart(DateTime? value) {
    state = state.copyWith(agentContractStart: () => value);
  }

  void updateAgentContractExpiry(DateTime? value) {
    state = state.copyWith(agentContractExpiry: () => value);
  }

  void updateClubContractExpiry(DateTime? value) {
    state = state.copyWith(clubContractExpiry: () => value);
  }

  void updateSalary(double? value) {
    state = state.copyWith(salary: () => value);
  }

  void updateSalaryCurrency(String? value) {
    state = state.copyWith(salaryCurrency: () => value);
  }

  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updateWhatsAppNumber(String? value) {
    state = state.copyWith(whatsAppNumber: () => value);
  }

  void updateStatus(PlayerStatus? value) {
    state = state.copyWith(status: () => value);
  }

  void setNewPhoto(String filePath) {
    state = state.copyWith(newPhotoFilePath: () => filePath);
  }

  Future<void> saveChanges() async {
    final player = state.player;
    if (player == null) return;

    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
    );

    String? photoUrl = state.photoUrl;

    if (state.newPhotoFilePath != null) {
      final storageService = ref.read(cloudStorageProvider);
      final file = File(state.newPhotoFilePath!);
      final bytes = await file.readAsBytes();
      final storagePath = 'players/${player.id}/photo.jpg';
      final uploadResult = await storageService.uploadFile(
        storagePath,
        Uint8List.fromList(bytes),
      );
      switch (uploadResult) {
        case Success(:final value):
          photoUrl = value;
        case Failure(:final exception):
          state = state.copyWith(
            isSaving: false,
            errorMessage: () => exception.message,
          );
          return;
      }
    }

    final updatedPlayer = player.copyWith(
      fullName: state.fullName,
      dateOfBirth: state.dateOfBirth,
      nationality: state.nationality,
      secondNationality: () =>
          state.secondNationality?.isEmpty == true
              ? null
              : state.secondNationality,
      countryOfResidence: state.countryOfResidence,
      photoUrl: () => photoUrl,
      preferredPosition: state.preferredPosition,
      otherPositions: () => state.otherPositions.isEmpty
          ? null
          : state.otherPositions.toList(),
      preferredFoot: state.preferredFoot,
      currentClub: () =>
          state.currentClub?.isEmpty == true ? null : state.currentClub,
      leagueCountry: () =>
          state.leagueCountry?.isEmpty == true ? null : state.leagueCountry,
      estimatedMarketValue: () => state.estimatedMarketValue,
      marketValueCurrency: () => state.marketValueCurrency,
      transfermarktUrl: () => state.transfermarktUrl?.isEmpty == true
          ? null
          : state.transfermarktUrl,
      agentContractStart: () => state.agentContractStart,
      agentContractExpiry: () => state.agentContractExpiry,
      clubContractExpiry: () => state.clubContractExpiry,
      salary: () => state.salary,
      salaryCurrency: () => state.salaryCurrency,
      phoneNumber: state.phoneNumber,
      email: state.email,
      whatsAppNumber: () => state.whatsAppNumber?.isEmpty == true
          ? null
          : state.whatsAppNumber,
      status: state.status,
    );

    final repo = ref.read(playerRepositoryProvider);
    final result = await repo.updatePlayer(updatedPlayer);
    switch (result) {
      case Success():
        state = state.copyWith(isSaving: false, isSuccess: true);
      case Failure(:final exception):
        state = state.copyWith(
          isSaving: false,
          errorMessage: () => exception.message,
        );
    }
  }
}
