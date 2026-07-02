library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../../auth/providers/agent_providers.dart';
import '../models/market_post_model.dart';
import 'market_feed_provider.dart';

part 'my_posts_provider.g.dart';

@riverpod
Stream<List<MarketPostModel>> myPosts(MyPostsRef ref) {
  final agent = ref.watch(currentAgentProvider);
  if (agent == null) return Stream.value(const []);

  final repo = ref.watch(marketRepositoryProvider);
  return repo.watchMyPosts(agent.id).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}

class MyPostsActionsState {
  const MyPostsActionsState({
    this.isClosing = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  final bool isClosing;
  final bool isDeleting;
  final String? errorMessage;

  MyPostsActionsState copyWith({
    bool? isClosing,
    bool? isDeleting,
    String? Function()? errorMessage,
  }) {
    return MyPostsActionsState(
      isClosing: isClosing ?? this.isClosing,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

@riverpod
class MyPostsActionsNotifier extends _$MyPostsActionsNotifier {
  @override
  MyPostsActionsState build() => const MyPostsActionsState();

  Future<Result<void>> closePost(String postId) async {
    state = state.copyWith(isClosing: true, errorMessage: () => null);

    final repo = ref.read(marketRepositoryProvider);
    final result = await repo.closePost(postId);

    switch (result) {
      case Success():
        state = state.copyWith(isClosing: false);
      case Failure(:final exception):
        state = state.copyWith(
          isClosing: false,
          errorMessage: () => exception.message,
        );
    }

    return result;
  }

  Future<Result<void>> deletePost(String postId) async {
    state = state.copyWith(isDeleting: true, errorMessage: () => null);

    final repo = ref.read(marketRepositoryProvider);
    final result = await repo.deletePost(postId);

    switch (result) {
      case Success():
        state = state.copyWith(isDeleting: false);
      case Failure(:final exception):
        state = state.copyWith(
          isDeleting: false,
          errorMessage: () => exception.message,
        );
    }

    return result;
  }
}
