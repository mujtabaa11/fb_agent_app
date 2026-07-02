library;

import '../../../core/errors/app_exceptions.dart';

enum MarketPostType {
  playerAvailable,
  needAPlayer;

  String toFirestoreValue() {
    return switch (this) {
      MarketPostType.playerAvailable => 'player_available',
      MarketPostType.needAPlayer => 'need_a_player',
    };
  }

  static MarketPostType fromFirestoreValue(String value) {
    return switch (value) {
      'player_available' => MarketPostType.playerAvailable,
      'need_a_player' => MarketPostType.needAPlayer,
      _ => throw DataException(
          originalMessage: 'Unknown MarketPostType value: $value',
        ),
    };
  }
}

enum MarketPostStatus {
  active,
  closed;

  String toFirestoreValue() {
    return switch (this) {
      MarketPostStatus.active => 'active',
      MarketPostStatus.closed => 'closed',
    };
  }

  static MarketPostStatus fromFirestoreValue(String value) {
    return switch (value) {
      'active' => MarketPostStatus.active,
      'closed' => MarketPostStatus.closed,
      _ => throw DataException(
          originalMessage: 'Unknown MarketPostStatus value: $value',
        ),
    };
  }
}
