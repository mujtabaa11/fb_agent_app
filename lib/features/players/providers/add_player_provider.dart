library;

import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../../auth/providers/agent_providers.dart';
import '../models/player_enums.dart';
import '../models/player_model.dart';
import 'player_providers.dart';

part 'add_player_provider.g.dart';

class AddPlayerState {
  const AddPlayerState({
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  AddPlayerState copyWith({
    bool? isSaving,
    String? Function()? errorMessage,
    bool? isSuccess,
  }) {
    return AddPlayerState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

@riverpod
class AddPlayerNotifier extends _$AddPlayerNotifier {
  @override
  AddPlayerState build() => const AddPlayerState();

  Future<void> savePlayer({
    required String fullName,
    required DateTime dateOfBirth,
    required String nationality,
    String? secondNationality,
    required String countryOfResidence,
    String? photoFilePath,
    required PlayerPosition preferredPosition,
    List<String>? otherPositions,
    required PreferredFoot preferredFoot,
    String? currentClub,
    String? leagueCountry,
    double? estimatedMarketValue,
    String? transfermarktUrl,
    DateTime? representationAgreementStart,
    DateTime? representationAgreementExpiry,
    DateTime? clubContractExpiry,
    double? salary,
    String? salaryCurrency,
    required String phoneNumber,
    required String email,
    String? whatsAppNumber,
    required PlayerStatus status,
  }) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: () => null,
    );

    final agent = ref.read(currentAgentProvider);
    if (agent == null) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: () => 'Not authenticated.',
      );
      return;
    }

    final repo = ref.read(playerRepositoryProvider);
    String? photoUrl;

    if (photoFilePath != null) {
      final storageService = ref.read(cloudStorageProvider);
      final file = File(photoFilePath);
      final bytes = await file.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'players/${agent.id}/$timestamp/photo.jpg';
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

    final now = DateTime.now();
    final player = PlayerModel(
      id: '',
      agentId: agent.id,
      status: status,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      secondNationality: secondNationality,
      countryOfResidence: countryOfResidence,
      photoUrl: photoUrl,
      preferredPosition: preferredPosition,
      otherPositions: otherPositions,
      preferredFoot: preferredFoot,
      currentClub: currentClub,
      leagueCountry: leagueCountry,
      estimatedMarketValue: estimatedMarketValue,
      transfermarktUrl: transfermarktUrl,
      representationAgreementStart: representationAgreementStart,
      representationAgreementExpiry: representationAgreementExpiry,
      clubContractExpiry: clubContractExpiry,
      salary: salary,
      salaryCurrency: salaryCurrency,
      phoneNumber: phoneNumber,
      email: email,
      whatsAppNumber: whatsAppNumber,
      createdAt: now,
      updatedAt: now,
    );

    final result = await repo.addPlayer(player);
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
