# Launchpad

A production-quality Flutter mobile boilerplate. Clone, configure, and start building — auth, navigation, theming, localization, Firebase services, data layer, and CI/CD are already wired up.

Every new Flutter project wastes its first sprint doing the same foundational work. Launchpad eliminates that entirely. This is not a demo app or a tutorial — it is a reusable, opinionated starting point that embeds best practices from the first line of code.

- Zero hardcoded strings (all via `AppLocalizations`), zero hardcoded visual values (all via theme tokens)
- Accessibility built in from day one — `Semantics` labels on all interactive elements, 44x44pt minimum touch targets
- Clean architecture with feature-first structure, typed exceptions surfaced only at the UI boundary

## Included Features

**Authentication** — Email & password sign-up/login, Google SSO (Android + iOS), Apple SSO (iOS), phone number sign-in (SMS OTP, feature-flagged via Remote Config), session persistence with automatic token refresh, password reset flow, email verification gate (email/password users must verify before accessing the app; SSO and phone auth users bypass this), account linking (SSO credential conflicts), account deletion with re-authentication gate

**Onboarding** — Swipeable PageView carousel with skip/next/done navigation, shown once on first launch. Completion flag persisted to SharedPreferences. Router guard enforces a four-state redirect chain: onboarding → login → email verification → home. Placeholder content is customizable — see `features/onboarding/README.md`.

**Navigation** — Bottom tab bar (Home, Explore, Profile) with GoRouter, side drawer with user area / nav links / theme toggle / locale switcher / logout, route guard with four-state redirect chain (onboarding → login → email verification → home), biometric lock overlay above the router, deep link support with post-login redirect for protected routes

**Theming** — Centralized design token system (colors, typography, spacing, border radius), light and dark mode with WCAG AA contrast ratios verified, theme toggle with persistence across sessions

**Localization** — Flutter `gen-l10n` with ARB files (add a language by adding one file), RTL support with directional properties throughout, runtime locale switcher in the side drawer

**Accessibility** — Semantic labels on all interactive elements, reusable `AccessibleTouchTarget` wrapper (44x44pt minimum), `AccessibilityChecklist.md` in repo for adding new screens

**Core Infrastructure** — Base HTTP client (Dio) with automatic auth header injection and token refresh on 401, typed exception hierarchy (`NetworkException`, `ServerException`, `AuthException`, `DataException`, `PermissionException`, etc.), local storage abstraction (`FlutterSecureStorage` for secrets, `SharedPreferences` for preferences), global error boundary with user-friendly fallback screen, reusable empty state component

**Firebase Services** — Analytics (automatic screen tracking, `AnalyticsService` wrapper, GDPR opt-out), Crashlytics (crash + non-fatal error reporting), Cloud Messaging (permission handling, token management, foreground/background handlers), Remote Config (feature flag infrastructure with defaults pattern), Performance Monitoring (automatic app startup + HTTP request traces), App Check (debug provider configured, production migration documented)

**Data Layer** — `BaseRepository<T>` abstract interface with `Result<T>` sealed type (`Success`/`Failure`), `FirestoreRepository<T>` with full CRUD + real-time `watchStream` + paginated `queryList` and typed error mapping, `BaseStorageService` abstract interface for file operations, `FirebaseStorageService` with upload progress tracking / download URL retrieval / delete with cancellation, `QueryOptions`/`QueryFilter`/`PaginatedResult` for backend-agnostic paginated queries with opaque cursor pattern, reference example: `UserProfileModel` + avatar upload flow + paginated Explore list demonstrating all patterns end-to-end

**Biometric Lock** — App-level biometric lock (Face ID / Touch ID / fingerprint) as a UI overlay above the router, user-scoped preference stored in `FlutterSecureStorage`, 30-second grace period, cold-start lock, Android `FLAG_SECURE` for app switcher privacy, device enrollment auto-clear, passcode fallback. See `features/biometric/README.md`.

**Phone Authentication** — SMS-based phone sign-in gated by Firebase Remote Config (`phone_auth_enabled`), country code picker with locale-aware default, 6-digit OTP input with auto-advance and auto-submit, 60-second resend countdown, Android auto-verification support, router guard bypass for email verification. See `features/phone_auth/README.md`.

**Connectivity Monitoring** — `ConnectivityService` abstraction backed by `connectivity_plus`, debounced online/offline stream, `OfflineBanner` widget integrated at the shell level with animated expand/collapse, offline write detection with user-facing snackbar

**CI/CD** — Pull request checks (`flutter analyze` + `flutter test`), automated Android APK build + Firebase App Distribution on merge to `main`, automated iOS IPA build + Firebase App Distribution on merge to `main`, auto-generated release notes (commit SHA, branch, message) on every distributed build

## Tech Stack

- **State management:** Riverpod (code-gen with `@riverpod`)
- **Navigation:** GoRouter (declarative, type-safe)
- **HTTP:** Dio
- **Auth:** Firebase Auth + Google Sign-In + Sign in with Apple + `local_auth` (biometric)
- **Local storage:** `flutter_secure_storage` (secrets) + `shared_preferences` (prefs)
- **Environment:** `flutter_dotenv` (`.env.development` / `.env.production`)
- **Localisation:** Flutter's built-in `gen-l10n` with ARB files

## Architecture

### Clean Architecture, Feature-First

- `lib/core/` — shared infrastructure: theme tokens, error types, services, data layer, network client, utilities, constants
- `lib/features/<feature>/` — self-contained feature modules with `models/`, `providers/`, `screens/`, `widgets/`
- `lib/routing/` — GoRouter configuration and route guards

### Repository & Service Pattern

All data access goes through repository or service classes — **zero Firebase or HTTP calls in widgets or ViewModels**.

- **Firestore:** feature code depends on `BaseRepository<T>` via DI. `FirestoreRepository<T>` is the concrete implementation resolved by Riverpod — feature code never imports it directly.
- **Cloud Storage:** feature code depends on `BaseStorageService` via DI. `FirebaseStorageService` is the concrete implementation — same boundary.
- **Import boundary rule:** `FirestoreRepository` and `FirebaseStorageService` must never be imported outside `core/` and the DI registration file. This ensures any project can swap Firebase for another backend by changing only the DI registration and the implementation class — zero feature code changes.

### Error Handling Contract

- All repository and service methods return `Result<T>` — a sealed class with `Success<T>` and `Failure` states.
- `Failure` carries a typed `AppException` subclass (`NetworkException`, `DocumentNotFoundException`, `PermissionException`, `DataException`, `FileNotFoundException`, `CancelledException`, etc.).
- The UI layer never receives a raw `FirebaseException` or Dart exception. All mapping happens at the repository/service layer.

### State Management

