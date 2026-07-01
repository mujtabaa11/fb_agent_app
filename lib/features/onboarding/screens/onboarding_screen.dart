/// Full-screen onboarding carousel with skip/next/done navigation.
///
/// Displays a [PageView] of [OnboardingPageContent] widgets with a page
/// indicator and navigation controls. No AppBar, no bottom nav bar. The
/// layout fills the screen below the status bar.
///
/// Edge cases handled:
/// - No overscroll past first or last page.
/// - Single-page mode: shows "Get Started" directly, no "Next" or "Skip".
/// - Android back press: does nothing (prevents navigating to a nonexistent
///   previous route). On Android this means the system handles it (exit app).
/// - Directional layout: swipe direction, button positions, and page
///   indicator use directional properties so they would mirror correctly if
///   an RTL locale is added in the future.
/// - [PageController] is properly disposed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../models/onboarding_page_data.dart';
import '../providers/onboarding_notifier.dart';
import '../widgets/onboarding_nav_controls.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_page_indicator.dart';

/// The onboarding screen shown to first-time users.
///
/// When the user taps "Skip" or "Get Started", the [OnboardingNotifier]
/// persists the completion flag to [SharedPreferences] and notifies the
/// router-level flag — the GoRouter redirect guard re-evaluates and
/// navigates to login (unauthenticated) or home (authenticated).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    this.pages = defaultOnboardingPages,
    super.key,
  });

  /// The pages to display. Defaults to [defaultOnboardingPages].
  final List<OnboardingPageData> pages;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Marks onboarding as completed. Both "Skip" and "Get Started" call this.
  /// The [OnboardingNotifier] awaits the SharedPreferences write, then
  /// notifies the router-level flag — GoRouter redirect handles navigation.
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.pages.length;
    final isLastPage = _currentPage == pageCount - 1;
    final isSinglePage = pageCount == 1;

    // Pop scope: on Android, do not navigate back from onboarding. The system
    // handles back press on the root route (exit app).
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Page content — expands to fill available space.
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: pageCount,
                    // Prevent overscroll past first/last page.
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OnboardingPageContent(
                        data: widget.pages[index],
                      );
                    },
                  ),
                ),

                // Page indicator.
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppTokens.space24,
                  ),
                  child: OnboardingPageIndicator(
                    pageCount: pageCount,
                    currentPage: _currentPage,
                  ),
                ),

                // Navigation controls.
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppTokens.space32,
                  ),
                  child: OnboardingNavControls(
                    isLastPage: isLastPage,
                    isSinglePage: isSinglePage,
                    onSkip: _completeOnboarding,
                    onNext: _goToNextPage,
                    onDone: _completeOnboarding,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
