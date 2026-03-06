# Adding a Firestore-Backed Feature Repository

Follow these three steps to create a new Firestore repository for any feature.
The `UserProfileModel` in this directory is the canonical reference.

> **Note:** This template has no Firebase project configured. The Profile screen
> demonstrates graceful `Failure` handling (empty state), which is intentional
> and correct behaviour for the boilerplate.

---

## Step 1 — Create Your Model

Create a model class in `features/<your_feature>/data/`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class YourModel {
  const YourModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory YourModel.fromJson(Map<String, dynamic> json) {
    return YourModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Excludes `id`, `createdAt`, and `updatedAt` — they are managed by the
  /// repository layer.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  YourModel copyWith({String? id, String? name}) {
    return YourModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _timestampToDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
```

**Rules:**

- `fromJson` handles missing keys with defaults — never throws on null.
- `toJson` excludes `id` (document key), `createdAt`, and `updatedAt`
  (server timestamps managed by `FirestoreRepository`).
- Firestore `Timestamp` → `DateTime` conversion goes in a static helper.

---

## Step 2 — Register the Repository in DI

Open `lib/core/data/repository_providers.dart` and add a new provider:

```dart
@Riverpod(keepAlive: true)
BaseRepository<YourModel> yourModelRepository(
  YourModelRepositoryRef ref,
) =>
    FirestoreRepository<YourModel>(
      collectionPath: 'yourCollection',
      fromJson: YourModel.fromJson,
      toJson: (model) => model.toJson(),
    );
```

Then run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Rules:**

- The return type is `BaseRepository<YourModel>` (abstract interface).
- The implementation is `FirestoreRepository<YourModel>` (concrete).
- `FirestoreRepository` is only imported in `repository_providers.dart` — never
  in feature code.

---

## Step 3 — Inject in Your ViewModel

In your feature's ViewModel / AsyncNotifier, depend on `BaseRepository<YourModel>`:

```dart
@riverpod
class YourViewModel extends _$YourViewModel {
  @override
  Future<YourModel> build() async {
    final repository = ref.watch(yourModelRepositoryProvider);
    final result = await repository.read(someId);

    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  }
}
```

**Rules:**

- Feature code imports `BaseRepository` and `Result` from `core/data/`.
- Feature code **never** imports `FirestoreRepository` or `cloud_firestore`.
- Pattern-match on `Success` / `Failure` to surface errors via
  Riverpod's `AsyncValue`.

---

## Checklist

- [ ] Model has `fromJson`, `toJson`, and `copyWith`.
- [ ] `toJson` excludes `id`, `createdAt`, `updatedAt`.
- [ ] Provider in `repository_providers.dart` returns `BaseRepository<T>`.
- [ ] `FirestoreRepository` is not imported in any file under `features/`.
- [ ] ViewModel uses `BaseRepository<T>` — zero Firebase imports.
- [ ] `build_runner` has been run after adding the provider.

---

## Platform Permissions — Avatar Upload

The avatar upload flow uses `image_picker` to access the device photo library.
Each platform requires permissions to be declared before the app can request
them at runtime.

### iOS

Add the following key to `ios/Runner/Info.plist` inside the top-level `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to set your profile picture.</string>
```

### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`
inside the `<manifest>` tag (before `<application>`):

```xml
<!-- Photo library access — API 33+ (Android 13) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Photo library access — API 32 and below -->
<uses-permission
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

> **Note:** `image_picker` handles the runtime permission prompt automatically.
> These manifest/plist entries only *declare* the permissions — without them the
> OS will deny the request silently.
