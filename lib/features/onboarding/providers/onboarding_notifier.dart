/// Riverpod notifier that manages the onboarding completion state.
///
/// Reads the persisted `hasCompletedOnboarding` flag from [SharedPreferences]
/// on startup and exposes [completeOnboarding] to mark onboarding as done.
/// After persisting, it also notifies the router-level [OnboardingFlagNotifier]
/// so that the GoRouter redirect guard re-evaluates immediately.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../routing/router.dart' show onboardingFlag;

part 'onboarding_notifier.g.dart';

@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  }

  /// Marks onboarding as completed and persists the flag.
  ///
  /// This method **awaits** the [SharedPreferences] write before updating
  /// provider state — no fire-and-forget. After persisting, it notifies the
  /// router-level [OnboardingFlagNotifier] which triggers a GoRouter redirect
  /// re-evaluation, navigating the user to login or home.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.hasCompletedOnboarding, true);
    state = const AsyncData(true);
    // Bridge to the router-level flag notifier so GoRouter re-evaluates.
    onboardingFlag.markCompleted();
  }
}
