library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/repository_providers.dart';
import '../../../core/data/result.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../auth/models/user_model.dart';
import '../models/market_post_model.dart';
import 'market_feed_provider.dart';

part 'agent_profile_provider.g.dart';

/// Streams the public profile of [agentId]. Emits `null` if the agent
/// document does not exist.
@riverpod
Stream<UserModel?> agentProfile(AgentProfileRef ref, String agentId) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchStream(agentId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(exception: DocumentNotFoundException()) => null,
      Failure(:final exception) => throw exception,
    };
  });
}

/// Streams [agentId]'s active Market posts, excluding expired ones.
@riverpod
Stream<List<MarketPostModel>> agentActivePosts(
  AgentActivePostsRef ref,
  String agentId,
) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.watchAgentActivePosts(agentId).map((result) {
    final posts = switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
    return posts.where((post) => !post.isExpired).toList();
  });
}
