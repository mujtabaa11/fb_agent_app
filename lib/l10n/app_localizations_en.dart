// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Football Agent Mate';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retryButton => 'Try Again';

  @override
  String get noInternetError => 'No internet connection. Please try again.';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get loginButton => 'Log In';

  @override
  String get forgotPasswordButton => 'Forgot Password?';

  @override
  String get googleSignInButton => 'Continue with Google';

  @override
  String get appleSignInButton => 'Continue with Apple';

  @override
  String get passwordResetTitle => 'Reset Password';

  @override
  String get passwordResetButton => 'Send Reset Email';

  @override
  String get passwordResetConfirmation => 'Check your email for a reset link.';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navProfile => 'Profile';

  @override
  String get logoutButton => 'Log Out';

  @override
  String get emailAlreadyInUseError =>
      'An account with this email already exists.';

  @override
  String get wrongPasswordError => 'Incorrect email or password.';

  @override
  String get weakPasswordError =>
      'Password must be at least 8 characters, include 1 uppercase letter and 1 number.';

  @override
  String get tooManyRequestsError =>
      'Too many requests. Please wait before trying again.';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateBody => 'Check back later.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get googleAccountLinkError =>
      'An account with this email already exists. Please log in with your email and password.';

  @override
  String get appleAccountLinkError =>
      'An account with this email already exists. Please log in with your email and password.';

  @override
  String get loadingAppLabel => 'Loading app, please wait.';

  @override
  String get themeModeSystem => 'Auto';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeSwitcherLabel => 'Theme switcher';

  @override
  String get drawerTitle => 'Menu';

  @override
  String get settingsSection => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get userAvatarLabel => 'User avatar';

  @override
  String get openDrawerLabel => 'Open navigation drawer';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String get errorBoundaryFallback => 'Something went wrong.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadErrorTitle => 'Could not load profile';

  @override
  String get profileLoadErrorBody =>
      'Your profile could not be loaded. Please try again later.';

  @override
  String get profileDisplayNameLabel => 'Display Name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileAvatarLabel => 'Profile picture';

  @override
  String get uploadPhotoButton => 'Upload Photo';

  @override
  String get avatarUploadProgress => 'Uploading photo…';

  @override
  String get avatarImageTooLargeError =>
      'The selected image is too large. Please choose a smaller photo.';

  @override
  String get photoLibraryPermissionDenied =>
      'Photo library access was denied. Please grant permission in Settings.';

  @override
  String get avatarUploadErrorTitle => 'Upload failed';

  @override
  String get avatarUploadErrorBody =>
      'Your photo could not be uploaded. Please try again.';

  @override
  String get accountLinkTitle => 'Link Your Account';

  @override
  String accountLinkBody(String email) {
    return 'An account already exists with $email. Please sign in with your original method to link your accounts.';
  }

  @override
  String get accountLinkPasswordLabel => 'Password';

  @override
  String get accountLinkSignInButton => 'Sign In & Link';

  @override
  String get accountLinkOrDivider => 'or sign in with';

  @override
  String get accountLinkSuccessMessage => 'Accounts linked successfully.';

  @override
  String get accountLinkFailedMessage =>
      'Unable to link accounts. Please try again.';

  @override
  String get accountLinkWrongPassword =>
      'Incorrect password. Please try again.';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deleteAccountConfirmTitle => 'Delete Your Account?';

  @override
  String get deleteAccountConfirmBody =>
      'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be deleted.';

  @override
  String get deleteAccountConfirmCancel => 'Cancel';

  @override
  String get deleteAccountConfirmDelete => 'Delete Account';

  @override
  String get deleteAccountReauthTitle => 'Verify Your Identity';

  @override
  String get deleteAccountReauthBody =>
      'For security, please verify your identity before deleting your account.';

  @override
  String get deleteAccountReauthPasswordButton => 'Verify & Delete';

  @override
  String get deleteAccountReauthGoogleButton => 'Re-authenticate with Google';

  @override
  String get deleteAccountReauthAppleButton => 'Re-authenticate with Apple';

  @override
  String get deleteAccountSuccessMessage => 'Your account has been deleted.';

  @override
  String get deleteAccountRequiresRecentLogin =>
      'Please sign in again before deleting your account.';

  @override
  String get deleteAccountErrorGeneric =>
      'Unable to delete your account. Please try again later.';

  @override
  String get deleteAccountWrongPassword =>
      'Incorrect password. Please try again.';

  @override
  String get deleteAccountDeletingProgress => 'Deleting your account…';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. Please check your inbox and tap the link to continue.';
  }

  @override
  String get verifyEmailResendButton => 'Resend Email';

  @override
  String verifyEmailResendCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifyEmailContinueButton => 'I\'ve Verified My Email';

  @override
  String get verifyEmailSignOutButton => 'Sign Out';

  @override
  String get verifyEmailSentConfirmation => 'Verification email sent.';

  @override
  String get verifyEmailNotYetVerified =>
      'Email not yet verified. Please check your inbox.';

  @override
  String get verifyEmailSendFailed =>
      'Could not send verification email. Please try again.';

  @override
  String get verifyEmailCheckLabel => 'Checking verification status';

  @override
  String get onboardingSlide1Title => 'Your Players. Your Network. One App.';

  @override
  String get onboardingSlide1Body =>
      'Agent Mate is built for football agents who mean business.';

  @override
  String get onboardingSlide2Title => 'Manage Every Client in One Place';

  @override
  String get onboardingSlide2Body =>
      'Register your players, track contracts, store documents, and never miss an important date.';

  @override
  String get onboardingSlide3Title => 'Connect With Agents Worldwide';

  @override
  String get onboardingSlide3Body =>
      'Post opportunities, discover players, and close deals — all inside Agent Mate.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNextButton => 'Next';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get offlineBannerMessage =>
      'You are offline. Some features may be unavailable.';

  @override
  String get offlineBannerSemanticsLabel =>
      'You are currently offline. Some features may be unavailable.';

  @override
  String get offlineSaveMessage =>
      'Changes saved offline — will sync when connected.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreLoadError => 'Could not load users';

  @override
  String get exploreLoadErrorBody =>
      'Something went wrong while loading the list. Please try again.';

  @override
  String get exploreEmptyTitle => 'No users yet';

  @override
  String get exploreEmptyBody =>
      'There are no user profiles to show right now.';

  @override
  String get exploreNoMoreResults => 'No more results';

  @override
  String get explorePageError => 'Failed to load more items.';

  @override
  String get exploreRefreshLabel => 'Refresh user list';

  @override
  String exploreUserItemLabel(String name, String email) {
    return '$name, $email';
  }

  @override
  String get userDetailTitle => 'User Details';

  @override
  String get userDetailDisplayName => 'Display Name';

  @override
  String get userDetailEmail => 'Email';

  @override
  String get userDetailCreatedAt => 'Joined';

  @override
  String get userDetailUpdatedAt => 'Last Updated';

  @override
  String get userDetailNoDate => 'N/A';

  @override
  String get biometricLockTitle => 'App Locked';

  @override
  String get biometricLockSubtitle => 'Authenticate to continue';

  @override
  String get biometricReason => 'Please authenticate to unlock the app';

  @override
  String get biometricTryAgainButton => 'Try Again';

  @override
  String get biometricUsePasscodeButton => 'Use Passcode';

  @override
  String get biometricFailedTitle => 'Authentication Failed';

  @override
  String get biometricFailedSubtitle =>
      'Biometric authentication failed. Please use your device passcode instead.';

  @override
  String get biometricSettingsTitle => 'Biometric Authentication';

  @override
  String get biometricSettingsSubtitle =>
      'Require Face ID or fingerprint when opening the app';

  @override
  String get biometricNotAvailable =>
      'Biometric authentication is not available on this device.';

  @override
  String get biometricEnableReason =>
      'Verify your identity to enable biometric authentication';

  @override
  String get biometricEnabledLabel => 'Biometric authentication: enabled';

  @override
  String get biometricDisabledLabel => 'Biometric authentication: disabled';

  @override
  String get phoneSignInButton => 'Continue with Phone';

  @override
  String get phoneInputTitle => 'Phone Sign-In';

  @override
  String get phoneCountrySearchHint => 'Search country or dial code';

  @override
  String get phoneNumberHint => 'Phone number';

  @override
  String get phoneSendCodeButton => 'Send Verification Code';

  @override
  String get phoneOtpTitle => 'Verify Your Phone';

  @override
  String phoneOtpDigitLabel(int position, int total) {
    return 'Digit $position of $total';
  }

  @override
  String phoneResendCountdown(String time) {
    return 'Resend code in $time';
  }

  @override
  String get phoneResendButton => 'Resend Code';

  @override
  String get phoneCodeSentConfirmation => 'Verification code sent.';

  @override
  String get phoneVerifyButton => 'Verify';

  @override
  String get phoneInvalidNumberError =>
      'Invalid phone number. Please check and try again.';

  @override
  String get phoneTooManyRequestsError =>
      'Too many requests. Please wait before trying again.';

  @override
  String get phoneNetworkError =>
      'Unable to send verification code. Check your connection.';

  @override
  String get phoneInvalidCodeError =>
      'Invalid verification code. Please try again.';

  @override
  String get phoneAccountExistsError =>
      'An account with this phone number already exists.';

  @override
  String playerCardLabel(String name, String position, String club) {
    return '$name, $position at $club';
  }

  @override
  String postCardLabel(String postType, String details) {
    return '$postType: $details';
  }

  @override
  String conversationCardLabel(String name, String lastMessage) {
    return 'Conversation with $name: $lastMessage';
  }

  @override
  String get photoUploadLabel => 'Upload photo';

  @override
  String documentSelectedLabel(String fileName) {
    return 'Document selected: $fileName';
  }

  @override
  String get removeDocumentLabel => 'Remove document';

  @override
  String uploadDocumentLabel(String label) {
    return 'Upload $label';
  }

  @override
  String familyContactLabel(String name, String relationship) {
    return '$name, $relationship';
  }

  @override
  String documentItemLabel(String label, String date) {
    return '$label, uploaded $date';
  }

  @override
  String noteItemLabel(String content) {
    return 'Note: $content';
  }

  @override
  String get editLabel => 'Edit';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get viewLabel => 'View';

  @override
  String get retryLabel => 'Retry';

  @override
  String get showcaseTitle => 'Component Showcase';

  @override
  String get showcaseCards => 'Cards';

  @override
  String get showcaseFormElements => 'Form Elements';

  @override
  String get showcaseButtons => 'Buttons';

  @override
  String get showcaseListItems => 'List Items';

  @override
  String get showcaseAvatars => 'Avatars';

  @override
  String get showcaseBadges => 'Badges & Tags';

  @override
  String get showcaseEmptyStates => 'Empty States';

  @override
  String get showcaseFeedback => 'Feedback';

  @override
  String get statusActiveClient => 'Active Client';

  @override
  String get statusProspect => 'Prospect';

  @override
  String get statusFormerClient => 'Former Client';

  @override
  String get postTypePlayerAvailable => 'Player Available';

  @override
  String get postTypeNeedPlayer => 'Need a Player';

  @override
  String get emptyPlayersTitle => 'No players yet';

  @override
  String get emptyPlayersSubtitle => 'Add your first player to get started.';

  @override
  String get errorLoadingData => 'Failed to load data. Please try again.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPlayers => 'Players';

  @override
  String get navMarket => 'Market';

  @override
  String get navMessages => 'Messages';

  @override
  String get drawerViewProfile => 'View Public Profile';

  @override
  String get drawerEditProfile => 'Edit Profile';

  @override
  String get setupTitle => 'Complete Your Profile';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get playersTitle => 'Players';

  @override
  String get marketTitle => 'Market';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get addPlayerTitle => 'Add Player';

  @override
  String get playerProfileTitle => 'Player Profile';

  @override
  String get editPlayerTitle => 'Edit Player';

  @override
  String get createPostTitle => 'Create Post';

  @override
  String get postDetailTitle => 'Post Details';

  @override
  String get myPostsTitle => 'My Posts';

  @override
  String get agentPublicProfileTitle => 'Agent Profile';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String unreadMessagesBadgeLabel(int count) {
    return '$count unread messages';
  }
}
