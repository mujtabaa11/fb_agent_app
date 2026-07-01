/// Riverpod providers for messaging state used outside the chat screens
/// themselves (e.g. the unread badge on the Messages tab).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messaging_providers.g.dart';

/// Count of unread messages across all conversations.
///
/// Placeholder — returns `0` until Phase 3 wires this to a Firestore
/// conversations query.
@riverpod
int unreadMessagesCount(UnreadMessagesCountRef ref) {
  return 0;
}
