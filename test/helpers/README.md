# Test Helpers

This directory contains shared test infrastructure for the Football Agent Mate project.

## Mocking Approach

We use **manual fakes** as the primary mocking strategy. Every abstract service
interface in the app has a corresponding `Fake*` class in `mock_providers.dart`.

### Why manual fakes?

- The app's interfaces are small and stable — writing fakes is straightforward.
- The codebase ships `NoOp*` implementations for Firebase services (analytics,
  crashlytics, notifications, remote config) that are reused as test fakes.
- No code-generation step required (no `build_runner` needed for mocks).

### When to use mockito instead

Use `@GenerateMocks` from the `mockito` package when you need:

- **Call verification** — asserting a method was called N times.
- **Argument capture** — inspecting arguments passed to a method.
- **Ordered verification** — asserting methods were called in sequence.
- **Simulating exceptions** from Firebase SDK classes that `fake_cloud_firestore`
  cannot produce (e.g. `permission-denied`, `unavailable` errors).

```dart
// Example: mockito-generated mock
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:football_agent_mate/features/auth/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository])
import 'my_test.mocks.dart';

void main() {
  final mockAuth = MockAuthRepository();
  when(mockAuth.currentUser).thenReturn(null);
  // ... use in test ...
  verify(mockAuth.signOut()).called(1);
}
```

After adding `@GenerateMocks`, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### When to use fake_cloud_firestore

Use `FakeFirebaseFirestore` for testing code that interacts with Firestore
directly (e.g. `FirestoreRepository`). It provides a full in-memory Firestore
implementation — including `withConverter`, `FieldValue.serverTimestamp()`,
and `snapshots()` streams — without requiring Firebase initialization.

Both `FirestoreRepository` and `FirebaseStorageService` accept an optional
instance parameter for DI in tests:

```dart
final fakeFirestore = FakeFirebaseFirestore();
final repo = FirestoreRepository<UserProfileModel>(
  collectionPath: 'users',
  fromJson: UserProfileModel.fromJson,
  toJson: (model) => model.toJson(),
  firestore: fakeFirestore,  // injected for testing
);
```

**Limitation:** `fake_cloud_firestore` does not simulate `FirebaseException`
errors (permission-denied, unavailable, etc.). For error mapping tests, use
mockito to mock the `FirebaseFirestore` chain and throw controlled exceptions.
See `test/core/data/firestore_repository_test.dart` for a working example.

### Testing FirebaseAuthRepository

`FirebaseAuthRepository` accepts optional DI parameters for all external
dependencies: `FirebaseAuth`, `GoogleSignIn`, and `AppleSignInProvider`.
Use mockito `@GenerateMocks` for `FirebaseAuth`, `UserCredential`, `User`,
`GoogleSignIn`, and `GoogleSignInAccount`. For Apple sign-in, pass a closure
matching the `AppleSignInProvider` typedef — no code generation needed.

`FirebaseAuthException` has a `@protected` constructor. To create instances in
tests, define a `TestFirebaseAuthException` subclass:

```dart
class TestFirebaseAuthException extends fb.FirebaseAuthException {
  TestFirebaseAuthException({required super.code, super.message});
}
```

See `test/features/auth/auth_repository_test.dart` for a complete example
covering sign-up, sign-in, Google SSO, Apple SSO, password reset, sign-out,
and cross-cutting network error mapping.

### Testing router redirect guards

The production router in `lib/routing/router.dart` uses module-level globals
for the `AuthRepository` and refresh notifier, so tests cannot inject
dependencies into it directly. Instead, construct a test-local `GoRouter` with
the same redirect callback but backed by `FakeAuthRepository` and a
controllable loading flag. Assert the redirect path via
`router.routeInformationProvider.value.uri.path`, NOT rendered widget content.

See `test/routing/router_guard_test.dart` for the full pattern.

### Testing ThemeNotifier (Riverpod + SharedPreferences)

