/// Full-screen onboarding carousel with skip/next/done navigation.
///
/// Displays a [PageView] of [OnboardingPageContent] widgets with a page
/// indicator and navigation controls. No AppBar, no bottom nav bar. The
/// layout fills the screen below the status bar.
///
/// Edge cases handled:
/// - No overscroll past first or last page.
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
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/onboarding_page_data.dart';
import '../providers/onboarding_notifier.dart';
import '../widgets/onboarding_nav_controls.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_page_indicator.dart';

/// The onboarding screen shown to first-time users.
///
/// When the user taps "Skip" or one of the final page's CTAs, the
/// [OnboardingNotifier] persists the completion flag to [SharedPreferences]
/// and the screen navigates directly to the target route.
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

  /// Marks onboarding as completed, then navigates to [route]. The
  /// [OnboardingNotifier] awaits the SharedPreferences write before this
  /// completes.
  Future<void> _completeOnboarding(String route) async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.pages.length;
    final isLastPage = _currentPage == pageCount - 1;

    // Pop scope: on Android, do not navigate back from onboarding. The system
    // handles back press on the root route (exit app).
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.background,
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
                        onPrimaryCta: () => _completeOnboarding('/signup'),
                        onSecondaryCta: () => _completeOnboarding('/login'),
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
                    onSkip: () => _completeOnboarding('/signup'),
                    onNext: _goToNextPage,
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
