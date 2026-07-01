# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**football_agent_mate** — A mobile app for football agents, built on a production-quality Flutter boilerplate. Features include authentication, navigation, theming, localization, Firebase services, data layer, and CI/CD.

## Commands

```bash
# Run the app
flutter run

# Run tests
flutter test                          # all tests
flutter test test/widget_test.dart    # single test file

# Code generation (Riverpod providers, etc.)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # watch mode

# Static analysis
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture

- **State Management:** Riverpod with code generation (`@riverpod` annotations + `riverpod_generator`)
- **Navigation:** GoRouter (declarative, type-safe routing)
- **HTTP Client:** Dio
- **Auth:** Firebase Auth + Google Sign-In + Sign in with Apple
- **Local Storage:** `flutter_secure_storage` (sensitive data) + `shared_preferences` (preferences)
- **Environment:** `flutter_dotenv` — loads `.env.development` or `.env.production` (both gitignored; see `.env.example` for required vars)

## Project Structure

```
lib/
├── main.dart
├── core/           # Shared: constants, errors, extensions, theme, utils, widgets
├── features/       # Feature modules (to be implemented)
└── routing/        # GoRouter configuration
```

Feature modules should follow a self-contained structure with their own models, providers, and screens.

## Key Conventions

- SDK constraint: `>=3.0.0 <4.0.0`
- Android: Java 17, Kotlin DSL (`build.gradle.kts`), package `com.footballagentmate.app`
- Generated files (`.g.dart`) are produced by `build_runner` — run code generation after modifying `@riverpod` annotated providers
- Linting: `flutter_lints` + `custom_lint` with `riverpod_lint`
- Firebase config files (`google-services.json`, `GoogleService-Info.plist`) are gitignored — must be added per environment
- When building a signed production release (APK/AAB), verify that any `TestConfig` flags (e.g., `SKIP_LOCATION_VALIDATION`, `SKIP_PHONE_VALIDATION`) are set to `false`
- **Localization:** English-only for the MVP (`l10n/app_en.arb` is the sole ARB file). All UI strings still go through `AppLocalizations`/gen-l10n — never hardcode strings — and layouts still use directional properties (`EdgeInsetsDirectional`, `AlignmentDirectional`), so the app is well-positioned to add more languages, including RTL ones, later by dropping in a new ARB file
