library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/conversation_repository_impl.dart';

part 'conversation_providers.g.dart';

@Riverpod(keepAlive: true)
ConversationRepository conversationRepository(ConversationRepositoryRef ref) {
  return ConversationRepositoryImpl();
}

class MessageAgentState {
  const MessageAgentState({
    this.isLoading = false,
    this.errorMessage,
    this.conversationId,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? conversationId;

  MessageAgentState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    String? Function()? conversationId,
  }) {
    return MessageAgentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      conversationId:
          conversationId != null ? conversationId() : this.conversationId,
    );
  }
}

@riverpod
class MessageAgentNotifier extends _$MessageAgentNotifier {
  @override
  MessageAgentState build(String postId) => const MessageAgentState();

  Future<void> initiateConversation(
    String currentAgentId,
    String otherAgentId,
    String openingMessageText,
    String? postId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    final repo = ref.read(conversationRepositoryProvider);
    final conversationResult =
        await repo.findOrCreateConversation(currentAgentId, otherAgentId);

    switch (conversationResult) {
      case Failure(:final exception):
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => exception.message,
        );
        return;
      case Success(:final value):
        final messageResult = await repo.sendOpeningMessage(
          value,
          currentAgentId,
          otherAgentId,
          openingMessageText,
          postId,
        );

        switch (messageResult) {
          case Success():
            state = state.copyWith(
              isLoading: false,
              conversationId: () => value,
            );
          case Failure(:final exception):
            state = state.copyWith(
              isLoading: false,
              errorMessage: () => exception.message,
            );
        }
    }
  }
}
