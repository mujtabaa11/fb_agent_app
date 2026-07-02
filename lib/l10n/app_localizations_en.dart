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
  String dashboardGreetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String dashboardGreetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String dashboardGreetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get statsTotalPlayers => 'Total Players';

  @override
  String get statsActiveClients => 'Active Clients';

  @override
  String get statsProspects => 'Prospects';

  @override
  String get statsMarketPosts => 'Market Posts';

  @override
  String get statsComingSoon => 'Coming Soon';

  @override
  String get sectionUpcomingExpiries => 'Upcoming Expiries';

  @override
  String get emptyExpiriesTitle => 'No Upcoming Expiries';

  @override
  String get emptyExpiriesMessage =>
      'No contracts expiring in the next 90 days.';

  @override
  String get contractTypeRepresentationAgreement =>
      'Representation Agreement (RA)';

  @override
  String get contractTypeClubContract => 'Club Contract';

  @override
  String expiryDaysRemaining(int count) {
    return '$count days';
  }

  @override
  String get errorLoadingDashboard =>
      'Failed to load dashboard. Please try again.';

  @override
  String get playersTitle => 'Players';

  @override
  String get marketTitle => 'Market';

  @override
  String get marketFilterTitle => 'Filter Posts';

  @override
  String get marketFilterButtonLabel => 'Filter posts';

  @override
  String marketFilterActiveCount(int count) {
    return '$count active filters';
  }

  @override
  String get marketFilterPostType => 'Post Type';

  @override
  String get marketFilterPosition => 'Position';

  @override
  String get marketFilterNationality => 'Nationality';

  @override
  String get marketFilterMaxAge => 'Max Age';

  @override
  String get marketFilterMaxValue => 'Max Market Value';

  @override
  String get marketFilterApply => 'Apply';

  @override
  String get marketFilterClearAll => 'Clear All';

  @override
  String get marketFilterAny => 'Any';

  @override
  String marketFilterMaxAgeOption(int age) {
    return 'U$age';
  }

  @override
  String get marketEmptyTitle => 'No Posts Yet';

  @override
  String get marketEmptySubtitle =>
      'Check back soon — agents are posting opportunities every day.';

  @override
  String get marketEmptyFilterTitle => 'No Matching Posts';

  @override
  String get marketEmptyFilterSubtitle =>
      'No posts match your current filters.';

  @override
  String get marketClearFilters => 'Clear Filters';

  @override
  String marketExpiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String marketPostedAgo(String duration) {
    return '$duration ago';
  }

  @override
  String marketDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String marketDurationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String marketDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get marketDurationJustNow => 'Just now';

  @override
  String marketPlayerAgeDetail(
      String position, String nationality, String age) {
    return '$position · $nationality · $age';
  }

  @override
  String marketNeededPlayerDetail(
      String position, String nationality, String ageRange) {
    return '$position · $nationality · $ageRange';
  }

  @override
  String marketAgeYears(int age) {
    return '$age yrs';
  }

  @override
  String marketAgeRange(int min, int max) {
    return '$min–$max yrs';
  }

  @override
  String get marketPostTapLabel => 'View post details';

  @override
  String marketAgentNameTapLabel(String name) {
    return 'View $name\'s profile';
  }

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
  String get postTypePlayerAvailableSubtitle =>
      'Market a player you represent to other agents';

  @override
  String get postTypeNeedAPlayerSubtitle =>
      'Broadcast a position or profile you are looking to fill';

  @override
  String get createPlayerAvailableTitle => 'Player Available';

  @override
  String get linkPlayerPrompt => 'Link a player from your roster';

  @override
  String get linkPlayerSearch => 'Search players';

  @override
  String get removeLinkedPlayerLabel => 'Remove linked player';

  @override
  String get postAnonymousLabel => 'Post Anonymously';

  @override
  String get postAnonymousSublabel =>
      'Hide player identity until you make contact';

  @override
  String get postDescriptionLabel => 'Description';

  @override
  String get postDescriptionHint => 'Describe the player or the opportunity...';

  @override
  String get postExpiryLabel => 'Post Expires On';

  @override
  String get postExternalLinksLabel => 'External Links';

  @override
  String get postExternalLinksSublabel => 'Add highlight reels or match videos';

  @override
  String get postLinkUrl => 'URL';

  @override
  String get postLinkLabel => 'Label (optional)';

  @override
  String get postAddLink => '+ Add Link';

  @override
  String get savePost => 'Publish Post';

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

  @override
  String setupStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get setupNext => 'Next';

  @override
  String get setupBack => 'Back';

  @override
  String get setupLogout => 'Log Out';

  @override
  String get setupCompleteButton => 'Complete Setup';

  @override
  String get setupErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get setupStep1Title => 'Add Your Photo';

  @override
  String get setupStep1Subtitle =>
      'Help other agents recognise you on the platform.';

  @override
  String get setupStep2Title => 'Your Identity';

  @override
  String get setupStep2Subtitle => 'Tell us who you are and where you operate.';

  @override
  String get setupFullName => 'Full Name';

  @override
  String get setupCountry => 'Country';

  @override
  String get setupStep3Title => 'FIFA Status';

  @override
  String get setupStep3Subtitle =>
      'Let other agents know your licensing status.';

  @override
  String get setupFifaRegistered => 'I am a FIFA Licensed Agent';

  @override
  String get setupLicenceNumber => 'FIFA Licence Number';

  @override
  String get setupStep4Title => 'Additional Details';

  @override
  String get setupStep4Subtitle => 'Round out your public profile.';

  @override
  String get setupOptionalNotice =>
      'These details are optional. You can always add or update them later from your profile.';

  @override
  String get setupBio => 'Bio';

  @override
  String get setupAgencyName => 'Agency Name';

  @override
  String get setupYearsOfExperience => 'Years of Experience';

  @override
  String get setupPhoneNumber => 'Phone Number';

  @override
  String get setupIsPhoneOnWhatsApp => 'This number is on WhatsApp';

  @override
  String setupYearsSingular(int count) {
    return '$count year';
  }

  @override
  String setupYearsPlural(int count) {
    return '$count years';
  }

  @override
  String get savePlayer => 'Save Player';

  @override
  String get discardChangesTitle => 'Discard Changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get discardButton => 'Discard';

  @override
  String get keepEditingButton => 'Keep Editing';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get sectionFootballDetails => 'Football Details';

  @override
  String get sectionRepresentation => 'Representation';

  @override
  String get sectionContractFinancial => 'Contract & Financial';

  @override
  String get sectionContact => 'Contact';

  @override
  String get sectionStatus => 'Status';

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get fieldDateOfBirth => 'Date of Birth';

  @override
  String get fieldNationality => 'Nationality';

  @override
  String get fieldSecondNationality => 'Second Nationality';

  @override
  String get fieldCountryOfResidence => 'Country of Residence';

  @override
  String get fieldPreferredPosition => 'Preferred Position';

  @override
  String get fieldOtherPositions => 'Other Positions';

  @override
  String get fieldPreferredFoot => 'Preferred Foot';

  @override
  String get fieldCurrentClub => 'Current Club';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldLeagueCountry => 'League Country';

  @override
  String get fieldMarketValue => 'Estimated Market Value';

  @override
  String get currencyEur => 'EUR';

  @override
  String get fieldTransfermarktUrl => 'Transfermarkt URL';

  @override
  String get fieldRepresentationAgreementStart =>
      'Representation Agreement Start';

  @override
  String get fieldRepresentationAgreementExpiry =>
      'Representation Agreement Expiry';

  @override
  String get fieldClubContractExpiry => 'Club Contract Expiry';

  @override
  String get fieldSalary => 'Salary';

  @override
  String get fieldPhoneNumber => 'Phone Number';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldWhatsAppNumber => 'WhatsApp Number';

  @override
  String get fieldClientStatus => 'Client Status';

  @override
  String get positionGK => 'GK';

  @override
  String get positionCB => 'CB';

  @override
  String get positionLB => 'LB';

  @override
  String get positionRB => 'RB';

  @override
  String get positionCDM => 'CDM';

  @override
  String get positionCM => 'CM';

  @override
  String get positionCAM => 'CAM';

  @override
  String get positionLW => 'LW';

  @override
  String get positionRW => 'RW';

  @override
  String get positionST => 'ST';

  @override
  String get footLeft => 'Left';

  @override
  String get footRight => 'Right';

  @override
  String get footBoth => 'Both';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationNameTooShort => 'Name must be at least 2 characters';

  @override
  String get validationPlayerTooYoung => 'Player must be at least 15 years old';

  @override
  String get errorSavePlayer => 'Failed to save player. Please try again.';

  @override
  String get playerProfileEdit => 'Edit';

  @override
  String get playerProfileDelete => 'Delete';

  @override
  String get playerDeleteTitle => 'Delete Player';

  @override
  String get playerDeleteConfirmation =>
      'Are you sure you want to delete this player? This action cannot be undone.';

  @override
  String get playerDeleteConfirm => 'Delete';

  @override
  String get playerDeleteCancel => 'Cancel';

  @override
  String get playerDeleteSuccess => 'Player deleted successfully';

  @override
  String get playerDeleteError => 'Failed to delete player. Please try again.';

  @override
  String get playerSectionIdentity => 'Identity';

  @override
  String get playerSectionFootball => 'Football Details';

  @override
  String get playerSectionRepresentation => 'Representation';

  @override
  String get playerSectionContract => 'Contract & Financial';

  @override
  String get playerSectionContact => 'Contact';

  @override
  String get playerSectionFamily => 'Family Contacts';

  @override
  String get playerSectionDocuments => 'Documents';

  @override
  String get playerSectionNotes => 'Notes';

  @override
  String playerAgeYears(int age) {
    return '$age years old';
  }

  @override
  String get playerContractExpiringSoon => 'Expiring soon';

  @override
  String get playerNoFamilyContacts => 'No family contacts added';

  @override
  String get playerNoDocuments => 'No documents uploaded';

  @override
  String get playerNoNotes => 'No notes added';

  @override
  String get playerNotFound => 'Player not found';

  @override
  String get playerProfileOpenTransfermarkt => 'View on Transfermarkt';

  @override
  String get playerProfileCallNumber => 'Call';

  @override
  String get playerProfileSendEmail => 'Email';

  @override
  String get playerProfileWhatsApp => 'WhatsApp';

  @override
  String get playerNotFoundBody =>
      'This player may have been removed or the link is invalid.';

  @override
  String get playerProfileBack => 'Back';

  @override
  String get editPlayerSave => 'Save Changes';

  @override
  String get editPlayerDiscardTitle => 'Discard Changes?';

  @override
  String get editPlayerDiscardMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get editPlayerDiscardConfirm => 'Discard';

  @override
  String get editPlayerDiscardCancel => 'Keep Editing';

  @override
  String get editPlayerSuccess => 'Player updated successfully';

  @override
  String get editPlayerError => 'Failed to update player. Please try again.';

  @override
  String get documentsSection => 'Documents';

  @override
  String get addDocument => 'Add Document';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get addDocumentTitle => 'Add Document';

  @override
  String get documentLabelField => 'Document Type';

  @override
  String get documentCustomLabelField => 'Specify Document Type';

  @override
  String get documentCustomLabelHint => 'e.g. UEFA Licence, NDA';

  @override
  String get documentFileField => 'Select File';

  @override
  String get emptyDocumentsTitle => 'No Documents Yet';

  @override
  String get emptyDocumentsMessage =>
      'Upload contracts, passports, and certificates to keep everything in one place.';

  @override
  String get deleteDocumentTitle => 'Delete Document?';

  @override
  String get deleteDocumentMessage => 'This action cannot be undone.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get documentUploadError =>
      'Failed to upload document. Please try again.';

  @override
  String get documentDeleteError =>
      'Failed to delete document. Please try again.';

  @override
  String get documentFileTooLarge =>
      'PDF files must be under 10MB. Please compress the file and try again.';

  @override
  String get documentFileTypeInvalid =>
      'Only PDF, JPG, and PNG files are supported.';

  @override
  String get notesSection => 'Notes';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get addNoteTitle => 'Add Note';

  @override
  String get editNoteTitle => 'Edit Note';

  @override
  String get saveNote => 'Save Note';

  @override
  String get updateNote => 'Update Note';

  @override
  String get noteContentField => 'Note';

  @override
  String get noteContentHint => 'Write your note here...';

  @override
  String get emptyNotesTitle => 'No Notes Yet';

  @override
  String get emptyNotesMessage =>
      'Add private notes, observations, and reminders for this player.';

  @override
  String get deleteNoteTitle => 'Delete Note?';

  @override
  String get deleteNoteMessage => 'This action cannot be undone.';

  @override
  String get noteEditedLabel => 'Edited';

  @override
  String get noteAddError => 'Failed to save note. Please try again.';

  @override
  String get noteUpdateError => 'Failed to update note. Please try again.';

  @override
  String get noteDeleteError => 'Failed to delete note. Please try again.';

  @override
  String get validationNoteEmpty => 'Note content cannot be empty.';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get addContactTitle => 'Add Contact';

  @override
  String get editContactTitle => 'Edit Contact';

  @override
  String get saveContact => 'Save Contact';

  @override
  String get updateContact => 'Update Contact';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldRelationship => 'Relationship';

  @override
  String get fieldRelationshipHint => 'e.g. Father, Wife, Brother';

  @override
  String get deleteContactTitle => 'Delete Contact?';

  @override
  String get deleteContactMessage => 'This action cannot be undone.';

  @override
  String get contactAddError => 'Failed to save contact. Please try again.';

  @override
  String get contactUpdateError =>
      'Failed to update contact. Please try again.';

  @override
  String get contactDeleteError =>
      'Failed to delete contact. Please try again.';

  @override
  String get labelPassport => 'Passport';

  @override
  String get labelContract => 'Contract';

  @override
  String get labelRepresentationAgreement => 'Representation Agreement (RA)';

  @override
  String get labelMedicalCertificate => 'Medical Certificate';

  @override
  String get labelWorkPermit => 'Work Permit';

  @override
  String get labelVisa => 'Visa';

  @override
  String get labelTransferAgreement => 'Transfer Agreement';

  @override
  String get labelReleaseLetter => 'Release Letter';

  @override
  String get labelInsurance => 'Insurance';

  @override
  String get labelOther => 'Other';
}
