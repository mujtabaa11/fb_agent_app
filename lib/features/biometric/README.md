# Biometric Lock

App-level biometric lock that requires Face ID / Touch ID / fingerprint authentication when the app resumes from the background. The lock is a UI overlay above the router — it is not a router guard condition. Users enable it from Profile → Settings, and the preference is stored per-user in `FlutterSecureStorage`.

## How It Works

1. **User enables biometric** — Profile → Settings toggle calls `BiometricPreferenceNotifier.enable()`, which verifies biometric availability and authenticates the user before persisting the preference.
2. **App goes to background** — `BiometricGuard` (a `WidgetsBindingObserver`) records a `_lastBackgroundedTimestamp`.
3. **App resumes** — the guard checks four conditions: (a) biometric preference is enabled, (b) user is authenticated, (c) device biometrics are available, (d) grace period has elapsed (or cold start). If all four are true, a blur overlay + lock screen is shown.
4. **User authenticates** — the native biometric prompt appears automatically. On failure, "Try Again" and "Use Passcode" buttons are shown. On success, the overlay is dismissed.
5. **Cold start** — `_lastBackgroundedTimestamp` is null, so biometric is always required on first open if the preference is enabled.

### Android FLAG_SECURE

On Android, `FLAG_SECURE` is set via a method channel while the lock screen is showing. This prevents the app content from appearing in the app switcher preview. The flag is cleared when the lock is dismissed. If the method channel is not configured (e.g. fresh project without the native handler), this is silently skipped.

### Session Expiry While Locked

If the Firebase session expires while the lock screen is showing, the router redirect guard will automatically route to the login screen after the lock is dismissed — no special handling is needed.

## Platform Setup

The `local_auth` package requires platform-specific configuration:

### iOS

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock the app with Face ID</string>
```

This string is shown in the iOS permission dialog. Customize it for your project.

### Android

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

For the `FLAG_SECURE` method channel (app switcher preview prevention), add a handler in your `MainActivity`. This is optional — the app works without it.

## Grace Period

When the app returns from the background within `AppConstants.biometricGracePeriodSeconds` (default: **30 seconds**), biometric is not required. This avoids repeated prompts during quick task switches (e.g. copying a 2FA code from another app).

To change the grace period, edit the constant in `lib/core/constants/app_constants.dart`:

```dart
static const int biometricGracePeriodSeconds = 30;
```

Set to `0` to require biometric on every resume. There is no upper limit, but values above 300 (5 minutes) effectively disable the lock for most usage patterns.

## Secure Storage

The biometric preference is stored in `FlutterSecureStorage` under a user-scoped key:

```
biometric_enabled_{userId}
```

This means:
- Each user on a shared device has their own biometric setting
- The preference **survives sign-out** — it is device-scoped, not session-scoped
- On account deletion, `clearForUser(userId)` removes the key

### Device Enrollment Check

On cold start, `BiometricPreferenceNotifier.checkDeviceEnrollment()` verifies that biometrics are still available on the device. If the user removed all fingerprints/faces from device settings, the preference is auto-cleared and a non-fatal error is logged to Crashlytics.

## Disabling Biometric Entirely

To remove biometric lock from your project:

1. Remove `BiometricGuard` from `main.dart` (it wraps `MaterialApp.router`)
2. Remove the biometric toggle from the settings screen
3. Optionally delete `lib/features/biometric/` entirely
4. Remove `local_auth` from `pubspec.yaml`
5. Remove the `NSFaceIDUsageDescription` entry from `ios/Runner/Info.plist`
6. Remove the `USE_BIOMETRIC` permission from `android/app/src/main/AndroidManifest.xml`

## Extension Point

### Passcode Fallback

The lock screen includes a "Use Passcode" button that falls back to the device's passcode/PIN/pattern via `authenticateWithPasscode()`. This uses `local_auth` with `biometricOnly: false`, which triggers the platform's device credential prompt.

### Custom Passcode

To implement an in-app passcode (independent of the device lock):

1. Create a `PasscodeService` with `setPasscode(String)`, `verifyPasscode(String)`, and `hasPasscode()` methods
2. Store the passcode hash in `FlutterSecureStorage` under a user-scoped key
3. Replace the "Use Passcode" button's handler in `BiometricLockScreen` to navigate to your passcode entry screen
4. The `BiometricGuard` does not need changes — it delegates authentication to `BiometricLockScreen`, which handles the UI

## Architecture

```
lib/features/biometric/
├── providers/
│   ├── biometric_providers.dart              # BiometricService DI provider
│   ├── biometric_preference_notifier.dart    # Async notifier managing the enable/disable preference
│   ├── biometric_providers.g.dart            # Generated
│   └── biometric_preference_notifier.g.dart  # Generated
├── services/
│   └── biometric_service.dart                # Abstract BiometricService + LocalAuthBiometricService
├── screens/
│   └── biometric_lock_screen.dart            # Full-screen lock overlay with auto-prompt
└── widgets/
    └── biometric_guard.dart                  # WidgetsBindingObserver that manages lock state
```

### Key Classes

| Class | Role |
|---|---|
| `BiometricService` | Abstract interface — `isAvailable()`, `authenticate()`, `authenticateWithPasscode()` |
| `LocalAuthBiometricService` | Production implementation wrapping `local_auth`. All `local_auth` imports are confined here |
| `BiometricPreferenceNotifier` | `@Riverpod(keepAlive: true)` async notifier. Reads/writes user-scoped preference. `enable()` requires biometric verification before persisting |
| `BiometricGuard` | `ConsumerStatefulWidget` with `WidgetsBindingObserver`. Manages lock overlay lifecycle |
| `BiometricLockScreen` | Full-screen lock UI. Auto-triggers biometric on mount, shows fallback buttons on failure |
