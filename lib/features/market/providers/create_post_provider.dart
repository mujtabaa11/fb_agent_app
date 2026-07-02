library;

import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../../core/storage/cloud_storage_providers.dart';
import '../../auth/providers/agent_providers.dart';
import '../../players/models/player_enums.dart';
import '../../players/models/player_model.dart';
import '../models/external_link_model.dart';
import '../models/market_post_enums.dart';
import '../models/market_post_model.dart';
import 'market_feed_provider.dart';

part 'create_post_provider.g.dart';

int _calculateAge(DateTime dateOfBirth) {
  final now = DateTime.now();
  var age = now.year - dateOfBirth.year;
  if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

class CreatePlayerAvailablePostState {
  const CreatePlayerAvailablePostState({
    this.linkedPlayerId,
    this.linkedPlayerName,
    this.playerPhotoLocalPath,
    this.playerPhotoUrl,
    this.playerPosition,
    this.playerNationality,
    this.playerLeagueCountry,
    this.playerAge,
    this.playerMarketValue,
    this.transfermarktUrl,
    this.isPlayerAnonymous = false,
    this.description = '',
    DateTime? expiresAt,
    this.externalLinks = const [],
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  }) : _expiresAt = expiresAt;

  final String? linkedPlayerId;
  final String? linkedPlayerName;
  final String? playerPhotoLocalPath;
  final String? playerPhotoUrl;
  final PlayerPosition? playerPosition;
  final String? playerNationality;
  final String? playerLeagueCountry;
  final int? playerAge;
  final double? playerMarketValue;
  final String? transfermarktUrl;
  final bool isPlayerAnonymous;
  final String description;
  final DateTime? _expiresAt;
  final List<ExternalLinkModel> externalLinks;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  DateTime get expiresAt =>
      _expiresAt ?? DateTime.now().add(const Duration(days: 30));

  bool get isFormValid => description.trim().isNotEmpty;

  CreatePlayerAvailablePostState copyWith({
    String? Function()? linkedPlayerId,
    String? Function()? linkedPlayerName,
    String? Function()? playerPhotoLocalPath,
    String? Function()? playerPhotoUrl,
    PlayerPosition? Function()? playerPosition,
    String? Function()? playerNationality,
    String? Function()? playerLeagueCountry,
    int? Function()? playerAge,
    double? Function()? playerMarketValue,
    String? Function()? transfermarktUrl,
    bool? isPlayerAnonymous,
    String? description,
    DateTime? expiresAt,
    List<ExternalLinkModel>? externalLinks,
    bool? isSaving,
    String? Function()? errorMessage,
    bool? isSuccess,
  }) {
    return CreatePlayerAvailablePostState(
      linkedPlayerId:
          linkedPlayerId != null ? linkedPlayerId() : this.linkedPlayerId,
      linkedPlayerName:
          linkedPlayerName != null ? linkedPlayerName() : this.linkedPlayerName,
      playerPhotoLocalPath: playerPhotoLocalPath != null
          ? playerPhotoLocalPath()
          : this.playerPhotoLocalPath,
      playerPhotoUrl:
          playerPhotoUrl != null ? playerPhotoUrl() : this.playerPhotoUrl,
      playerPosition:
          playerPosition != null ? playerPosition() : this.playerPosition,
      playerNationality: playerNationality != null
          ? playerNationality()
          : this.playerNationality,
      playerLeagueCountry: playerLeagueCountry != null
          ? playerLeagueCountry()
          : this.playerLeagueCountry,
      playerAge: playerAge != null ? playerAge() : this.playerAge,
      playerMarketValue:
          playerMarketValue != null ? playerMarketValue() : this.playerMarketValue,
      transfermarktUrl:
          transfermarktUrl != null ? transfermarktUrl() : this.transfermarktUrl,
      isPlayerAnonymous: isPlayerAnonymous ?? this.isPlayerAnonymous,
      description: description ?? this.description,
      expiresAt: expiresAt ?? _expiresAt,
      externalLinks: externalLinks ?? this.externalLinks,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

@riverpod
class CreatePlayerAvailablePostNotifier
    extends _$CreatePlayerAvailablePostNotifier {
  String? _reservedPostId;

  @override
  CreatePlayerAvailablePostState build() =>
      const CreatePlayerAvailablePostState();

  void linkPlayer(PlayerModel player) {
    state = state.copyWith(
      linkedPlayerId: () => player.id,
      linkedPlayerName: () => player.fullName,
      playerPhotoLocalPath: () => null,
      playerPhotoUrl: () => player.photoUrl,
      playerPosition: () => player.preferredPosition,
      playerNationality: () => player.nationality,
      playerLeagueCountry: () => player.leagueCountry,
      playerAge: () => _calculateAge(player.dateOfBirth),
      playerMarketValue: () => player.estimatedMarketValue,
      transfermarktUrl: () => player.transfermarktUrl,
    );
  }

  void unlinkPlayer() {
    state = state.copyWith(
      linkedPlayerId: () => null,
      linkedPlayerName: () => null,
      playerPhotoLocalPath: () => null,
      playerPhotoUrl: () => null,
      playerPosition: () => null,
      playerNationality: () => null,
      playerLeagueCountry: () => null,
      playerAge: () => null,
      playerMarketValue: () => null,
      transfermarktUrl: () => null,
    );
  }

  void setPlayerPhotoLocalPath(String? path) {
    state = state.copyWith(playerPhotoLocalPath: () => path);
  }

  void setPlayerPosition(PlayerPosition? value) {
    state = state.copyWith(playerPosition: () => value);
  }

  void setPlayerNationality(String? value) {
    state = state.copyWith(playerNationality: () => value);
  }

  void setPlayerLeagueCountry(String? value) {
    state = state.copyWith(playerLeagueCountry: () => value);
  }

  void setPlayerAge(int? value) {
    state = state.copyWith(playerAge: () => value);
  }

  void setPlayerMarketValue(double? value) {
    state = state.copyWith(playerMarketValue: () => value);
  }

  void setTransfermarktUrl(String? value) {
    state = state.copyWith(transfermarktUrl: () => value);
  }

  void setAnonymous(bool value) {
    state = state.copyWith(isPlayerAnonymous: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setExpiresAt(DateTime value) {
    state = state.copyWith(expiresAt: value);
  }

  void addExternalLink(ExternalLinkModel link) {
    if (state.externalLinks.length >= 5) return;
    state = state.copyWith(
      externalLinks: [...state.externalLinks, link],
    );
  }

  void updateExternalLink(int index, ExternalLinkModel link) {
    final links = [...state.externalLinks];
    links[index] = link;
    state = state.copyWith(externalLinks: links);
  }

  void removeExternalLink(int index) {
    final links = [...state.externalLinks]..removeAt(index);
    state = state.copyWith(externalLinks: links);
  }

  Future<void> savePost() async {
    if (!state.isFormValid) return;

    state = state.copyWith(isSaving: true, errorMessage: () => null);

    final agent = ref.read(currentAgentProvider);
    if (agent == null) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: () => 'Not authenticated.',
      );
      return;
    }

    final isAnonymous = state.isPlayerAnonymous;

    final repo = ref.read(marketRepositoryProvider);
    final postId = _reservedPostId ??= repo.generatePostId();

    String? photoUrl = isAnonymous ? null : state.playerPhotoUrl;

    if (!isAnonymous && state.playerPhotoLocalPath != null) {
      final storageService = ref.read(cloudStorageProvider);
      final file = File(state.playerPhotoLocalPath!);
      final bytes = await file.readAsBytes();
      final storagePath = 'market_posts/$postId/photo.jpg';
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

    final post = MarketPostModel(
      id: postId,
      agentId: agent.id,
      type: MarketPostType.playerAvailable,
      status: MarketPostStatus.active,
      description: state.description.trim(),
      expiresAt: state.expiresAt,
      playerId: isAnonymous ? null : state.linkedPlayerId,
      playerPhotoUrl: photoUrl,
      playerPosition: state.playerPosition,
      playerNationality: state.playerNationality,
      playerLeagueCountry: state.playerLeagueCountry,
      playerAge: state.playerAge,
      playerMarketValue: state.playerMarketValue,
      transfermarktUrl: isAnonymous ? null : state.transfermarktUrl,
      isPlayerAnonymous: isAnonymous,
      externalLinks: isAnonymous ? const [] : state.externalLinks,
    );

    final result = await repo.createPost(post);
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
