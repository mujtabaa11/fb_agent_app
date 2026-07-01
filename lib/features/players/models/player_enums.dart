library;

import '../../../core/errors/app_exceptions.dart';

enum PlayerStatus {
  activeClient,
  prospect,
  formerClient;

  String toFirestoreValue() {
    return switch (this) {
      PlayerStatus.activeClient => 'active_client',
      PlayerStatus.prospect => 'prospect',
      PlayerStatus.formerClient => 'former_client',
    };
  }

  static PlayerStatus fromFirestoreValue(String value) {
    return switch (value) {
      'active_client' => PlayerStatus.activeClient,
      'prospect' => PlayerStatus.prospect,
      'former_client' => PlayerStatus.formerClient,
      _ => throw DataException(
          originalMessage: 'Unknown PlayerStatus value: $value',
        ),
    };
  }
}

enum PlayerPosition {
  gk,
  cb,
  lb,
  rb,
  cdm,
  cm,
  cam,
  lw,
  rw,
  st;

  String toFirestoreValue() {
    return switch (this) {
      PlayerPosition.gk => 'GK',
      PlayerPosition.cb => 'CB',
      PlayerPosition.lb => 'LB',
      PlayerPosition.rb => 'RB',
      PlayerPosition.cdm => 'CDM',
      PlayerPosition.cm => 'CM',
      PlayerPosition.cam => 'CAM',
      PlayerPosition.lw => 'LW',
      PlayerPosition.rw => 'RW',
      PlayerPosition.st => 'ST',
    };
  }

  static PlayerPosition fromFirestoreValue(String value) {
    return switch (value) {
      'GK' => PlayerPosition.gk,
      'CB' => PlayerPosition.cb,
      'LB' => PlayerPosition.lb,
      'RB' => PlayerPosition.rb,
      'CDM' => PlayerPosition.cdm,
      'CM' => PlayerPosition.cm,
      'CAM' => PlayerPosition.cam,
      'LW' => PlayerPosition.lw,
      'RW' => PlayerPosition.rw,
      'ST' => PlayerPosition.st,
      _ => throw DataException(
          originalMessage: 'Unknown PlayerPosition value: $value',
        ),
    };
  }
}

enum PreferredFoot {
  left,
  right,
  both;

  String toFirestoreValue() {
    return switch (this) {
      PreferredFoot.left => 'left',
      PreferredFoot.right => 'right',
      PreferredFoot.both => 'both',
    };
  }

  static PreferredFoot fromFirestoreValue(String value) {
    return switch (value) {
      'left' => PreferredFoot.left,
      'right' => PreferredFoot.right,
      'both' => PreferredFoot.both,
      _ => throw DataException(
          originalMessage: 'Unknown PreferredFoot value: $value',
        ),
    };
  }
}
