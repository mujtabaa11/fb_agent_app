# Onboarding

A pre-built onboarding shell with a swipeable PageView carousel, skip/next/done navigation, a persisted completion flag, and router guard integration. Downstream projects replace the placeholder content with their own — the infrastructure is ready to use.

## How It Works

1. **First launch** — the router guard detects that `hasCompletedOnboarding` is `false` in `SharedPreferences` and redirects to `/onboarding`.
2. **User swipes** through 3 placeholder pages (or taps Skip / Get Started).
3. **On completion** — `completeOnboarding()` writes `true` to `SharedPreferences`, the router guard re-evaluates, and the user is sent to `/login` (unauthenticated) or `/home` (authenticated).
4. **Subsequent launches** — the flag is read on startup. If `true`, onboarding is skipped entirely.

## Customizing Pages

Pages are defined as a `List<OnboardingPageData>` in `models/onboarding_page_data.dart`. Adding, removing, or reordering pages means editing this single list — no widget tree changes required.

### Changing the Number of Pages

Edit the `defaultOnboardingPages` list in `models/onboarding_page_data.dart`:

```dart
const List<OnboardingPageData> defaultOnboardingPages = [
  OnboardingPageData(
    icon: Icons.rocket_launch_outlined,
    title: _welcomeTitle,
    subtitle: _welcomeSubtitle,
  ),
  // Add or remove entries here.
];
```

The page indicator, navigation controls, and single-page mode all adapt automatically to any number of pages. **Recommended: 3–7 pages.** Fewer than 3 may not justify a carousel. More than 7 suggests a content problem, not a UI limitation.

### Adding a New Page

1. Add an entry to `defaultOnboardingPages` with your `IconData`, title accessor, and subtitle accessor.
2. Add two localized string accessors (one for title, one for subtitle) that reference `AppLocalizations` getters.
3. Add the corresponding keys to `l10n/app_en.arb` and `l10n/app_ar.arb`.
4. Run `flutter gen-l10n` to regenerate the localizations class.

Example — adding a 4th page:

```dart
// In onboarding_page_data.dart, add to the list:
OnboardingPageData(
  icon: Icons.palette_outlined,
  title: (l10n) => l10n.onboardingCustomizeTitle,
  subtitle: (l10n) => l10n.onboardingCustomizeSubtitle,
),
```

```json
// In app_en.arb:
"onboardingCustomizeTitle": "Make It Yours",
"@onboardingCustomizeTitle": { "description": "Title for fourth onboarding page." },
"onboardingCustomizeSubtitle": "Customize colors, fonts, and layout to match your brand.",
"@onboardingCustomizeSubtitle": { "description": "Subtitle for fourth onboarding page." }
```

### Replacing Placeholder Icons with Custom Illustrations

The placeholder pages use `IconData` (Material Icons). To use custom illustrations or images:

1. Change the `icon` field in `OnboardingPageData` from `IconData` to a `Widget` field, or add an optional `illustration` widget field.
2. Update `OnboardingPageContent` to render the widget instead of the `Icon`.
3. Place illustration assets in `assets/` and register them in `pubspec.yaml`.

The `OnboardingPageContent` widget is in `widgets/onboarding_page_content.dart` — modify the icon rendering section to display your custom widget.

### Adding New ARB Keys

All onboarding strings live in the ARB files under the `onboarding` prefix:

- `onboardingWelcomeTitle`, `onboardingWelcomeSubtitle`
- `onboardingBuildFasterTitle`, `onboardingBuildFasterSubtitle`
- `onboardingShipTitle`, `onboardingShipSubtitle`
- `onboardingSkipButton`, `onboardingNextButton`, `onboardingGetStartedButton`
- `onboardingPageIndicator` (with `{current}` and `{total}` placeholders)

Add new keys to both `l10n/app_en.arb` and `l10n/app_ar.arb`, then run:

```bash
flutter gen-l10n
```

## Resetting Onboarding

### Programmatically

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('has_completed_onboarding');
```

Then restart the app — the router guard will redirect to `/onboarding`.

### During Development — Clearing App Data

**Android (emulator or device):**

```bash
adb shell pm clear com.footballagentmate.app
```

**iOS Simulator:**

```bash
xcrun simctl uninstall booted com.footballagentmate.app
# Then reinstall and run
flutter run
```

Or delete the app from the simulator home screen and reinstall.

## Version-Gated Re-Showing (Pattern — Not Implemented)

Some projects re-show onboarding after a major app update. The recommended pattern:

1. Store the app version alongside the onboarding flag:

```dart
await prefs.setString('onboarding_completed_version', appVersion);
```

2. In the onboarding notifier's `build()` method, compare the stored version with the current app version:

```dart
final completedVersion = prefs.getString('onboarding_completed_version');
final currentVersion = packageInfo.version; // from package_info_plus
if (completedVersion == null || completedVersion != currentVersion) {
  return false; // re-show onboarding
}
return true;
```

3. Update `completeOnboarding()` to write the current version instead of (or alongside) the boolean flag.

This pattern is **documented only** — it is not implemented in the boilerplate. Each downstream project decides when and how to re-trigger onboarding.

## Disabling Onboarding Entirely

To remove onboarding from your project:

1. In `lib/routing/router.dart`, remove the onboarding checks from the `redirect` function:
   - Remove the `onboardingFlag.isLoading` check.
   - Remove the `!onboardingFlag.hasCompleted` check.
   - Remove the `isOnboarding` variable from the location checks.
2. Remove the `/onboarding` route from the route table.
3. Remove the `onboardingFlag` global and `OnboardingFlagNotifier` class.
4. Optionally delete the `lib/features/onboarding/` directory entirely.

## Testing

### Unit Tests

- `test/features/onboarding/onboarding_notifier_test.dart` — tests the `OnboardingNotifier` persistence logic (flag read, write, rebuild).
- `test/features/onboarding/onboarding_router_test.dart` — tests the four-state router guard chain (onboarding → login → verification → home).

### Bypassing Onboarding in Other Tests

The `pumpApp()` helper in `test/helpers/test_utils.dart` accepts a `hasCompletedOnboarding` parameter (default: `true`). All existing tests automatically bypass onboarding. Only onboarding-specific tests set it to `false`.

### Resetting the Flag in Development

Use the programmatic reset or the `adb`/`xcrun` commands documented above.
