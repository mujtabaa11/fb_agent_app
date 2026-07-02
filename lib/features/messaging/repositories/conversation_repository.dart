library;

import '../../../core/data/result.dart';

abstract class ConversationRepository {
  /// Finds an existing conversation between [currentAgentId] and
  /// [otherAgentId], or creates a new one if none exists. Returns the
  /// conversation id.
  Future<Result<String>> findOrCreateConversation(
    String currentAgentId,
    String otherAgentId,
  );

  /// Writes the opening message to `conversations/{conversationId}/messages`
  /// and updates the parent conversation's last-message metadata and the
  /// other agent's unread count. [postId] is attached when the message was
  /// initiated from a Market post.
  Future<Result<void>> sendOpeningMessage(
    String conversationId,
    String senderId,
    String otherAgentId,
    String text,
    String? postId,
  );
}
