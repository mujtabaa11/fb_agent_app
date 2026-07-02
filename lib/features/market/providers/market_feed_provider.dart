library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../auth/models/user_model.dart';
import '../../players/models/player_enums.dart';
import '../models/market_post_enums.dart';
import '../models/market_post_model.dart';
import '../repositories/market_repository.dart';
import '../repositories/market_repository_impl.dart';

part 'market_feed_provider.g.dart';

@Riverpod(keepAlive: true)
MarketRepository marketRepository(MarketRepositoryRef ref) {
  return MarketRepositoryImpl();
}

@riverpod
Stream<List<MarketPostModel>> marketFeed(MarketFeedRef ref) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.watchMarketFeed().map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

@riverpod
Future<UserModel?> marketPostAgent(MarketPostAgentRef ref, String agentId) async {
  final repo = ref.watch(userRepositoryProvider);
  final result = await repo.read(agentId);
  return switch (result) {
    Success(:final value) => value,
    Failure() => null,
  };
}

class MarketFeedFilterState {
  const MarketFeedFilterState({
    this.postType,
    this.position,
    this.nationality,
    this.maxAge,
    this.maxMarketValue,
  });

  final MarketPostType? postType;
  final PlayerPosition? position;
  final String? nationality;
  final int? maxAge;
  final double? maxMarketValue;

  int get activeFilterCount => [
        postType,
        position,
        nationality,
        maxAge,
        maxMarketValue,
      ].where((value) => value != null).length;

  MarketFeedFilterState copyWith({
    MarketPostType? Function()? postType,
    PlayerPosition? Function()? position,
    String? Function()? nationality,
    int? Function()? maxAge,
    double? Function()? maxMarketValue,
  }) {
    return MarketFeedFilterState(
      postType: postType != null ? postType() : this.postType,
      position: position != null ? position() : this.position,
      nationality: nationality != null ? nationality() : this.nationality,
      maxAge: maxAge != null ? maxAge() : this.maxAge,
      maxMarketValue:
          maxMarketValue != null ? maxMarketValue() : this.maxMarketValue,
    );
  }
}

@riverpod
class MarketFeedFilter extends _$MarketFeedFilter {
  @override
  MarketFeedFilterState build() => const MarketFeedFilterState();

  void setPostType(MarketPostType? value) {
    state = state.copyWith(postType: () => value);
  }

  void setPosition(PlayerPosition? value) {
    state = state.copyWith(position: () => value);
  }

  void setNationality(String? value) {
    state = state.copyWith(nationality: () => value);
  }

  void setMaxAge(int? value) {
    state = state.copyWith(maxAge: () => value);
  }

  void setMaxMarketValue(double? value) {
    state = state.copyWith(maxMarketValue: () => value);
  }

  void clearAllFilters() {
    state = const MarketFeedFilterState();
  }
}

@riverpod
List<MarketPostModel> filteredMarketFeed(FilteredMarketFeedRef ref) {
  final posts = ref.watch(marketFeedProvider).valueOrNull ?? [];
  final filter = ref.watch(marketFeedFilterProvider);

  return posts.where((post) {
    if (post.isExpired) return false;

    if (filter.postType != null && post.type != filter.postType) {
      return false;
    }

    if (filter.position != null) {
      final matchesPosition = post.type == MarketPostType.playerAvailable
          ? post.playerPosition == filter.position
          : post.neededPosition == filter.position;
      if (!matchesPosition) return false;
    }

    if (filter.nationality != null) {
      final matchesNationality = post.type == MarketPostType.playerAvailable
          ? post.playerNationality == filter.nationality
          : (post.neededNationalities?.isNotEmpty ?? false) &&
              post.neededNationalities!.first == filter.nationality;
      if (!matchesNationality) return false;
    }

    if (filter.maxAge != null && post.type == MarketPostType.playerAvailable) {
      if (post.playerAge == null || post.playerAge! > filter.maxAge!) {
        return false;
      }
    }

    if (filter.maxMarketValue != null &&
        post.type == MarketPostType.playerAvailable) {
      if (post.playerMarketValue == null ||
          post.playerMarketValue! > filter.maxMarketValue!) {
        return false;
      }
    }

    return true;
  }).toList();
}
