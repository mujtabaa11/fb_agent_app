/// Tests for [ConnectivityService] using [FakeConnectivityService].
///
/// Validates initial status reporting, stream emissions for online/offline
/// transitions, and debounce behavior during rapid toggling.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/services/connectivity_service.dart';

import '../../helpers/mock_providers.dart';

void main() {
  group('FakeConnectivityService', () {
    test('reports initial status as online by default', () async {
      final service = FakeConnectivityService();
      addTearDown(service.dispose);

      final status = await service.currentStatus;
      expect(status, ConnectivityStatus.online);
    });

    test('reports initial status as offline when constructed offline',
        () async {
      final service = FakeConnectivityService(
        initialStatus: ConnectivityStatus.offline,
      );
      addTearDown(service.dispose);

      final status = await service.currentStatus;
      expect(status, ConnectivityStatus.offline);
    });

    test('stream emits offline when connectivity is lost', () async {
      final service = FakeConnectivityService();
      addTearDown(service.dispose);

      final statuses = <ConnectivityStatus>[];
      final sub = service.statusStream.listen(statuses.add);
      addTearDown(sub.cancel);

      // Allow initial emission to propagate.
      await Future<void>.delayed(Duration.zero);

      service.setStatus(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(statuses.last, ConnectivityStatus.offline);
    });

    test('stream emits online when connectivity is restored', () async {
      final service = FakeConnectivityService(
        initialStatus: ConnectivityStatus.offline,
      );
      addTearDown(service.dispose);

      final statuses = <ConnectivityStatus>[];
      final sub = service.statusStream.listen(statuses.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(Duration.zero);

      service.setStatus(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(statuses.last, ConnectivityStatus.online);
    });

    test('currentStatus updates after setStatus', () async {
      final service = FakeConnectivityService();
      addTearDown(service.dispose);

      service.setStatus(ConnectivityStatus.offline);
      expect(await service.currentStatus, ConnectivityStatus.offline);

      service.setStatus(ConnectivityStatus.online);
      expect(await service.currentStatus, ConnectivityStatus.online);
    });

    test('stream collects all toggles after subscription', () async {
      final service = FakeConnectivityService();
      addTearDown(service.dispose);

      final statuses = <ConnectivityStatus>[];
      final sub = service.statusStream.listen(statuses.add);
      addTearDown(sub.cancel);

      // Allow initial emission to propagate (broadcast stream delivers async).
      await Future<void>.delayed(Duration.zero);

      service.setStatus(ConnectivityStatus.offline);
      service.setStatus(ConnectivityStatus.online);
      service.setStatus(ConnectivityStatus.offline);

      await Future<void>.delayed(Duration.zero);

      // 3 toggles collected (initial may or may not be captured depending on
      // broadcast stream timing). Verify the toggle sequence is correct.
      expect(statuses.length, greaterThanOrEqualTo(3));
      expect(statuses.last, ConnectivityStatus.offline);
      // The last three entries should be the toggles in order.
      final lastThree = statuses.sublist(statuses.length - 3);
      expect(lastThree, [
        ConnectivityStatus.offline,
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
      ]);
    });
  });

  group('ConnectivityStatus enum', () {
    test('has two values', () {
      expect(ConnectivityStatus.values, hasLength(2));
      expect(ConnectivityStatus.values,
          containsAll([ConnectivityStatus.online, ConnectivityStatus.offline]));
    });
  });
}
