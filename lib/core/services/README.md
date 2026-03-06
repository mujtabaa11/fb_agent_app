# Core Services

Shared application-level services registered via Riverpod DI.

## Connectivity Monitoring

`ConnectivityService` provides a debounced stream of online/offline status.

### Architecture

- **Abstract contract:** `ConnectivityService` — consumers depend on this.
- **Concrete implementation:** `ConnectivityPlusService` — backed by `connectivity_plus`.
- **DI registration:** `connectivityServiceProvider` (keepAlive singleton).
- **Stream provider:** `connectivityStatusProvider` — widgets `ref.watch()` this.

### Debounce Strategy

Both online-to-offline and offline-to-online transitions are debounced by
1 second. This prevents the offline banner from flickering during rapid
airplane mode toggling. The debounce lives in the service, not the widget.

### Known Limitation

`connectivity_plus` reports **interface status** (Wi-Fi radio on, cellular
radio on, etc.), not internet **reachability**. A device may report "online"
while behind a captive portal or connected to a router with no upstream.

For true reachability, a periodic ping-based health check would be needed.
This is intentionally out of scope for US-84 — the banner provides a
best-effort signal based on interface state, which covers the vast majority
of real-world offline scenarios (airplane mode, no SIM, Wi-Fi off).

### OfflineBanner Widget

`OfflineBanner` (`core/widgets/offline_banner.dart`) is a `ConsumerWidget` that
watches `connectivityStatusProvider` and renders a `MaterialBanner` in
`colorScheme.errorContainer` when offline. The banner animates in/out with
`AnimatedSize` and includes a `Semantics` label for screen readers.

The banner is integrated at the `ShellScreen` level — it appears above all tab
content without duplicating per-screen.

### Offline Writes

When Firestore writes succeed while offline, the SDK queues them
automatically. The app shows a snackbar ("Changes saved offline — will
sync when connected.") to inform the user. No custom offline write queue
is used — Firestore's built-in cache handles replay on reconnection.

### Extension Points

- **True reachability check:** Replace `ConnectivityPlusService` with a
  subclass that periodically pings a known endpoint (e.g. your API's
  `/health` route) and emits `offline` when the ping fails.
- **Custom debounce duration:** Pass a different `Duration` to the
  debounce logic in `ConnectivityPlusService`.
- **Per-feature offline behavior:** Watch `connectivityStatusProvider` in
  any ViewModel to gate network calls or show feature-specific offline UI.