Use `SharedPreferences.setMockInitialValues({})` (Flutter's built-in test
support) to seed preferences before each test. Use `ProviderContainer` to
unit-test the notifier without pumping a widget:

```dart
SharedPreferences.setMockInitialValues({StorageKeys.themeMode: 'dark'});

final container = ProviderContainer();
addTearDown(container.dispose);

final mode = await container.read(themeNotifierProvider.future);
expect(mode, ThemeMode.dark);
```

See `test/core/theme/theme_notifier_test.dart` for the full pattern covering
default behavior, persistence, and preference stability.

### Testing OnboardingNotifier (Riverpod + SharedPreferences)

Same pattern as ThemeNotifier — use `SharedPreferences.setMockInitialValues({})`
and `ProviderContainer`:

```dart
SharedPreferences.setMockInitialValues({});

final container = ProviderContainer();
addTearDown(container.dispose);

final completed = await container.read(onboardingNotifierProvider.future);
expect(completed, false);

await container.read(onboardingNotifierProvider.notifier).completeOnboarding();
final after = await container.read(onboardingNotifierProvider.future);
expect(after, true);
```

See `test/features/onboarding/onboarding_notifier_test.dart` for the full
pattern.

### Testing the onboarding router guard

The onboarding router guard adds a fourth state to the redirect chain. Tests
use a test-local `_TestOnboardingFlagNotifier` (controllable `isLoading` /
`hasCompleted` flags) merged with the auth notifier via `Listenable.merge`,
replicating the production `Listenable.merge([_authNotifier, onboardingFlag])`.

See `test/features/onboarding/onboarding_router_test.dart` for the full pattern.

### Bypassing onboarding in non-onboarding tests

`pumpApp()` defaults to `hasCompletedOnboarding: true`, which seeds
`SharedPreferences` with the flag set. All existing tests automatically bypass
onboarding without modification. Only onboarding-specific tests pass `false`.

### Testing account deletion order (three-step cleanup)

`FirebaseAuthRepository.deleteAccount()` executes three steps sequentially:
Storage → Firestore → Auth. To verify this order without depending on Firebase,
use `ThreeStepDeletionFake` (defined in `account_deletion_test.dart`). This
subclass of `FakeAuthRepository` overrides `deleteAccount()` to record step
names in a `deletionSteps` list:

```dart
final fake = ThreeStepDeletionFake();
fake.setUser(createTestAuthUser());

// ... trigger deletion via provider ...

expect(fake.deletionSteps, ['deleteStorage', 'deleteFirestore', 'deleteAuth']);
```

Each step can be independently failed via `storageFailWith`, `firestoreFailWith`,
and `authDeleteFailWith` to verify that Storage/Firestore failures do not block
the Auth deletion step.

### Testing polling with fakeAsync

For timer-based behavior (e.g. email verification polling), use the
`fake_async` package to control time advancement:

```dart
import 'package:fake_async/fake_async.dart';

test('polling fires at expected intervals', () {
  fakeAsync((async) {
    Timer.periodic(const Duration(seconds: 5), (_) {
      repo.reloadUser();
    });

    async.elapse(const Duration(seconds: 5));
    expect(callCount, 1);

    async.elapse(const Duration(seconds: 10));
    expect(callCount, 3);
  });
});
```

See `test/features/auth/email_verification_test.dart` for complete examples
including timer cancellation verification.

### Per-method failure overrides on FakeAuthRepository

`FakeAuthRepository` supports per-method failure overrides that take precedence
over the global `failWith`. This allows testing scenarios where one method fails
while others succeed (e.g. re-auth succeeds but link fails):

```dart
fakeAuth.linkPendingCredentialFailWith = const AuthException.coded(
  'Provider already linked.',
  code: 'provider-already-linked',
);
// signInWithEmail still succeeds, only linkPendingCredential fails
```

Available per-method overrides: `sendEmailVerificationFailWith`,
`reloadUserFailWith`, `linkPendingCredentialFailWith`,
`deleteAccountFailWith`, `signInWithEmailFailWith`,
`signInWithGoogleFailWith`, `signInWithAppleFailWith`, `reauthFailWith`.

