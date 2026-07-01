import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name displayed in the app bar, task switcher, and browser tab title.
  ///
  /// In en, this message translates to:
  /// **'Football Agent Mate'**
  String get appTitle;

  /// Generic loading indicator text shown alongside a spinner while data is being fetched or an action is in progress.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Fallback error message displayed in a snackbar or inline alert when an unexpected error occurs and no specific error message is available.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Button label on error state screens and dialogs. Tapping it retries the failed operation.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// Error message displayed in a snackbar or inline alert when a network request fails due to no internet connectivity.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get noInternetError;

  /// Heading displayed at the top of the sign-up screen where new users register with email and password.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// Greeting heading displayed at the top of the login screen where returning users sign in.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// Form field label for the email text input on the login and sign-up screens.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Form field label for the password text input on the login and sign-up screens.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Primary submit button on the sign-up screen. Tapping it creates a new account with the entered email and password.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// Primary submit button on the login screen. Tapping it authenticates the user with the entered email and password.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// Text button on the login screen below the password field. Tapping it navigates to the password reset screen.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// Social sign-in button on the login and sign-up screens. Tapping it initiates the Google OAuth sign-in flow.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignInButton;

  /// Social sign-in button on the login and sign-up screens (iOS only). Tapping it initiates the Sign in with Apple flow.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get appleSignInButton;

  /// Heading displayed at the top of the password reset screen where users request a password reset email.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get passwordResetTitle;

  /// Primary submit button on the password reset screen. Tapping it sends a password reset link to the entered email address.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get passwordResetButton;

  /// Confirmation message shown on the password reset screen after a reset email has been successfully sent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a reset link.'**
  String get passwordResetConfirmation;

  /// Label for the Home tab in the bottom navigation bar. Navigates to the main home feed screen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Label for the Explore tab in the bottom navigation bar. Navigates to the content discovery screen.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Label for the Profile tab in the bottom navigation bar. Navigates to the user's profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Button in the side navigation drawer. Tapping it signs the user out and returns to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutButton;

  /// Error message shown on the sign-up screen when the user tries to register with an email address that is already associated with an existing account.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get emailAlreadyInUseError;

  /// Error message shown on the login screen when authentication fails due to an incorrect email or password combination.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get wrongPasswordError;

  /// Validation error shown on the sign-up screen when the entered password does not meet the minimum strength requirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, include 1 uppercase letter and 1 number.'**
  String get weakPasswordError;

  /// Error message shown when Firebase rate-limits the user after too many consecutive authentication attempts (login, sign-up, or password reset).
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait before trying again.'**
  String get tooManyRequestsError;

  /// Title text displayed in empty state placeholders when a list or feed has no content to show.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// Supportive body text displayed below the empty state title, encouraging the user to return later when content is available.
  ///
  /// In en, this message translates to:
  /// **'Check back later.'**
  String get emptyStateBody;

  /// Screen-reader-only accessibility label for the password visibility toggle button when the password is currently hidden. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Screen-reader-only accessibility label for the password visibility toggle button when the password is currently visible. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Placeholder message shown on screens or features that are not yet implemented, indicating future availability.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Error message shown when a user attempts Google sign-in but the email is already registered with an email/password account and cannot be automatically linked.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please log in with your email and password.'**
  String get googleAccountLinkError;

  /// Error message shown when a user attempts Apple sign-in but the email is already registered with an email/password account and cannot be automatically linked.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please log in with your email and password.'**
  String get appleAccountLinkError;

  /// Screen-reader-only accessibility label for the splash screen's loading spinner. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'Loading app, please wait.'**
  String get loadingAppLabel;

  /// Label for the system/automatic theme option in the theme switcher in the side drawer. Selecting it follows the device's light/dark mode setting.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeModeSystem;

  /// Label for the dark theme option in the theme switcher in the side drawer. Selecting it forces dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Label for the light theme option in the theme switcher in the side drawer. Selecting it forces light mode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Screen-reader-only accessibility label for the segmented theme mode control in the side drawer. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'Theme switcher'**
  String get themeSwitcherLabel;

  /// Header title displayed at the top of the side navigation drawer.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get drawerTitle;

  /// Section heading in the side navigation drawer that groups settings controls such as theme and language.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// Row label in the Settings section of the side drawer, identifying the theme mode control.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Screen-reader-only accessibility label for the circular user profile image displayed in the side drawer header. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'User avatar'**
  String get userAvatarLabel;

  /// Screen-reader-only accessibility label for the hamburger menu icon button in the app bar that opens the side navigation drawer. Not displayed as visible text.
  ///
  /// In en, this message translates to:
  /// **'Open navigation drawer'**
  String get openDrawerLabel;

  /// Button on the password reset confirmation screen. Tapping it navigates the user back to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Inline validation error shown below the email text field on the login or sign-up screen when the entered email format is invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmailError;

  /// Hardcoded fallback error message displayed by the global error boundary widget when the app crashes and localized strings are unavailable.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorBoundaryFallback;

  /// Heading displayed at the top of the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Title shown in the empty state widget on the profile screen when the user's profile data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get profileLoadErrorTitle;

  /// Body text shown in the empty state widget on the profile screen when the user's profile data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be loaded. Please try again later.'**
  String get profileLoadErrorBody;

  /// Label for the display name field on the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayNameLabel;

  /// Label for the email field on the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// Screen-reader-only accessibility label for the user's profile avatar image.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profileAvatarLabel;

  /// Button label on the profile screen that opens the device photo library to select a new avatar image.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhotoButton;

  /// Screen-reader-only accessibility label for the progress indicator shown while the avatar image is being uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get avatarUploadProgress;

  /// Error message shown when the selected avatar image exceeds the 500 KB size limit even after compression.
  ///
  /// In en, this message translates to:
  /// **'The selected image is too large. Please choose a smaller photo.'**
  String get avatarImageTooLargeError;

  /// Error message shown when the user denies photo library access permission when trying to select an avatar image.
  ///
  /// In en, this message translates to:
  /// **'Photo library access was denied. Please grant permission in Settings.'**
  String get photoLibraryPermissionDenied;

  /// Title shown in a snackbar or inline alert when the avatar upload or profile update fails.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get avatarUploadErrorTitle;

  /// Body text shown alongside the upload error title when the avatar upload or profile update fails.
  ///
  /// In en, this message translates to:
  /// **'Your photo could not be uploaded. Please try again.'**
  String get avatarUploadErrorBody;

  /// Title displayed at the top of the account linking bottom sheet that appears when SSO sign-in detects a conflicting email.
  ///
  /// In en, this message translates to:
  /// **'Link Your Account'**
  String get accountLinkTitle;

  /// Explanation text in the account linking bottom sheet. Contains the conflicting email address.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with {email}. Please sign in with your original method to link your accounts.'**
  String accountLinkBody(String email);

  /// Label for the password field in the account linking bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountLinkPasswordLabel;

  /// Primary action button in the account linking bottom sheet that re-authenticates and links accounts.
  ///
  /// In en, this message translates to:
  /// **'Sign In & Link'**
  String get accountLinkSignInButton;

  /// Divider text between the password form and SSO buttons in the account linking bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'or sign in with'**
  String get accountLinkOrDivider;

  /// Success snackbar message shown after accounts are linked.
  ///
  /// In en, this message translates to:
  /// **'Accounts linked successfully.'**
  String get accountLinkSuccessMessage;

  /// Error snackbar message shown when account linking fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Unable to link accounts. Please try again.'**
  String get accountLinkFailedMessage;

  /// Inline error shown in the account linking bottom sheet when the password is incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get accountLinkWrongPassword;

  /// Destructive button on the profile screen that initiates the account deletion flow.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// Title of the first confirmation dialog shown when the user taps the delete account button.
  ///
  /// In en, this message translates to:
  /// **'Delete Your Account?'**
  String get deleteAccountConfirmTitle;

  /// Body text of the first confirmation dialog explaining the irreversibility of account deletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be deleted.'**
  String get deleteAccountConfirmBody;

  /// Cancel button in the account deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountConfirmCancel;

  /// Destructive confirm button in the account deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountConfirmDelete;

  /// Title of the re-authentication step shown before account deletion proceeds.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get deleteAccountReauthTitle;

  /// Explanation text in the re-authentication step of account deletion.
  ///
  /// In en, this message translates to:
  /// **'For security, please verify your identity before deleting your account.'**
  String get deleteAccountReauthBody;

  /// Button label in the re-auth step that verifies the password and proceeds with deletion.
  ///
  /// In en, this message translates to:
  /// **'Verify & Delete'**
  String get deleteAccountReauthPasswordButton;

  /// Button label for Google re-authentication before account deletion.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate with Google'**
  String get deleteAccountReauthGoogleButton;

  /// Button label for Apple re-authentication before account deletion.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate with Apple'**
  String get deleteAccountReauthAppleButton;

  /// Snackbar message shown after successful account deletion, before navigating to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get deleteAccountSuccessMessage;

  /// Error message shown when account deletion fails because the user's login session is too old.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before deleting your account.'**
  String get deleteAccountRequiresRecentLogin;

  /// Generic error message shown when account deletion fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete your account. Please try again later.'**
  String get deleteAccountErrorGeneric;

  /// Inline error shown in the re-auth step when the password is incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get deleteAccountWrongPassword;

  /// Accessibility label for the progress indicator shown during the three-step account deletion process.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account…'**
  String get deleteAccountDeletingProgress;

  /// Heading displayed at the top of the email verification screen after sign-up.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// Body text on the email verification screen explaining what the user should do.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Please check your inbox and tap the link to continue.'**
  String verifyEmailBody(String email);

  /// Button that resends the verification email to the user's address.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get verifyEmailResendButton;

  /// Label shown on the resend button during cooldown, displaying the remaining seconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String verifyEmailResendCooldown(int seconds);

  /// Button the user taps after verifying their email. Checks verification status and navigates to home if verified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get verifyEmailContinueButton;

  /// Button on the email verification screen that signs the user out and returns to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get verifyEmailSignOutButton;

  /// Snackbar message shown after a verification email is successfully sent or resent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get verifyEmailSentConfirmation;

  /// Snackbar message shown when the user taps 'I've Verified' but their email is not yet confirmed.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Please check your inbox.'**
  String get verifyEmailNotYetVerified;

  /// Snackbar error message when sending the verification email fails for a generic reason.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification email. Please try again.'**
  String get verifyEmailSendFailed;

  /// Screen-reader-only accessibility label for the progress indicator shown while checking email verification status.
  ///
  /// In en, this message translates to:
  /// **'Checking verification status'**
  String get verifyEmailCheckLabel;

  /// Title for the first onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Your Players. Your Network. One App.'**
  String get onboardingSlide1Title;

  /// Subtitle for the first onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Agent Mate is built for football agents who mean business.'**
  String get onboardingSlide1Body;

  /// Title for the second onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Manage Every Client in One Place'**
  String get onboardingSlide2Title;

  /// Subtitle for the second onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Register your players, track contracts, store documents, and never miss an important date.'**
  String get onboardingSlide2Body;

  /// Title for the third onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Connect With Agents Worldwide'**
  String get onboardingSlide3Title;

  /// Subtitle for the third onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Post opportunities, discover players, and close deals — all inside Agent Mate.'**
  String get onboardingSlide3Body;

  /// Button label on the last onboarding page that completes the onboarding flow and navigates to sign up.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Button label on the last onboarding page that completes the onboarding flow and navigates to login.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// Button label to skip the onboarding flow and proceed directly to sign up.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Button label to advance to the next onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// Screen-reader-only accessibility label announcing the current page position in the onboarding carousel.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPageIndicator(int current, int total);

  /// Warning text displayed in the offline banner below the app bar when the device has no network connectivity.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some features may be unavailable.'**
  String get offlineBannerMessage;

  /// Screen-reader-only accessibility label for the offline banner so assistive technologies announce the connectivity state.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Some features may be unavailable.'**
  String get offlineBannerSemanticsLabel;

  /// Snackbar message shown when a Firestore write succeeds while the device is offline, indicating the change will sync automatically.
  ///
  /// In en, this message translates to:
  /// **'Changes saved offline — will sync when connected.'**
  String get offlineSaveMessage;

  /// Heading displayed at the top of the Explore screen showing the paginated user list.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// Title shown in the full-screen error state when the first page of the explore list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load users'**
  String get exploreLoadError;

  /// Body text shown in the full-screen error state when the first page of the explore list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading the list. Please try again.'**
  String get exploreLoadErrorBody;

  /// Title shown in the empty state when the explore list has no items to display.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get exploreEmptyTitle;

  /// Body text shown in the empty state when the explore list has no items to display.
  ///
  /// In en, this message translates to:
  /// **'There are no user profiles to show right now.'**
  String get exploreEmptyBody;

  /// Subtle text shown at the bottom of the explore list when all pages have been loaded and there are no more results.
  ///
  /// In en, this message translates to:
  /// **'No more results'**
  String get exploreNoMoreResults;

  /// Inline error text shown at the bottom of the explore list when a subsequent page fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more items.'**
  String get explorePageError;

  /// Screen-reader-only accessibility label for the pull-to-refresh gesture on the explore list.
  ///
  /// In en, this message translates to:
  /// **'Refresh user list'**
  String get exploreRefreshLabel;

  /// Screen-reader-only accessibility label for a user list item in the explore list.
  ///
  /// In en, this message translates to:
  /// **'{name}, {email}'**
  String exploreUserItemLabel(String name, String email);

  /// Heading displayed at the top of the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetailTitle;

  /// Label for the display name field on the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get userDetailDisplayName;

  /// Label for the email field on the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userDetailEmail;

  /// Label for the account creation date on the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get userDetailCreatedAt;

  /// Label for the last update timestamp on the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get userDetailUpdatedAt;

  /// Placeholder shown when a date field has no value on the user detail screen.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get userDetailNoDate;

  /// Heading displayed on the biometric lock screen when the app requires authentication to resume.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get biometricLockTitle;

  /// Subtitle text on the biometric lock screen prompting the user to authenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get biometricLockSubtitle;

  /// Localized reason string passed to the platform biometric prompt explaining why authentication is needed.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to unlock the app'**
  String get biometricReason;

  /// Button on the biometric lock screen that re-triggers the biometric authentication prompt after a cancel or failure.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get biometricTryAgainButton;

  /// Button on the biometric lock screen that triggers device passcode entry as a fallback when biometric authentication fails or is cancelled.
  ///
  /// In en, this message translates to:
  /// **'Use Passcode'**
  String get biometricUsePasscodeButton;

  /// Heading displayed on the biometric lock screen fallback state when the user has exceeded the platform biometric retry limit.
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed'**
  String get biometricFailedTitle;

  /// Subtitle on the biometric lock screen fallback state explaining that biometric retries are exhausted and passcode is required.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Please use your device passcode instead.'**
  String get biometricFailedSubtitle;

  /// Title for the biometric authentication toggle in the settings section of the side drawer.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricSettingsTitle;

  /// Subtitle for the biometric authentication toggle explaining what the setting does.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID or fingerprint when opening the app'**
  String get biometricSettingsSubtitle;

  /// Snackbar message shown when the user tries to enable biometric authentication but the device does not support it or has no enrolled biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device.'**
  String get biometricNotAvailable;

  /// Localized reason string passed to the platform biometric prompt when the user is enabling the biometric lock setting.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to enable biometric authentication'**
  String get biometricEnableReason;

  /// Screen-reader-only accessibility label for the biometric toggle when it is turned on.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication: enabled'**
  String get biometricEnabledLabel;

  /// Screen-reader-only accessibility label for the biometric toggle when it is turned off.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication: disabled'**
  String get biometricDisabledLabel;

  /// Social sign-in button on the login screen. Tapping it navigates to the phone number input screen for phone-based authentication.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone'**
  String get phoneSignInButton;

  /// Heading displayed at the top of the phone number input screen.
  ///
  /// In en, this message translates to:
  /// **'Phone Sign-In'**
  String get phoneInputTitle;

  /// Hint text and accessibility label for the search field in the country code picker bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Search country or dial code'**
  String get phoneCountrySearchHint;

  /// Label for the phone number text input field on the phone input screen.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberHint;

  /// Primary submit button on the phone input screen that sends an SMS verification code to the entered phone number.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get phoneSendCodeButton;

  /// Heading displayed at the top of the OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get phoneOtpTitle;

  /// Screen-reader-only accessibility label for each OTP digit input field, announcing its position.
  ///
  /// In en, this message translates to:
  /// **'Digit {position} of {total}'**
  String phoneOtpDigitLabel(int position, int total);

  /// Countdown text shown below the OTP input, indicating when the resend button will become available.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String phoneResendCountdown(String time);

  /// Button that resends the SMS verification code. Disabled during the countdown period.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get phoneResendButton;

  /// Snackbar message shown after an SMS verification code has been successfully resent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent.'**
  String get phoneCodeSentConfirmation;

  /// Fallback verify button on the OTP screen for accessibility. Auto-submit on 6th digit is the primary trigger.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get phoneVerifyButton;

  /// Error message shown when the entered phone number fails format validation or Firebase rejects it as invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number. Please check and try again.'**
  String get phoneInvalidNumberError;

  /// Error message shown when Firebase rate-limits SMS verification requests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait before trying again.'**
  String get phoneTooManyRequestsError;

  /// Error message shown when SMS verification fails due to a network connectivity issue.
  ///
  /// In en, this message translates to:
  /// **'Unable to send verification code. Check your connection.'**
  String get phoneNetworkError;

  /// Error message shown when the user enters an incorrect OTP code.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get phoneInvalidCodeError;

  /// Error message shown when the phone number is already associated with another account.
  ///
  /// In en, this message translates to:
  /// **'An account with this phone number already exists.'**
  String get phoneAccountExistsError;

  /// Accessibility label for a player card in a list.
  ///
  /// In en, this message translates to:
  /// **'{name}, {position} at {club}'**
  String playerCardLabel(String name, String position, String club);

  /// Accessibility label for a market post card.
  ///
  /// In en, this message translates to:
  /// **'{postType}: {details}'**
  String postCardLabel(String postType, String details);

  /// Accessibility label for a conversation card.
  ///
  /// In en, this message translates to:
  /// **'Conversation with {name}: {lastMessage}'**
  String conversationCardLabel(String name, String lastMessage);

  /// Accessibility label for the photo upload field.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get photoUploadLabel;

  /// Accessibility label when a document file is selected.
  ///
  /// In en, this message translates to:
  /// **'Document selected: {fileName}'**
  String documentSelectedLabel(String fileName);

  /// Accessibility label for the remove document button.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get removeDocumentLabel;

  /// Accessibility label for the document upload button.
  ///
  /// In en, this message translates to:
  /// **'Upload {label}'**
  String uploadDocumentLabel(String label);

  /// Accessibility label for a family contact list item.
  ///
  /// In en, this message translates to:
  /// **'{name}, {relationship}'**
  String familyContactLabel(String name, String relationship);

  /// Accessibility label for a document list item.
  ///
  /// In en, this message translates to:
  /// **'{label}, uploaded {date}'**
  String documentItemLabel(String label, String date);

  /// Accessibility label for a note list item.
  ///
  /// In en, this message translates to:
  /// **'Note: {content}'**
  String noteItemLabel(String content);

  /// Accessibility label for edit action buttons.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// Accessibility label for delete action buttons.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// Accessibility label for view action buttons.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewLabel;

  /// Label for retry button in error states.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// Title for the developer component showcase screen.
  ///
  /// In en, this message translates to:
  /// **'Component Showcase'**
  String get showcaseTitle;

  /// Section header for cards in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get showcaseCards;

  /// Section header for form elements in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Form Elements'**
  String get showcaseFormElements;

  /// Section header for buttons in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get showcaseButtons;

  /// Section header for list items in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'List Items'**
  String get showcaseListItems;

  /// Section header for avatars in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get showcaseAvatars;

  /// Section header for badges in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Badges & Tags'**
  String get showcaseBadges;

  /// Section header for empty states in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Empty States'**
  String get showcaseEmptyStates;

  /// Section header for feedback components in the component showcase.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get showcaseFeedback;

  /// Badge label for active client player status.
  ///
  /// In en, this message translates to:
  /// **'Active Client'**
  String get statusActiveClient;

  /// Badge label for prospect player status.
  ///
  /// In en, this message translates to:
  /// **'Prospect'**
  String get statusProspect;

  /// Badge label for former client player status.
  ///
  /// In en, this message translates to:
  /// **'Former Client'**
  String get statusFormerClient;

  /// Badge label for player available post type.
  ///
  /// In en, this message translates to:
  /// **'Player Available'**
  String get postTypePlayerAvailable;

  /// Badge label for need a player post type.
  ///
  /// In en, this message translates to:
  /// **'Need a Player'**
  String get postTypeNeedPlayer;

  /// Title for empty player list state.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get emptyPlayersTitle;

  /// Subtitle for empty player list state.
  ///
  /// In en, this message translates to:
  /// **'Add your first player to get started.'**
  String get emptyPlayersSubtitle;

  /// Generic error message for inline error states.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Please try again.'**
  String get errorLoadingData;

  /// Label for the Dashboard tab in the bottom navigation bar. Navigates to the agent's dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Label for the Players tab in the bottom navigation bar. Navigates to the player list screen.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navPlayers;

  /// Label for the Market tab in the bottom navigation bar. Navigates to the market feed screen.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// Label for the Messages tab in the bottom navigation bar. Navigates to the conversation list screen.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Navigation item in the side drawer. Tapping it opens the current agent's public profile screen.
  ///
  /// In en, this message translates to:
  /// **'View Public Profile'**
  String get drawerViewProfile;

  /// Navigation item in the side drawer. Tapping it opens the profile editing screen.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get drawerEditProfile;

  /// Heading displayed at the top of the account setup screen shown to agents with an incomplete profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get setupTitle;

  /// Heading displayed at the top of the dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Heading displayed at the top of the player list screen.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersTitle;

  /// Heading displayed at the top of the market feed screen.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketTitle;

  /// Heading displayed at the top of the conversation list screen.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Heading displayed at the top of the add player screen.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayerTitle;

  /// Heading displayed at the top of the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get playerProfileTitle;

  /// Heading displayed at the top of the edit player screen.
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get editPlayerTitle;

  /// Heading displayed at the top of the create market post screen.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostTitle;

  /// Heading displayed at the top of the market post detail screen.
  ///
  /// In en, this message translates to:
  /// **'Post Details'**
  String get postDetailTitle;

  /// Heading displayed at the top of the agent's own market posts screen.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPostsTitle;

  /// Heading displayed at the top of an agent's public profile screen.
  ///
  /// In en, this message translates to:
  /// **'Agent Profile'**
  String get agentPublicProfileTitle;

  /// Heading displayed at the top of the conversation chat screen.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Heading displayed at the top of the edit profile screen.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// Screen-reader-only accessibility label for the unread message count badge on the Messages tab.
  ///
  /// In en, this message translates to:
  /// **'{count} unread messages'**
  String unreadMessagesBadgeLabel(int count);

  /// Step counter displayed in the setup wizard header, e.g. '1 / 4'.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String setupStepCounter(int current, int total);

  /// Label for the next-step button in the account setup wizard.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get setupNext;

  /// Label for the back button in the account setup wizard.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get setupBack;

  /// Label for the logout text button on step 1 of the account setup wizard.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get setupLogout;

  /// Label for the final submit button on step 4 of the account setup wizard.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get setupCompleteButton;

  /// Generic error message displayed when saving the agent profile fails during setup.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get setupErrorGeneric;

  /// Title for step 1 of the account setup wizard — profile photo upload.
  ///
  /// In en, this message translates to:
  /// **'Add Your Photo'**
  String get setupStep1Title;

  /// Subtitle for step 1 of the account setup wizard — profile photo upload.
  ///
  /// In en, this message translates to:
  /// **'Help other agents recognise you on the platform.'**
  String get setupStep1Subtitle;

  /// Title for step 2 of the account setup wizard — name and country.
  ///
  /// In en, this message translates to:
  /// **'Your Identity'**
  String get setupStep2Title;

  /// Subtitle for step 2 of the account setup wizard — name and country.
  ///
  /// In en, this message translates to:
  /// **'Tell us who you are and where you operate.'**
  String get setupStep2Subtitle;

  /// Label for the full name text field in setup step 2.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get setupFullName;

  /// Label for the country dropdown in setup step 2.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get setupCountry;

  /// Title for step 3 of the account setup wizard — FIFA licensing.
  ///
  /// In en, this message translates to:
  /// **'FIFA Status'**
  String get setupStep3Title;

  /// Subtitle for step 3 of the account setup wizard — FIFA licensing.
  ///
  /// In en, this message translates to:
  /// **'Let other agents know your licensing status.'**
  String get setupStep3Subtitle;

  /// Label for the FIFA registration toggle in setup step 3.
  ///
  /// In en, this message translates to:
  /// **'I am a FIFA Licensed Agent'**
  String get setupFifaRegistered;

  /// Label for the FIFA licence number text field in setup step 3.
  ///
  /// In en, this message translates to:
  /// **'FIFA Licence Number'**
  String get setupLicenceNumber;

  /// Title for step 4 of the account setup wizard — optional profile details.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get setupStep4Title;

  /// Subtitle for step 4 of the account setup wizard — optional profile details.
  ///
  /// In en, this message translates to:
  /// **'Round out your public profile.'**
  String get setupStep4Subtitle;

  /// Info banner text on step 4 of setup explaining that the fields are optional.
  ///
  /// In en, this message translates to:
  /// **'These details are optional. You can always add or update them later from your profile.'**
  String get setupOptionalNotice;

  /// Label for the bio text field in setup step 4.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get setupBio;

  /// Label for the agency name text field in setup step 4.
  ///
  /// In en, this message translates to:
  /// **'Agency Name'**
  String get setupAgencyName;

  /// Label for the years of experience dropdown in setup step 4.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get setupYearsOfExperience;

  /// Label for the phone number text field in setup step 4.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get setupPhoneNumber;

  /// Label for the WhatsApp toggle in setup step 4.
  ///
  /// In en, this message translates to:
  /// **'This number is on WhatsApp'**
  String get setupIsPhoneOnWhatsApp;

  /// Singular year label for the years of experience dropdown.
  ///
  /// In en, this message translates to:
  /// **'{count} year'**
  String setupYearsSingular(int count);

  /// Plural years label for the years of experience dropdown.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String setupYearsPlural(int count);

  /// Label for the save button on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Save Player'**
  String get savePlayer;

  /// Title for the discard confirmation dialog when leaving the add player form with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChangesTitle;

  /// Body text for the discard confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get discardChangesMessage;

  /// Destructive button label in the discard confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// Button label in the discard confirmation dialog to dismiss and continue editing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditingButton;

  /// Section header for the identity section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get sectionIdentity;

  /// Section header for the football details section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Football Details'**
  String get sectionFootballDetails;

  /// Section header for the representation section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Representation'**
  String get sectionRepresentation;

  /// Section header for the contract and financial section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Contract & Financial'**
  String get sectionContractFinancial;

  /// Section header for the contact section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get sectionContact;

  /// Section header for the status section of the add player form.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sectionStatus;

  /// Label for the full name field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// Label for the date of birth field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get fieldDateOfBirth;

  /// Label for the nationality dropdown on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get fieldNationality;

  /// Label for the optional second nationality field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Second Nationality'**
  String get fieldSecondNationality;

  /// Label for the country of residence dropdown on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Country of Residence'**
  String get fieldCountryOfResidence;

  /// Label for the preferred position dropdown on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Preferred Position'**
  String get fieldPreferredPosition;

  /// Label for the other positions multi-select chips on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Other Positions'**
  String get fieldOtherPositions;

  /// Label for the preferred foot dropdown on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Preferred Foot'**
  String get fieldPreferredFoot;

  /// Label for the current club field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Current Club'**
  String get fieldCurrentClub;

  /// Label for the league country field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'League Country'**
  String get fieldLeagueCountry;

  /// Label for the estimated market value field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Estimated Market Value'**
  String get fieldMarketValue;

  /// Label for the Transfermarkt URL field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Transfermarkt URL'**
  String get fieldTransfermarktUrl;

  /// Label for the agent contract start date field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Agent Contract Start'**
  String get fieldAgentContractStart;

  /// Label for the agent contract expiry date field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Agent Contract Expiry'**
  String get fieldAgentContractExpiry;

  /// Label for the club contract expiry date field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Club Contract Expiry'**
  String get fieldClubContractExpiry;

  /// Label for the salary field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get fieldSalary;

  /// Label for the phone number field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get fieldPhoneNumber;

  /// Label for the email field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// Label for the WhatsApp number field on the add player form.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get fieldWhatsAppNumber;

  /// Label for the client status dropdown on the add player form.
  ///
  /// In en, this message translates to:
  /// **'Client Status'**
  String get fieldClientStatus;

  /// Display label for the Goalkeeper position.
  ///
  /// In en, this message translates to:
  /// **'GK'**
  String get positionGK;

  /// Display label for the Centre-Back position.
  ///
  /// In en, this message translates to:
  /// **'CB'**
  String get positionCB;

  /// Display label for the Left-Back position.
  ///
  /// In en, this message translates to:
  /// **'LB'**
  String get positionLB;

  /// Display label for the Right-Back position.
  ///
  /// In en, this message translates to:
  /// **'RB'**
  String get positionRB;

  /// Display label for the Central Defensive Midfielder position.
  ///
  /// In en, this message translates to:
  /// **'CDM'**
  String get positionCDM;

  /// Display label for the Central Midfielder position.
  ///
  /// In en, this message translates to:
  /// **'CM'**
  String get positionCM;

  /// Display label for the Central Attacking Midfielder position.
  ///
  /// In en, this message translates to:
  /// **'CAM'**
  String get positionCAM;

  /// Display label for the Left Winger position.
  ///
  /// In en, this message translates to:
  /// **'LW'**
  String get positionLW;

  /// Display label for the Right Winger position.
  ///
  /// In en, this message translates to:
  /// **'RW'**
  String get positionRW;

  /// Display label for the Striker position.
  ///
  /// In en, this message translates to:
  /// **'ST'**
  String get positionST;

  /// Display label for left preferred foot.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get footLeft;

  /// Display label for right preferred foot.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get footRight;

  /// Display label for both-footed preference.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get footBoth;

  /// Validation error shown when a required field is left empty.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// Validation error shown when the email format is invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// Validation error shown when the full name is less than 2 characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameTooShort;

  /// Validation error shown when the date of birth indicates the player is under 15 years old.
  ///
  /// In en, this message translates to:
  /// **'Player must be at least 15 years old'**
  String get validationPlayerTooYoung;

  /// Error message shown in a snackbar when saving a player fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save player. Please try again.'**
  String get errorSavePlayer;

  /// Tooltip for the edit button in the player profile app bar.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get playerProfileEdit;

  /// Tooltip for the delete button in the player profile app bar.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playerProfileDelete;

  /// Title of the delete player confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Player'**
  String get playerDeleteTitle;

  /// Body text of the delete player confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this player? This action cannot be undone.'**
  String get playerDeleteConfirmation;

  /// Confirm button label in the delete player confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playerDeleteConfirm;

  /// Cancel button label in the delete player confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get playerDeleteCancel;

  /// Snackbar message shown after a player is successfully deleted.
  ///
  /// In en, this message translates to:
  /// **'Player deleted successfully'**
  String get playerDeleteSuccess;

  /// Snackbar message shown when player deletion fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete player. Please try again.'**
  String get playerDeleteError;

  /// Section header for the identity section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get playerSectionIdentity;

  /// Section header for the football details section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Football Details'**
  String get playerSectionFootball;

  /// Section header for the representation section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Representation'**
  String get playerSectionRepresentation;

  /// Section header for the contract and financial section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Contract & Financial'**
  String get playerSectionContract;

  /// Section header for the contact section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get playerSectionContact;

  /// Section header for the family contacts section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Family Contacts'**
  String get playerSectionFamily;

  /// Section header for the documents section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get playerSectionDocuments;

  /// Section header for the notes section on the player profile screen.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get playerSectionNotes;

  /// Displays the player's age calculated from date of birth.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String playerAgeYears(int age);

  /// Warning label shown next to contract dates expiring within 90 days.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get playerContractExpiringSoon;

  /// Empty state message for the family contacts section.
  ///
  /// In en, this message translates to:
  /// **'No family contacts added'**
  String get playerNoFamilyContacts;

  /// Empty state message for the documents section.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded'**
  String get playerNoDocuments;

  /// Empty state message for the notes section.
  ///
  /// In en, this message translates to:
  /// **'No notes added'**
  String get playerNoNotes;

  /// Message shown when a player document does not exist or has been deleted.
  ///
  /// In en, this message translates to:
  /// **'Player not found'**
  String get playerNotFound;

  /// Accessibility label for the Transfermarkt link on the player profile.
  ///
  /// In en, this message translates to:
  /// **'View on Transfermarkt'**
  String get playerProfileOpenTransfermarkt;

  /// Accessibility label for tapping a phone number to open the dialer.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get playerProfileCallNumber;

  /// Accessibility label for tapping an email address to open the mail client.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get playerProfileSendEmail;

  /// Accessibility label for tapping a WhatsApp number to open WhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get playerProfileWhatsApp;

  /// Body text for the player not found empty state.
  ///
  /// In en, this message translates to:
  /// **'This player may have been removed or the link is invalid.'**
  String get playerNotFoundBody;

  /// Label for the back button on the player not found state.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get playerProfileBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