Riverpod (code-gen with `@riverpod`) is used consistently for auth state, theme state, locale state, and all feature state. No mixing of approaches.

## Setup

1. **Clone the repo**

   ```bash
   git clone <repo-url> && cd template_app
   ```

2. **Add Firebase config files**

   - Android: place `google-services.json` in `android/app/`
   - iOS: place `GoogleService-Info.plist` in `ios/Runner/`

   These files are gitignored and must be obtained from your Firebase console.

3. **Create your environment file**

   ```bash
   cp .env.example .env.development
   ```

   Edit `.env.development` and fill in the required values (see below).

4. **Install dependencies**

   ```bash
   flutter pub get
   ```

5. **Run code generation** (if you've added `@riverpod` providers)

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**

   ```bash
   flutter run
   ```

## Environment Variables

| Variable   | Required | Description                                      | Example                         |
|------------|----------|--------------------------------------------------|---------------------------------|
| `BASE_URL` | Yes      | Root URL for the backend API (no trailing slash)  | `https://api.example.com/v1`    |

Create `.env.development` for debug builds and `.env.production` for release builds. Both are gitignored.

> **Never commit** `.env.*` files or Firebase config files (`google-services.json`, `GoogleService-Info.plist`).

## Firebase Setup

Firebase is required for authentication. Follow these steps to configure it for your project:

1. **Install the FlutterFire CLI** (if not already installed)

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Run `flutterfire configure`** from the project root

   ```bash
   flutterfire configure
   ```

   This will walk you through selecting your Firebase project and platforms, then generate `lib/firebase_options.dart` with your project-specific config values.

3. **Place the native config files**

   The CLI may handle this automatically, but verify the files are in the correct locations:

   - **Android:** `google-services.json` in `android/app/`
   - **iOS:** `GoogleService-Info.plist` in `ios/Runner/`

   You can download these manually from the [Firebase console](https://console.firebase.google.com/) if needed.

4. **Never commit Firebase config files**

   The following files are gitignored and must not be checked in:

   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

   Each developer must run `flutterfire configure` or obtain these files from the team's shared secrets.

> **Note:** Web Firebase configuration is out of scope for V1. Only Android and iOS are supported.

An example showing the expected structure of `firebase_options.dart` is available at `lib/core/constants/firebase_options.dart.example` for reference.

## Firebase App Check

App Check verifies that requests to your Firebase backends originate from the genuine app, not from a script or modified build. It is activated in `main.dart` immediately after `Firebase.initializeApp()` and before any other Firebase service is used.

The template ships with the **debug provider** only. This prints a debug token to the console at startup, which you register in the Firebase Console to allow requests from your development device. Production attestation (DeviceCheck / Play Integrity) is intentionally left for each downstream project to configure.

### Finding the debug token

When the app starts, look for the debug token in your console output:

**Android (logcat):**

```
D DebugAppCheckProvider: Enter this debug secret into the allow list in
D DebugAppCheckProvider: the Firebase Console for your project: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

**iOS (Xcode console):**

```
<FIRAppCheckDebugProvider> Firebase App Check debug token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

### Registering the debug token

1. Open the [Firebase Console](https://console.firebase.google.com/)
2. Go to **App Check** (in the left sidebar under Build)
3. Select **Apps** → choose your app (Android or iOS)
4. Click **Manage debug tokens**
5. Click **Add debug token** and paste the token from your console output
6. Click **Save**

Repeat for each device or simulator you develop on — each generates a unique token.

### Enforcement

App Check does **not** block requests until you explicitly enable enforcement per service. To enforce:

1. In the Firebase Console → **App Check** → select a Firebase service (e.g. Authentication, Firestore, Cloud Functions, Storage)
2. Click **Enforce**

> **Warning:** Enabling enforcement immediately blocks all requests from unverified clients. Ensure all team members have registered their debug tokens and any production builds use a production attestation provider before enforcing.

### Switching to production attestation

When preparing for release, create a `ProductionAppCheckService` that uses platform-appropriate providers:

1. Create `lib/core/services/production_app_check_service.dart`:

   ```dart
   class ProductionAppCheckService implements AppCheckService {
     @override
     Future<void> activate() async {
       await FirebaseAppCheck.instance.activate(
         providerAndroid: const AndroidPlayIntegrityProvider(),
         providerApple: const AppleDeviceCheckProvider(),
       );
     }
   }
   ```

2. Update the provider in `app_check_service.dart` to return `ProductionAppCheckService()`

3. Update the `DebugAppCheckService()` call in `main.dart` to use `ProductionAppCheckService()`

4. In the Firebase Console → **App Check** → register your production app's attestation (Play Integrity for Android, DeviceCheck for iOS)

> **Note:** You can keep `DebugAppCheckService` for debug builds by checking `kDebugMode` and switching providers accordingly.

## Firebase Analytics

Firebase Analytics auto-initializes with `Firebase.initializeApp()` — no separate init step is needed. Screen tracking is automatic via `FirebaseAnalyticsObserver` wired into GoRouter.

### Debug Mode Behaviour

In debug builds, analytics collection is **disabled by default** so development traffic does not pollute production dashboards. All analytics calls are logged to the console with a `[Analytics]` prefix for easy verification.

### DebugView (Real-Time Event Monitoring)

To see events in the Firebase Console's DebugView in real time, enable the debug flag on your device:

**Android:**

```bash
adb shell setprop debug.firebase.analytics.app com.template.template_app
```

To disable:

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

**iOS (Xcode):**

Add the launch argument `-FIRDebugEnabled` to your Xcode scheme:

1. **Product → Scheme → Edit Scheme → Run → Arguments**
2. Add `-FIRDebugEnabled` to **Arguments Passed on Launch**

To disable, replace with `-FIRDebugDisabled`.

### Logging Custom Events

Use `AnalyticsEvents` constants for event names:

```dart
final analytics = ref.read(analyticsServiceProvider);
analytics.logEvent(AnalyticsEvents.login, parameters: {'method': 'google'});
```

### GDPR Opt-Out

Disable analytics collection when the user opts out of tracking:

```dart
final analytics = ref.read(analyticsServiceProvider);
await analytics.setAnalyticsCollectionEnabled(false);
```

Re-enable by passing `true`. Persist the user's preference with `SharedPreferences` and apply it at startup.

### User Identity

Set the current user ID for cross-device analytics:

```dart
final analytics = ref.read(analyticsServiceProvider);
await analytics.setUserId('user_123');   // set after login
await analytics.setUserId(null);         // clear on logout
```

## Firebase Crashlytics

Firebase Crashlytics captures crash reports and non-fatal errors, providing symbolicated stack traces grouped by root cause in the Firebase Console.

### How Errors Are Captured

Errors are captured at three layers — no manual instrumentation is needed for unhandled errors:

1. **Flutter framework errors** (build/layout/paint) — `FlutterError.onError` in `main.dart` routes these to Crashlytics as **fatal** errors
2. **Unhandled async Dart errors** — `PlatformDispatcher.onError` in `main.dart` routes these to Crashlytics as **fatal** errors
3. **Error boundary catches** (widget build errors) — `AppErrorWidget` in `error_boundary.dart` routes these to Crashlytics as **non-fatal** errors (the app is still running)

### Debug Mode Behaviour

In debug builds, Crashlytics collection is **disabled by default** so development crashes do not pollute production dashboards. All Crashlytics calls are logged to the console with a `[Crashlytics]` prefix for easy verification.

### Recording Non-Fatal Errors in Feature Code

To report caught exceptions from feature code:

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);
crashlytics.recordError(exception, stackTrace);
```

### User Identification

Set a non-sensitive user identifier (e.g. Firebase UID) to associate crash reports with a specific user:

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);
await crashlytics.setUserIdentifier('uid_123');
```

> **Warning:** Only use non-sensitive identifiers. Never pass email addresses, names, or other PII.

### Custom Keys

Attach non-sensitive context to crash reports:

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);
await crashlytics.setCustomKey('screen', 'checkout');
await crashlytics.setCustomKey('item_count', 3);
```

### iOS dSYM Upload

For symbolicated crash reports on iOS, upload dSYM files after each release build:

**Local (Xcode):**

1. Build your release archive in Xcode
2. In the Xcode Organizer, right-click the archive → **Show in Finder**
3. Upload dSYMs using the Firebase CLI:

   ```bash
   firebase crashlytics:symbols:upload --app=YOUR_APP_ID path/to/dSYMs
   ```

**CI/CD:**

Add a post-build step to upload dSYMs automatically:

```bash
firebase crashlytics:symbols:upload --app=$FIREBASE_IOS_APP_ID build/ios/archive/Runner.xcarchive/dSYMs
```

### Force a Test Crash

To verify Crashlytics is working, trigger a test crash in a release build:

```dart
FirebaseCrashlytics.instance.crash();
```

> **Note:** Test crashes only appear in the Firebase Console in **release** builds. Debug builds have collection disabled.

## Push Notifications (FCM)

Firebase Cloud Messaging (FCM) is configured for both Android and iOS. The `NotificationService` in `lib/core/services/notification_service.dart` encapsulates all FCM logic — no FCM calls should be scattered in widgets.

### How It Works

On app launch, `NotificationService.initialise()` is called in `main.dart` after `Firebase.initializeApp()`. It:

1. Registers the top-level background message handler
2. Requests notification permission (iOS system dialog / Android 13+ runtime permission)
3. Retrieves and logs the FCM token (debug mode only)
4. Listens for token refresh events
5. Installs foreground and background message handlers
6. Checks for an initial message (app opened from terminated state via notification tap)
7. Configures iOS foreground notification presentation (alert, badge, sound)

### Permission Handling

- **iOS:** The system permission dialog is shown on the first call to `requestPermission()`. If the user denies, the app continues normally with no crash and no repeated permission request on subsequent launches.
- **Android 13+:** The `POST_NOTIFICATIONS` runtime permission is requested automatically by the `firebase_messaging` package.

### Debug Mode Behaviour

In debug builds, all FCM events are logged to the console with a `[Notifications]` prefix. The FCM token is printed at startup for easy testing with the Firebase Console's test notification feature.

### Foreground Messages

When the app is in the foreground, messages are delivered silently to the `onMessage` handler. On iOS, `setForegroundNotificationPresentationOptions` is configured to show alerts, badges, and sounds. To display a local notification banner on Android in the foreground, integrate a local notification package (e.g. `flutter_local_notifications`) — this is project-specific and intentionally left for downstream projects.

### Background and Terminated Messages

Background messages are handled by a top-level function (`_firebaseMessagingBackgroundHandler`) — this is a Flutter/FCM hard requirement because the engine invokes it in its own isolate. Notifications sent while the app is in the background or terminated appear in the system notification tray automatically.

### Notification Tap Handling

When the user taps a notification:

- **App in background:** `FirebaseMessaging.onMessageOpenedApp` fires with the notification payload
- **App terminated:** `FirebaseMessaging.instance.getInitialMessage()` returns the payload on launch

Both cases are handled in `NotificationService.initialise()` with debug logging. **Downstream projects should implement their own routing logic here** — e.g. navigating to a specific screen based on `message.data`. See the comments in `notification_service.dart` for examples.

### Token Management

The FCM token is retrieved at startup and logged in debug mode. Token refresh events are listened to via `onTokenRefresh`. When the token changes, send the new token to your backend server so it can update its records. See the `TODO(US-25)` comment in `notification_service.dart`.

### iOS Setup (Requires Apple Developer Account)

FCM on iOS requires APNs (Apple Push Notification service) configuration. The following steps are deferred until an Apple Developer account is available:

1. **Enable Push Notifications capability in Xcode**

   Open `ios/Runner.xcworkspace` → Runner target → Signing & Capabilities → click "+ Capability" → add "Push Notifications". This registers the capability with your Apple Developer account.

2. **Enable Background Modes capability in Xcode**

   Runner target → Signing & Capabilities → click "+ Capability" → add "Background Modes" → check "Remote notifications". The `UIBackgroundModes` key is already declared in `Info.plist`.

3. **Create an APNs authentication key**

   In the [Apple Developer portal](https://developer.apple.com/account/resources/authkeys/list) → Keys → click "+" → enable "Apple Push Notifications service (APNs)" → download the `.p8` key file. Note the **Key ID**.

4. **Upload the APNs key to Firebase Console**

   Go to **Firebase Console** → **Project Settings** → **Cloud Messaging** → select your iOS app → under "APNs Authentication Key", click "Upload" → provide the `.p8` file, Key ID, and Team ID.

5. **Entitlements file**

   `ios/Runner/Runner.entitlements` is already created with the `aps-environment` entitlement set to `development`. For production builds, Xcode will automatically switch this to `production` when archiving with a distribution profile.

> **Warning:** Without steps 1–4 completed, `getToken()` will return `null` on iOS and push notifications will not be delivered. Android works without any additional configuration.

### Testing Push Notifications

**Firebase Console (quickest method):**

1. Open [Firebase Console](https://console.firebase.google.com/) → your project → **Engage** → **Messaging**
2. Click **New campaign** → **Notifications**
3. Enter a title and body → click **Send test message**
4. Paste the FCM token from your debug console output → click **Test**

**Android Emulator:**

FCM works on Android emulators with Google Play Services. The token is logged at startup — use it with the Firebase Console test message feature above.

**iOS Simulator:**

FCM does not work on the iOS Simulator — push notifications require a physical iOS device with APNs configured.

### Sending from a Backend

To send notifications from your backend server, use the [Firebase Admin SDK](https://firebase.google.com/docs/cloud-messaging/send-message) or the FCM HTTP v1 API. Target devices using the FCM token retrieved by `getToken()`.

## Firebase Remote Config

Firebase Remote Config lets you change the behaviour and appearance of your app without publishing an update, by defining feature flags and remote parameters in the Firebase Console that the app fetches at launch.

### How It Works

On app launch, `RemoteConfigService.initialise()` is called in `main.dart` after `Firebase.initializeApp()`. It:

1. Configures the fetch interval (`Duration.zero` in debug, 1 hour in production)
2. Registers default values from `RemoteConfigDefaults`
3. Calls `fetchAndActivate()` to pull the latest config from Firebase

If the fetch fails (no internet, timeout, Firebase throttling), the app continues using cached or default values — it never crashes or blocks the launch.

### Debug Mode Behaviour

In debug builds, the fetch interval is set to `Duration.zero` so changes published in the Firebase Console are picked up immediately on the next app restart. All Remote Config operations are logged to the console with a `[RemoteConfig]` prefix.

In production, the fetch interval is set to **1 hour** to avoid Firebase throttling. Firebase will return cached values for any fetch within the minimum interval.

### Adding a New Feature Flag

1. **Define the default value** in `lib/core/constants/remote_config_defaults.dart`:

   ```dart
   abstract final class RemoteConfigDefaults {
     static const Map<String, dynamic> defaults = {
       'enable_new_onboarding': false,
       'max_retry_count': 3,
     };
   }
   ```

2. **Create the parameter in the Firebase Console**

   Go to **Firebase Console** → your project → **Engage** → **Remote Config** → **Add parameter**. Use the same key name (e.g. `enable_new_onboarding`) and set the desired value.

3. **Read the value via `RemoteConfigService`**

   ```dart
   final remoteConfig = ref.read(remoteConfigServiceProvider);
   final showOnboarding = remoteConfig.getBool('enable_new_onboarding');
   final maxRetries = remoteConfig.getInt('max_retry_count');
   ```

### Available Getters

| Method           | Return type | Description                       |
|------------------|-------------|-----------------------------------|
| `getString(key)` | `String`    | String value (empty if not found) |
| `getBool(key)`   | `bool`      | Boolean value (false if not found)|
| `getInt(key)`    | `int`       | Integer value (0 if not found)    |
| `getDouble(key)` | `double`    | Double value (0.0 if not found)   |

If a key does not exist in Remote Config, the registered default value from `RemoteConfigDefaults` is returned — never an exception.

### Testing Flags Locally

In debug builds the fetch interval is `Duration.zero`, so you can test flag changes instantly:

1. Set the parameter value in the **Firebase Console** → **Remote Config**
2. Click **Publish changes**
3. Restart the app (hot restart is sufficient) — the new value is fetched immediately

### Conditions and Rollouts

Remote Config supports **conditions** for targeted rollouts — e.g. show a feature to 10% of users, specific app versions, or specific countries. Configure conditions in the Firebase Console when adding or editing a parameter. No code changes are needed — the SDK handles condition evaluation automatically.

## Firebase Performance Monitoring

Firebase Performance Monitoring automatically captures app startup time and HTTP request metrics (duration, response code, payload size) in release builds. No custom traces are defined in the template — only automatic monitoring is configured.

### What Is Tracked Automatically

- **App start trace** — time from when the app process starts to when the first frame renders
- **HTTP request traces** — every network request made through the Dio HTTP client is captured via `DioFirebasePerformanceInterceptor`, including URL, HTTP method, response code, request/response payload size, and duration
- **Screen rendering traces** — slow and frozen frame metrics per screen (collected by the SDK automatically)

### Debug Mode Behaviour

In debug builds, performance data collection is **disabled** so development traffic does not pollute production dashboards. The SDK is initialised in `main.dart` with `setPerformanceCollectionEnabled(!kDebugMode)`.

### Adding a Custom Trace

When your project needs to measure a specific operation (e.g. image processing, database query, complex computation), create a custom trace:

```dart
import 'package:firebase_performance/firebase_performance.dart';

Future<void> processImages(List<String> paths) async {
  final trace = FirebasePerformance.instance.newTrace('image_processing');
  await trace.start();

  // ... your operation ...

  trace.putMetric('image_count', paths.length);
  trace.putAttribute('format', 'webp');
  await trace.stop();
}
```

Custom traces appear in the Firebase Console under **Performance** → **Custom traces** after a few hours of data collection.

### Verifying Traces in the Firebase Console

1. Open the [Firebase Console](https://console.firebase.google.com/) → your project → **Performance**
2. **App start trace** — visible under **Performance** → **Dashboard** → **App start** within a few hours of a release build launch
3. **Network request traces** — visible under **Performance** → **Network requests**. Filter by URL pattern to find specific API calls
4. **Custom traces** — visible under **Performance** → **Custom traces** (none are defined in the template)

> **Note:** Performance data takes up to **12 hours** to appear in the Firebase Console after the first release build run. Data is only collected in release builds — debug builds have collection disabled.

## Google SSO Setup

After cloning the boilerplate, complete these steps to enable Google Sign-In for your project:

1. **Enable Google Sign-In in Firebase Console**

   Go to **Authentication → Sign-in method** and enable the **Google** provider.

2. **Add SHA-1 fingerprint (Android)**

   In Firebase Console → **Project Settings → Your apps → Android app**, add your debug and release SHA-1 fingerprints:

   ```bash
   cd android && ./gradlew signingReport
   ```

3. **Download updated `google-services.json`**

   After adding the SHA-1 fingerprint, download the updated `google-services.json` from Firebase Console and place it in `android/app/`.

4. **iOS — no additional client ID steps**

   The `iosClientId` in `firebase_options.dart` is generated by `flutterfire configure` and is sufficient for iOS.

5. **iOS URL Scheme (required)**

   Open `ios/Runner.xcworkspace` in Xcode. Select the **Runner** target → **Info** tab → **URL Types**. Add a new URL type with the `REVERSED_CLIENT_ID` value from `GoogleService-Info.plist` as the **URL Scheme**. This value looks like: `com.googleusercontent.apps.YOUR_CLIENT_ID`.

   Without this step, Google Sign-In will fail on iOS with a URL scheme error.

> **Note:** The `google_sign_in` package is already included in `pubspec.yaml` — no additional dependencies are needed.

## Apple SSO Setup

After cloning the boilerplate, complete these steps to enable Sign in with Apple for your project:

1. **Enable Sign in with Apple for your App ID**

   Go to the [Apple Developer portal](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → select your App ID → **Capabilities** → enable **Sign in with Apple**.

2. **Create a Services ID**

   In the Apple Developer portal → **Identifiers** → click **+** → select **Services IDs** → register a new Services ID. This is used for web/Firebase verification. Configure the **Sign in with Apple** capability on the Services ID and add your Firebase callback URL as a return URL.

3. **Create a Key with Sign in with Apple enabled**

   In the Apple Developer portal → **Keys** → click **+** → enable **Sign in with Apple** → download the `.p8` private key file. Note the **Key ID** displayed after creation.

4. **Configure Apple provider in Firebase Console**

   Go to **Firebase Console** → **Authentication** → **Sign-in method** → **Apple** → enable it. Enter your **Services ID**, **Apple Team ID**, **Key ID**, and upload the `.p8` private key file.

5. **Add the Xcode capability**

   Open `ios/Runner.xcworkspace` in Xcode. Select the **Runner** target → **Signing & Capabilities** → click **+ Capability** → add **Sign in with Apple**.

> **Note:** The `sign_in_with_apple` package is already included in `pubspec.yaml` — no additional dependencies are needed.

> **Note:** The Apple SSO button is iOS-only — it will not appear on Android by design.

> **Warning:** Never commit the `.p8` private key file — add it to `.gitignore` if downloaded locally.

## Account Deletion

Users can delete their account from the Profile screen. The flow is:

1. **Confirmation dialog** — warns that deletion is permanent and irreversible.
2. **Re-authentication** — verifies identity via the user's current sign-in provider (password, Google, Apple, or phone).
3. **Three-step cleanup** — deletes Cloud Storage files (`users/{uid}/`), Firestore document (`users/{uid}`), then Firebase Auth record, in that order.

### Orphaned Data Trade-Off

Account deletion is client-side only — there is no Cloud Function involved. If the Storage or Firestore deletion step fails (e.g. due to a network issue), the auth record is still deleted. The user is signed out and shown a success message.

This means **orphaned data may remain** in Cloud Storage or Firestore if those steps fail. Storage and Firestore failures are logged to Crashlytics as non-fatal errors for monitoring. For production apps that require guaranteed cleanup, consider adding a Cloud Function triggered by `auth.user().onDelete()` that performs server-side cleanup of the user's data.

There is no admin-initiated deletion or account merging — those are out of scope.

## Email Verification

Email/password users are required to verify their email address before accessing the app. After sign-up, the router guard redirects to `/verify-email` instead of `/home`. The screen:

- **Auto-sends** a verification email on mount
- **Polls** every 5 seconds (Firebase `authStateChanges()` does not fire on `user.reload()`, so polling is required)
- Provides a **"Resend Email"** button with a 60-second cooldown
- Provides an **"I've Verified My Email"** button for manual checking
- Allows **sign out** to return to the login screen

SSO users (Google, Apple) and phone-authenticated users bypass email verification entirely — SSO emails are already provider-verified, and phone auth users have no email address.

### Making Verification Optional

To disable email verification for downstream projects, remove the `needsVerification` block from the redirect function in `lib/routing/router.dart`. The `/verify-email` route and `VerifyEmailScreen` can then be safely deleted.

## Project Structure

```
lib/
├── main.dart              # Bootstrap: bindings, dotenv, ProviderScope
├── app.dart               # Root MaterialApp.router (theme, routing, l10n)
├── core/
│   ├── constants/         # App-wide constants and env config
│   ├── data/              # BaseRepository, FirestoreRepository, Result type
│   ├── errors/            # Custom exception hierarchy, error boundary
│   ├── extensions/        # Dart extension methods on framework types
│   ├── l10n/              # Locale notifier for runtime locale switching
│   ├── network/           # Dio HTTP client with auth + performance interceptors
│   ├── services/          # Firebase services (Analytics, Crashlytics, FCM, etc.)
│   ├── storage/           # Cloud storage (BaseStorageService) + local storage
│   ├── theme/             # ThemeData factories, colour/typography tokens
│   ├── utils/             # Validators, formatters, pure helpers
│   └── widgets/           # Shared UI components (AccessibleTouchTarget, etc.)
├── features/              # Self-contained feature modules
│   ├── auth/              # Login, sign-up, forgot password, SSO
│   ├── biometric/         # Biometric lock (Face ID, Touch ID, fingerprint)
│   ├── explore/           # Paginated list reference (infinite scroll, pull-to-refresh)
│   ├── phone_auth/        # Phone number sign-in (SMS OTP)
│   ├── profile/           # User profile model, avatar upload, view model
│   └── shell/             # Bottom nav bar, side drawer, tab screens
├── routing/               # GoRouter config and route guards
l10n/
├── app_en.arb             # English source strings (ARB format)
└── app_ar.arb             # Arabic translations
```

## Firestore Data Layer

### Overview

The template provides a generic Firestore repository pattern so adding a new Firestore-backed feature requires: (1) create a model with `fromJson`/`toJson`, (2) register a `FirestoreRepository<T>` in DI against `BaseRepository<T>`, (3) inject `BaseRepository<T>` in the ViewModel. No Firestore imports outside `core/`.

### The `Result<T>` Type

All data operations return `Result<T>` — a sealed class with two states: `Success<T>` (carries the value) and `Failure` (carries a typed `AppException`). Consuming code pattern-matches on `Success`/`Failure` — no try/catch at the calling layer.

### Available Operations

| Method | Signature | Description |
|---|---|---|
| `create` | `create(model)` → `Future<Result<T>>` | Create a new document |
| `read` | `read(id)` → `Future<Result<T>>` | Read a document by ID |
| `update` | `update(id, model)` → `Future<Result<T>>` | Update an existing document |
| `delete` | `delete(id)` → `Future<Result<void>>` | Delete a document |
| `watchStream` | `watchStream(id)` → `Stream<Result<T>>` | Real-time document updates |
| `queryList` | `queryList(options)` → `Future<Result<PaginatedResult<T>>>` | Paginated list query with filters, sorting, and opaque cursor |

### Typed Error Mapping

- Document not found → `DocumentNotFoundException`
- No connectivity → `NetworkException`
- Permission denied → `PermissionException`
- All other Firestore errors → `DataException` with original message for logging

### Reference Example: UserProfile

- `features/profile/data/user_profile_model.dart` — fields: `id`, `displayName`, `email`, `avatarUrl` (nullable), `createdAt`, `updatedAt`
- Registered in DI as `BaseRepository<UserProfileModel>` backed by `FirestoreRepository<UserProfileModel>` with `collectionPath: 'users'`
- The Profile screen reads from this repository and handles loading, loaded, and failure states
- Follow this pattern exactly when creating new feature repositories

### Reference Example: Explore (Paginated List)

- `features/explore/` — paginated list of user profiles using `queryList` with infinite scroll and pull-to-refresh
- `ExploreViewModel` manages pagination state (cursor, hasMore, loading flags, error states) via an `ExploreState` immutable class
- `ExploreScreen` uses a `ScrollController` at 80% scroll threshold to trigger `loadNextPage()`, with `RefreshIndicator` for pull-to-refresh
- `UserDetailScreen` shows all fields for a selected user profile
- Follow this pattern when building any paginated list feature — swap `UserProfileModel` for your model and adjust `QueryOptions` (filters, sort order, page size)

### Adding a New Repository (Step-by-Step)

1. Create your model class with `fromJson(Map<String, dynamic>)` and `toJson()` methods
2. Register a `FirestoreRepository<YourModel>` in DI, configured with the collection path and your model's serialization functions, bound against `BaseRepository<YourModel>`
3. In your ViewModel/controller, inject `BaseRepository<YourModel>` — never `FirestoreRepository` directly
4. Handle `Success` and `Failure` states from every `Result<T>` returned

### Subcollections

`collectionPath` supports nested paths: e.g. `'users/{userId}/posts'`. Pass the interpolated path when registering the repository.

### Timestamps

Use `FieldValue.serverTimestamp()` for `createdAt` and `updatedAt` fields to ensure consistency.

### Offline Cache

Firestore SDK caches documents locally by default. Documents served from cache while offline are valid `Success` results, not `Failure`.

## Cloud Storage

### Overview

The template provides a file storage abstraction. Feature code depends on `BaseStorageService` via DI — never imports `FirebaseStorageService` directly.

### Available Operations

| Method | Signature | Description |
|---|---|---|
| `uploadFile` | `uploadFile(storagePath, bytes, {onProgress})` → `Future<Result<String>>` | Upload file, returns download URL on success |
| `downloadUrl` | `downloadUrl(storagePath)` → `Future<Result<String>>` | Get download URL for a stored file |
| `deleteFile` | `deleteFile(storagePath)` → `Future<Result<void>>` | Delete a file from storage |

### Progress Tracking

`uploadFile` accepts an optional `onProgress` callback that receives a `double` between 0.0 and 1.0.

### Cancellation

Uploads return a handle supporting cancellation. If cancelled mid-upload, the partially uploaded file is deleted from Cloud Storage — no orphaned files.

### Typed Error Mapping

- File not found → `FileNotFoundException`
- No connectivity → `NetworkException`
- Permission denied → `PermissionException`

### Reference Example: Avatar Upload

The Profile screen includes an avatar upload flow demonstrating the full pattern: image picker → compression (max 500KB) → upload to `avatars/{userId}` with progress indicator → update `avatarUrl` in Firestore via `BaseRepository<UserProfileModel>`. The `ProfileViewModel` depends on `BaseStorageService` and `BaseRepository<UserProfileModel>` via DI — zero Firebase imports.

### Storage Path Conventions

The service has no opinion on path structure — callers provide the full `storagePath` string (e.g. `'avatars/$userId'`, `'documents/$docId/attachments/$fileName'`). File size limits and MIME type validation are the caller's responsibility, not the service's.

### Adding File Upload to a Feature

1. Inject `BaseStorageService` in your ViewModel
2. Call `uploadFile(path, bytes, onProgress: (p) => updateProgress(p))`
3. Handle `Success` (contains download URL) or `Failure`
4. If the URL needs to be persisted (e.g. avatar URL), chain a repository update after a successful upload

### Platform Setup (Image Picker)

The `image_picker` package requires permission entries:

- **iOS:** `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` in `Info.plist` (already configured)
- **Android:** `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` in `AndroidManifest.xml` (already configured)

### Swapping Providers

To replace Firebase Storage with S3 or another provider: create a new class implementing `BaseStorageService`, update the DI registration. Zero feature code changes.

## Accessibility

All interactive elements across every screen ship with `Semantics` labels describing their action. The `AccessibleTouchTarget` wrapper widget in `lib/core/widgets/accessible_touch_target.dart` enforces a 44x44 logical pixel minimum touch target on any child widget — use it for all tappable elements.

Dynamic state labels are used throughout: the show/hide password toggle, theme toggle, and drawer menu button all have `Semantics` labels that update to reflect current state (e.g. "Switch to dark mode" / "Switch to light mode"). Error states and status indicators are conveyed via both color AND text/icon — never color alone.

`AccessibilityChecklist.md` in the repo root documents what to verify when adding new screens: semantic labels, touch targets, focus order, modal focus trapping, screen reader testing with TalkBack (Android) and VoiceOver (iOS).

When adding new screens or features, add `Semantics` labels in the same commit as the widget — do not defer accessibility as a separate pass.

## Adding a New Language

1. Create a new ARB file in `l10n/` (e.g. `app_ar.arb` for Arabic).
2. Copy all keys from `app_en.arb` and translate the values.
3. Add the locale to `supportedLocales` in `lib/app.dart`.
4. Run `flutter gen-l10n` (or let `build_runner` handle it).

## Localization & AI Translation

### ARB Files as Source of Truth

Launchpad uses Flutter's ARB files (`l10n/app_en.arb`) as the single source of truth for all user-facing strings. Every key in the ARB file includes a `@description` field that provides context to both human translators and AI translation tools. The description should answer: what the string is, where it appears, and what it does.

**Every new ARB key added to a project built on Launchpad must include a descriptive `@description` field.** Generic descriptions like `"Button label"` lead to poor translations — write descriptions that disambiguate context, e.g. `"Primary submit button on the sign-up screen. Tapping it creates a new account with the entered email and password."`.

### Android — Google Play Continuous Translation (Gemini)

Google Play Continuous Translation is an opt-in feature in the Play Console that uses Gemini AI to automatically translate your app's strings when a new App Bundle is uploaded.

- **Automation level:** Very high — translations are generated automatically on each AAB upload with no developer intervention
- **Cost:** Free (as of 2026)
- **ARB integration:** ARB files need to be exported to the Play Console's expected format (CSV or via the Play Developer API) before upload. This is a manual, project-specific step — add it to your release checklist or CI pipeline
- **How `@description` helps:** The description fields feed directly into Gemini's translation context. Descriptive, unambiguous descriptions significantly improve translation quality
- **Limitations:** AI translation can struggle with context ambiguity (e.g. "Back" as navigation vs. body part), string interpolation placeholders (e.g. `{count}` rendered literally), and UI clipping in languages with longer words (German, Finnish). Always review generated translations before publishing to production

### iOS — Xcode String Catalogs & Apple Intelligence

Xcode's String Catalog (`.xcstrings`) format provides AI-assisted translation powered by Apple Intelligence, built into the Xcode IDE.

- **How it works:** Xcode extracts strings from Swift/SwiftUI code and offers AI-powered auto-fill translations within the editor
- **Flutter note:** Flutter uses ARB files, not `.xcstrings`. To use Xcode's AI translation, a conversion step is needed — tools like `arb_to_xcstrings` or a custom CI script can convert ARB to `.xcstrings` format. This conversion is project-specific and out of scope for the template
- **Automation level:** Moderate — the developer triggers translation within Xcode; it does not run automatically on build or upload
- **Cost:** Free, included in the Xcode toolset

### Workflow Recommendation for Teams

1. **Maintain ARB files as the source of truth** in the repository. All string additions and edits happen in `l10n/app_en.arb`
2. **Use Google Play Continuous Translation for Android** — it offers the lowest friction path to multilingual support, with translations generated automatically on AAB upload
3. **For iOS, evaluate the ARB-to-xcstrings conversion workflow** — if your team already works in Xcode for native modules, the conversion may be worthwhile; otherwise, rely on the Android pipeline's translations and apply them to both platforms
4. **Always review AI translations for:**
   - Context errors — nouns translated as verbs or vice versa (e.g. "Book" as a noun vs. an action)
   - Broken placeholder variables — `{userName}` rendered as literal text instead of a substitution token
   - UI clipping — languages with longer average word length (German, Finnish, Greek) may overflow fixed-width UI elements
5. **Test RTL languages** (Arabic, Hebrew) using the locale switcher built into the side drawer to verify layout mirroring and text alignment

## Customising Theme Tokens

Theme tokens are defined in `lib/core/theme/`:

- **`AppColors`** — all color tokens for light and dark themes. Each color pair includes a comment showing its WCAG AA contrast ratio against the relevant background.
- **`AppTextStyles`** — font size scale: xs (11), sm (13), md (15), lg (17), xl (20), xxl (24), display (32). Font family defined once.
- **`AppSpacing`** — spacing scale: 4, 8, 12, 16, 24, 32, 48, 64.
- **`AppRadius`** — border radius: sm (4), md (8), lg (16), xl (24).

To rebrand for a new project: update the color tokens in `AppColors`, change the font family in `AppTextStyles`, and rebuild. All screens update automatically — zero other code changes needed.

Both light and dark `ThemeData` objects are wired to `MaterialApp` via `AppTheme.light` and `AppTheme.dark` getters. The `ThemeNotifier` reads the user's preference from `SharedPreferences` on init and writes on change.

## Adding a New Screen

1. Create a feature folder: `lib/features/<feature_name>/`
2. Add subdirectories as needed: `screens/`, `providers/`, `models/`, `widgets/`
3. Create your screen widget — all text must reference `AppLocalizations`, all colors/spacing must reference theme tokens, all interactive elements must have `Semantics` labels
4. Register the route in `lib/routing/router.dart` — add it inside the `ShellRoute` if it should show the bottom nav bar, or outside if it's a standalone screen
5. The router redirect guard handles four states in priority order: onboarding (first launch) → login (unauthenticated) → email verification (unverified email/password user) → home (authenticated and verified). Phone auth and SSO users bypass email verification. Protected routes are handled automatically — no additional code needed
6. Add new ARB keys to `l10n/app_en.arb` for any new user-facing strings
7. Run `flutter gen-l10n` to regenerate the localizations class

## Deep Links

The app supports deep links via a custom URL scheme and universal links (HTTPS).

- **Custom scheme:** `launchpad://` (e.g. `launchpad://home`, `launchpad://profile`)
- **Universal link:** `https://template.launchpad.app/` (e.g. `https://template.launchpad.app/home`)

Malformed or unrecognised deep link URLs are handled gracefully — the app opens to `/home` (authenticated) or `/login` (unauthenticated) and never crashes.

### Testing Deep Links

**iOS Simulator:**

```bash
xcrun simctl openurl booted "launchpad://home"
```

**Android Emulator:**

```bash
adb shell am start -W -a android.intent.action.VIEW -d "launchpad://home"
```

### Adding a New Deep Link Route

Add the route to `lib/routing/router.dart` — no other changes are needed. The existing auth redirect guard handles unauthenticated access to protected routes automatically.

### Customising the Scheme and Host

When adapting this template for your project, update the placeholder scheme and host in the following files:

1. **`android/app/src/main/AndroidManifest.xml`** — change the `android:host` and `android:scheme` values in the deep link intent filters
2. **`ios/Runner/Info.plist`** — change the `launchpad` string in `CFBundleURLSchemes` and update the `CFBundleURLName`
3. **This README** — update the scheme and host references above

### Universal Links (HTTPS) — Production Setup

Universal links require server-side configuration that is out of scope for this template but required for production:

- **Android:** Host a `assetlinks.json` file at `https://<your-host>/.well-known/assetlinks.json`
- **iOS:** Host an `apple-app-site-association` file at `https://<your-host>/.well-known/apple-app-site-association`

Refer to the [Android App Links](https://developer.android.com/training/app-links) and [Apple Universal Links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app) documentation for details.

## Per-Project Configuration Checklist

Everything a developer needs to do after cloning to make this their own project.

### Required Before Running

- [ ] Create a Firebase project and enable Authentication, Firestore, Cloud Storage
- [ ] Run `flutterfire configure` or manually place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Copy `.env.example` to `.env.development` and fill in `BASE_URL`

### Authentication Setup

- [ ] Enable Email/Password sign-in method in Firebase Console
- [ ] Enable Google sign-in method — add SHA-1 fingerprint (Android), download updated `google-services.json`
- [ ] Add `REVERSED_CLIENT_ID` URL scheme in Xcode for iOS Google Sign-In
- [ ] (iOS) Enable Sign in with Apple: Apple Developer portal setup, Firebase Console Apple provider config, Xcode capability
- [ ] (Phone auth) Enable Phone sign-in method in Firebase Console — requires Blaze plan for SMS delivery
- [ ] (Phone auth) Set `phone_auth_enabled` to `true` in Firebase Remote Config to show the phone sign-in button
- [ ] (Phone auth) Add test phone numbers in Firebase Console for development (avoids SMS charges)
- [ ] Register App Check debug tokens in Firebase Console for each development device

### Biometric Lock Setup

- [ ] (iOS) Add `NSFaceIDUsageDescription` to `ios/Runner/Info.plist`
- [ ] (Android) Add `USE_BIOMETRIC` permission to `android/app/src/main/AndroidManifest.xml`
- [ ] (Android, optional) Add `FLAG_SECURE` method channel handler in `MainActivity` for app switcher privacy

### Firebase Services

- [ ] Enable Analytics, Crashlytics, Cloud Messaging, Remote Config, Performance Monitoring in Firebase Console
- [ ] (iOS) Upload APNs authentication key to Firebase Console → Cloud Messaging for push notifications
- [ ] (iOS) Enable Push Notifications + Background Modes capabilities in Xcode

### CI/CD Distribution

See [`README_CI.md`](README_CI.md) for detailed setup instructions.

- [ ] Enable Firebase App Distribution in Firebase Console
- [ ] Create a Firebase service account with App Distribution permissions
- [ ] Create an Android keystore for signing QA builds
- [ ] Obtain Apple distribution certificate and provisioning profile
- [ ] Configure all required GitHub Secrets (see [`README_CI.md`](README_CI.md) for the full list)
- [ ] Create an `internal-qa` tester group in Firebase App Distribution
- [ ] Update `ios/ExportOptions.plist` with your `teamID` and provisioning profile values

### Branding & Customization

- [ ] Update app name, bundle ID, and package name
- [ ] Update color tokens in `lib/core/theme/` — all screens update automatically
- [ ] Update deep link scheme and host in `AndroidManifest.xml`, `Info.plist`, and README
- [ ] Update the pinned Flutter version in all three workflow files if upgrading

### Firestore & Security Rules

- [ ] Configure Firestore security rules (at minimum: authenticated-user-only read/write)
- [ ] Configure Cloud Storage security rules (at minimum: authenticated-user-only)
- [ ] Create composite indexes for any `queryList` queries combining `orderBy` with `where` on different fields (Firestore logs the index-creation URL on first failure)

### Before Going Live

- [ ] Replace App Check `DebugAppCheckProvider` with production providers (DeviceCheck for iOS, Play Integrity for Android)
- [ ] Enable App Check enforcement per Firebase service in the Console
- [ ] Configure iOS dSYM upload for Crashlytics symbolication (see Crashlytics section)
- [ ] Host `assetlinks.json` (Android) and `apple-app-site-association` (iOS) for universal links
- [ ] Review and customize Remote Config default values in `RemoteConfigDefaults`
- [ ] Implement FCM notification tap routing in `NotificationService` for project-specific navigation

## CI/CD

The project uses **GitHub Actions** for continuous integration. The workflow is defined in `.github/workflows/flutter_ci.yml`.

### What the pipeline does

The pipeline runs automatically on every **pull request** and **push** to `main` or `master`. It performs two checks:

1. **Static analysis** — `flutter analyze --fatal-infos` (info-level issues fail the build)
2. **Tests** — `flutter test`

Both checks run in a single `analyze_and_test` job on `ubuntu-latest`. Code generation (`build_runner`) and l10n generation (`gen-l10n`) run before analysis and tests so that all generated files are present.

### Pinned Flutter version

The workflow pins Flutter to **3.41.2** (stable). This ensures reproducible builds — every CI run uses the same Flutter/Dart version regardless of when it runs. Update the `flutter-version` value in the workflow file when you intentionally upgrade Flutter.

### Extending the pipeline with build steps

Add a new job after `analyze_and_test`:

```yaml
jobs:
  analyze_and_test:
    # ... existing job ...

  build_android:
    runs-on: ubuntu-latest
    needs: analyze_and_test
    steps:
      # ... your build steps ...
```

The `needs: analyze_and_test` dependency ensures builds only run after analysis and tests pass.

### Adding Firebase config for real builds

The CI workflow creates placeholder Firebase files so analysis and tests succeed. The distribution workflows (`distribute_android.yml`, `distribute_ios.yml`) decode real Firebase config from GitHub Secrets at build time — the files are never committed to the repo, consistent with the `.gitignore` convention.

All three secrets are required for distribution builds:

| Secret | File It Produces |
|--------|-----------------|
| `GOOGLE_SERVICES_JSON` | `android/app/google-services.json` |
| `GOOGLE_SERVICE_INFO_PLIST` | `ios/Runner/GoogleService-Info.plist` |
| `FIREBASE_OPTIONS_DART` | `lib/firebase_options.dart` |

Generate each by base64-encoding the corresponding file (see [`README_CI.md`](README_CI.md) for step-by-step instructions).

### QA Build Distribution

In addition to PR checks, two distribution workflows run automatically on every push (merge) to `main`:

| Workflow | File | What It Does |
|---|---|---|
| Distribute Android | `distribute_android.yml` | Builds a signed release APK and uploads it to Firebase App Distribution |
| Distribute iOS | `distribute_ios.yml` | Builds a signed release IPA and uploads it to Firebase App Distribution |

Both workflows run the full test suite before building — **if any test fails, the build is not distributed.** Both run in parallel. Every distributed build includes auto-generated release notes containing the Git commit SHA, branch name, and commit message.

> **Full setup instructions** — including all required GitHub Secrets, Android keystore generation, iOS certificate and provisioning profile setup, `ExportOptions.plist` configuration, tester group management, and runner cost considerations — are documented in [`README_CI.md`](README_CI.md).

## Testing

The test directory mirrors the `lib/` structure:

```
test/
├── core/{data, services, network, theme}/
├── features/{auth, profile, shell}/
├── routing/
└── helpers/          # Shared test infrastructure
    ├── mock_providers.dart   # Fakes for all abstract interfaces
    ├── test_utils.dart       # pumpApp() widget test helper
    └── README.md             # How to write tests
```

**Mocking approach:** Manual fakes are the default strategy — every abstract service interface has a corresponding `Fake*` class in `mock_providers.dart`. `mockito` is used for error mapping tests where `fake_cloud_firestore` cannot simulate `FirebaseException` errors. `fake_cloud_firestore` provides an in-memory Firestore for CRUD and stream tests. `FirestoreRepository`, `FirebaseStorageService`, and `FirebaseAuthRepository` all accept optional instance parameters for DI in tests (`FirebaseAuthRepository` also accepts `GoogleSignIn` and `AppleSignInProvider` for SSO mocking).

**`pumpApp()` helper:** Wraps a widget in `ProviderScope` + `MaterialApp.router` + `GoRouter` + localisation delegates + light theme. Accepts provider overrides and an optional locale parameter for RTL testing.

**Naming convention:** Test files mirror the source path and append `_test.dart` (e.g. `lib/core/data/result.dart` → `test/core/data/result_test.dart`).

For detailed guidance on creating mocks, using `pumpApp()`, overriding providers, and a complete worked example, see [`test/helpers/README.md`](test/helpers/README.md).

## Commands

```bash
flutter run                                                   # Run the app
flutter test                                                  # Run all tests
flutter analyze                                               # Static analysis
dart run build_runner build --delete-conflicting-outputs       # Code generation
dart run build_runner watch --delete-conflicting-outputs       # Code gen (watch)
```