### Call logging on FakeAuthRepository

`FakeAuthRepository` records all method calls in a `callLog` list:

```dart
fakeAuth.setUser(createTestAuthUser());
await container.read(deleteAccountProvider.notifier)
    .reAuthWithEmailAndDelete('test@example.com', 'password');

expect(fakeAuth.callLog, contains('reauthenticateWithEmail'));
expect(fakeAuth.callLog, contains('deleteAccount'));
```

## How to Create a Mock

### Manual fake (preferred)

1. Open `mock_providers.dart`.
2. Implement the abstract interface with an in-memory backing store.
3. Add a `shouldFail` / `failWith` flag so tests can toggle failure paths.

### Existing fakes

| Interface                          | Fake class                  |
|------------------------------------|-----------------------------|
| `BaseRepository<UserProfileModel>` | `FakeUserProfileRepository` |
| `StorageService`                   | `FakeStorageService`        |
| `BaseStorageService`               | `FakeBaseStorageService`    |
| `AuthRepository`                   | `FakeAuthRepository`        |
| `AnalyticsService`                 | `FakeAnalyticsService`      |
| `CrashlyticsService`              | `FakeCrashlyticsService`    |
| `NotificationService`             | `FakeNotificationService`   |
| `RemoteConfigService`             | `FakeRemoteConfigService`   |
| `AppCheckService`                 | `FakeAppCheckService`       |

## How to Use `pumpApp()`

`pumpApp()` wraps a widget in the same tree shape as the real app:
`ProviderScope` → `MaterialApp.router` → `GoRouter` → your widget.

```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_utils.dart';
import '../helpers/mock_providers.dart';

void main() {
  testWidgets('displays greeting', (tester) async {
    await pumpApp(tester, const GreetingWidget());

    expect(find.text('Hello'), findsOneWidget);
  });
}
```

### Parameters

| Parameter                | Type              | Default         | Description                                                                 |
|--------------------------|-------------------|-----------------|-----------------------------------------------------------------------------|
| `tester`                 | `WidgetTester`    | (required)      | The tester from `testWidgets`.                                              |
| `child`                  | `Widget`          | (required)      | The widget under test.                                                      |
| `overrides`              | `List<Override>`  | `[]`            | Riverpod provider overrides.                                                |
| `locale`                 | `Locale`          | `Locale('en')`  | Locale passed to `MaterialApp.router`. English is currently the only supported locale. |
| `hasCompletedOnboarding` | `bool`            | `true`          | Sets the onboarding flag in SharedPreferences. Default bypasses onboarding. |

## How to Override a Provider in a Test

Pass overrides to `pumpApp()`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/features/auth/providers/auth_providers.dart';
import '../helpers/mock_providers.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows profile when authenticated', (tester) async {
    // 1. Create the fake
    final fakeAuth = FakeAuthRepository();
    fakeAuth.setUser(createTestAuthUser());

    // 2. Override the provider
    await pumpApp(
      tester,
      const ProfileWidget(),
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
      ],
    );

    // 3. Assert
    expect(find.text('Test User'), findsOneWidget);
  });
}
```

## Naming Convention

Test files must mirror the source file path and append `_test.dart`:

```
lib/core/data/result.dart           → test/core/data/result_test.dart
lib/features/auth/models/auth_user.dart → test/features/auth/auth_user_test.dart
lib/core/theme/app_theme.dart       → test/core/theme/app_theme_test.dart
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_agent_mate/core/data/result.dart';
import 'package:football_agent_mate/features/auth/providers/auth_providers.dart';
import '../helpers/mock_providers.dart';
import '../helpers/test_utils.dart';

void main() {
  late FakeAuthRepository fakeAuth;

  setUp(() {
    fakeAuth = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  group('LoginScreen', () {
    testWidgets('shows login form when unauthenticated', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: Text('Login Form')),
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
        ],
      );

      expect(find.text('Login Form'), findsOneWidget);
    });
  });
}
```
