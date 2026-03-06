/// Connectivity monitoring abstraction and concrete implementation.
///
/// [ConnectivityService] defines the contract. [ConnectivityPlusService] is the
/// production implementation backed by `connectivity_plus`.
///
/// **Limitation:** `connectivity_plus` reports *interface* status (Wi-Fi on,
/// cellular on, etc.), not internet *reachability*. A device may report
/// "online" while behind a captive portal or a misconfigured router. For true
/// reachability, a periodic ping-based check would be needed (out of scope —
/// see US-84 scope boundary).
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Connectivity status reported by [ConnectivityService].
enum ConnectivityStatus { online, offline }

/// Abstract contract for connectivity monitoring.
///
/// Consumers depend on this interface — never on the concrete implementation.
abstract class ConnectivityService {
  /// A debounced stream of connectivity changes.
  ///
  /// Emissions are delayed by ~1 second to prevent banner flickering during
  /// rapid toggles (e.g. airplane mode on/off quickly).
  Stream<ConnectivityStatus> get statusStream;

  /// The current connectivity status on demand.
  Future<ConnectivityStatus> get currentStatus;
}

/// Production implementation backed by `connectivity_plus`.
///
/// Debounces both online→offline and offline→online transitions by 1 second
/// so the UI does not flicker during rapid network state changes.
class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<ConnectivityStatus> get statusStream {
    return _connectivity.onConnectivityChanged
        .map(_mapResults)
        .distinct()
        .asyncExpand(_debounce);
  }

  @override
  Future<ConnectivityStatus> get currentStatus async {
    final results = await _connectivity.checkConnectivity();
    return _mapResults(results);
  }

  /// Maps a list of [ConnectivityResult] to a single [ConnectivityStatus].
  ///
  /// The device is considered offline only when the sole result is `none`.
  static ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  /// Debounces each emission by 1 second. If a new value arrives within the
  /// window, the previous pending emission is cancelled.
  static Stream<ConnectivityStatus> _debounce(ConnectivityStatus status) {
    return Stream<ConnectivityStatus>.value(status)
        .asyncExpand((s) => Future.delayed(
              const Duration(seconds: 1),
              () => s,
            ).asStream());
  }
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(ConnectivityServiceRef ref) =>
    ConnectivityPlusService();

/// Provides a debounced stream of [ConnectivityStatus] changes.
///
/// Widgets can `ref.watch(connectivityStatusProvider)` to reactively show/hide
/// an offline banner.
@riverpod
Stream<ConnectivityStatus> connectivityStatus(
  ConnectivityStatusRef ref,
) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
}
