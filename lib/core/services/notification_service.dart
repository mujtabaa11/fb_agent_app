/// Push notification abstraction for FCM permission handling, token
/// management, and foreground/background message handling.
///
/// Ships with a [NoOpNotificationService] stub for testing and a
/// [FirebaseNotificationService] for production use.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Top-level background message handler.
///
/// This **must** be a top-level function — not a class method or closure —
/// because the Flutter engine needs to be able to invoke it in its own
/// isolate when the app is backgrounded or terminated. A class method
/// cannot be looked up by the engine across isolate boundaries.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised in main.dart. If you need to access
  // Firebase services here, call Firebase.initializeApp() first (it is
  // safe to call multiple times).
  if (kDebugMode) {
    debugPrint('[Notifications] Background message received: '
        '${message.messageId}');
    debugPrint('[Notifications] Data: ${message.data}');
  }
}

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

/// Contract for push notification handling.
abstract class NotificationService {
  /// Request notification permission from the user.
  ///
  /// On iOS this shows the system permission dialog on first call.
  /// On Android 13+ this requests the POST_NOTIFICATIONS permission.
  Future<void> requestPermission();

  /// Retrieve the current FCM registration token.
  ///
  /// The token is logged in debug mode. In production, send this token
  /// to your backend so it can target this device.
  Future<String?> getToken();

  /// Set up all FCM handlers and request permission + token.
  ///
  /// Call once during app bootstrap, after [Firebase.initializeApp].
  Future<void> initialise();
}

// ---------------------------------------------------------------------------
// No-op stub (for testing)
// ---------------------------------------------------------------------------

/// A no-op implementation that only prints in debug mode.
class NoOpNotificationService implements NotificationService {
  @override
  Future<void> requestPermission() async {
    assert(() {
      debugPrint('[Notifications] requestPermission (no-op)');
      return true;
    }());
  }

  @override
  Future<String?> getToken() async {
    assert(() {
      debugPrint('[Notifications] getToken (no-op)');
      return true;
    }());
    return null;
  }

  @override
  Future<void> initialise() async {
    assert(() {
      debugPrint('[Notifications] initialise (no-op)');
      return true;
    }());
  }
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

/// Firebase Cloud Messaging implementation.
///
/// Handles:
/// - Permission requests (iOS system dialog / Android 13+ runtime permission)
/// - FCM token retrieval and refresh
/// - Foreground message handling
/// - Background message handling (via top-level [_firebaseMessagingBackgroundHandler])
/// - Notification tap handling (initial message + onMessageOpenedApp)
class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService() {
    _messaging = FirebaseMessaging.instance;
  }

  late final FirebaseMessaging _messaging;

  @override
  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission();

    if (kDebugMode) {
      debugPrint('[Notifications] Permission status: '
          '${settings.authorizationStatus}');
    }
  }

  @override
  Future<String?> getToken() async {
    // TODO(US-25): On iOS, getToken() will return null until an APNs token
    // is available. This requires:
    //   1. An Apple Developer account with Push Notifications capability
    //   2. An APNs key uploaded to Firebase Console → Project Settings →
    //      Cloud Messaging → iOS app → APNs Authentication Key
    // Once configured, getToken() will return a valid FCM token on iOS.
    final token = await _messaging.getToken();

    if (kDebugMode) {
      debugPrint('[Notifications] FCM token: $token');
    }

    return token;
  }

  @override
  Future<void> initialise() async {
    // Register the top-level background handler. This must be called
    // before any other FCM interaction and must reference a top-level
    // function — see the doc comment on [_firebaseMessagingBackgroundHandler].
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // Request permission (shows iOS system dialog on first call).
    await requestPermission();

    // Retrieve the FCM token. If this fails (e.g. missing APNs key on iOS),
    // log the error and continue — push notifications are degraded but the
    // app remains functional.
    try {
      await getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Notifications] Failed to retrieve FCM token: $e');
      }
    }

    // Listen for token refresh events. When the FCM token changes (e.g.
    // app data cleared, app restored on new device, or server-side
    // invalidation), the new token must be sent to your backend.
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint('[Notifications] Token refreshed: $newToken');
      }
      // TODO(US-25): Send the refreshed token to your backend server so
      // it can update the stored token for this device.
    });

    // Handle foreground messages. When the app is in the foreground,
    // notifications are not displayed in the system tray by default —
    // they are delivered silently to this handler.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[Notifications] Foreground message received: '
            '${message.messageId}');
        debugPrint('[Notifications] Title: '
            '${message.notification?.title}');
        debugPrint('[Notifications] Body: '
            '${message.notification?.body}');
        debugPrint('[Notifications] Data: ${message.data}');
      }

      // TODO(US-25): To display foreground notifications in the system
      // tray, integrate a local notification package (e.g.
      // flutter_local_notifications) and show the notification here.
      // This is project-specific and intentionally left for downstream
      // projects to implement.
    });

    // Handle notification taps when the app is in the background (but
    // not terminated). This is where project-specific routing logic
    // should be implemented — e.g. navigating to a specific screen
    // based on the notification payload.
    //
    // Downstream projects: implement your onMessageOpenedApp handler
    // here. Use message.data to determine which screen to navigate to
    // and call your GoRouter instance accordingly. Example:
    //
    //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //     final route = message.data['route'];
    //     if (route != null) router.go(route);
    //   });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[Notifications] Notification tapped (background): '
            '${message.messageId}');
        debugPrint('[Notifications] Data: ${message.data}');
      }
    });

    // Handle the case where a notification tap launched the app from a
    // terminated state. getInitialMessage() returns the RemoteMessage
    // that caused the app to open, or null if the app was not opened
    // from a notification.
    //
    // Downstream projects: use this payload for initial deep-link
    // routing — same logic as onMessageOpenedApp above.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('[Notifications] App opened from terminated via '
            'notification: ${initialMessage.messageId}');
        debugPrint('[Notifications] Data: ${initialMessage.data}');
      }
    }

    // Set foreground notification presentation options for iOS.
    // This controls whether notifications are shown in the system tray
    // when the app is in the foreground on iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) =>
    FirebaseNotificationService();
