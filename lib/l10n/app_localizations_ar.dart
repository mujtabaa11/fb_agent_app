// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فوتبول أجنت ميت';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get retryButton => 'حاول مجدداً';

  @override
  String get noInternetError =>
      'لا يوجد اتصال بالإنترنت. يرجى المحاولة مرة أخرى.';

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
  String get languageLabel => 'Language';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get deviceDefaultLanguage => 'Device Default';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileLoadErrorTitle => 'تعذّر تحميل الملف الشخصي';

  @override
  String get profileLoadErrorBody =>
      'تعذّر تحميل ملفك الشخصي. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get profileDisplayNameLabel => 'الاسم المعروض';

  @override
  String get profileEmailLabel => 'البريد الإلكتروني';

  @override
  String get profileAvatarLabel => 'صورة الملف الشخصي';

  @override
  String get uploadPhotoButton => 'رفع صورة';

  @override
  String get avatarUploadProgress => 'جارٍ رفع الصورة…';

  @override
  String get avatarImageTooLargeError =>
      'الصورة المختارة كبيرة جداً. يرجى اختيار صورة أصغر.';

  @override
  String get photoLibraryPermissionDenied =>
      'تم رفض الوصول إلى مكتبة الصور. يرجى منح الإذن من الإعدادات.';

  @override
  String get avatarUploadErrorTitle => 'فشل الرفع';

  @override
  String get avatarUploadErrorBody =>
      'تعذّر رفع صورتك. يرجى المحاولة مرة أخرى.';

  @override
  String get accountLinkTitle => 'ربط حسابك';

  @override
  String accountLinkBody(String email) {
    return 'يوجد حساب مسجل بالفعل بالبريد $email. يرجى تسجيل الدخول بالطريقة الأصلية لربط حساباتك.';
  }

  @override
  String get accountLinkPasswordLabel => 'كلمة المرور';

  @override
  String get accountLinkSignInButton => 'تسجيل الدخول والربط';

  @override
  String get accountLinkOrDivider => 'أو سجّل الدخول باستخدام';

  @override
  String get accountLinkSuccessMessage => 'تم ربط الحسابات بنجاح.';

  @override
  String get accountLinkFailedMessage =>
      'تعذّر ربط الحسابات. يرجى المحاولة مرة أخرى.';

  @override
  String get accountLinkWrongPassword =>
      'كلمة مرور غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteAccountButton => 'حذف الحساب';

  @override
  String get deleteAccountConfirmTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountConfirmBody =>
      'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء دائم ولا يمكن التراجع عنه. سيتم حذف جميع بياناتك.';

  @override
  String get deleteAccountConfirmCancel => 'إلغاء';

  @override
  String get deleteAccountConfirmDelete => 'حذف الحساب';

  @override
  String get deleteAccountReauthTitle => 'تحقق من هويتك';

  @override
  String get deleteAccountReauthBody =>
      'لأسباب أمنية، يرجى التحقق من هويتك قبل حذف حسابك.';

  @override
  String get deleteAccountReauthPasswordButton => 'تحقق واحذف';

  @override
  String get deleteAccountReauthGoogleButton => 'إعادة المصادقة مع جوجل';

  @override
  String get deleteAccountReauthAppleButton => 'إعادة المصادقة مع أبل';

  @override
  String get deleteAccountSuccessMessage => 'تم حذف حسابك.';

  @override
  String get deleteAccountRequiresRecentLogin =>
      'يرجى تسجيل الدخول مرة أخرى قبل حذف حسابك.';

  @override
  String get deleteAccountErrorGeneric =>
      'تعذّر حذف حسابك. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get deleteAccountWrongPassword =>
      'كلمة مرور غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteAccountDeletingProgress => 'جارٍ حذف حسابك…';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String verifyEmailBody(String email) {
    return 'أرسلنا رابط تحقق إلى $email. يرجى التحقق من صندوق الوارد والنقر على الرابط للمتابعة.';
  }

  @override
  String get verifyEmailResendButton => 'إعادة إرسال البريد';

  @override
  String verifyEmailResendCooldown(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get verifyEmailContinueButton => 'لقد تحققت من بريدي';

  @override
  String get verifyEmailSignOutButton => 'تسجيل الخروج';

  @override
  String get verifyEmailSentConfirmation => 'تم إرسال بريد التحقق.';

  @override
  String get verifyEmailNotYetVerified =>
      'لم يتم التحقق من البريد بعد. يرجى التحقق من صندوق الوارد.';

  @override
  String get verifyEmailSendFailed =>
      'تعذّر إرسال بريد التحقق. يرجى المحاولة مرة أخرى.';

  @override
  String get verifyEmailCheckLabel => 'جارٍ التحقق من حالة التحقق';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في فوتبول أجنت ميت';

  @override
  String get onboardingWelcomeSubtitle =>
      'قالب Flutter الجاهز للإنتاج. كل ما تحتاجه للبناء والنشر والتوسع — معدّ مسبقاً.';

  @override
  String get onboardingBuildFasterTitle => 'ابنِ أسرع';

  @override
  String get onboardingBuildFasterSubtitle =>
      'المصادقة والتوجيه والسمات والتعريب والمزيد — مبنية مسبقاً لتركز على ما يميز تطبيقك.';

  @override
  String get onboardingShipTitle => 'انشر بثقة';

  @override
  String get onboardingShipSubtitle =>
      'بنية إنتاجية عالية الجودة، مُختبرة وموثقة. ابدأ ببناء تطبيقك الرائع القادم اليوم.';

  @override
  String get onboardingSkipButton => 'تخطي';

  @override
  String get onboardingNextButton => 'التالي';

  @override
  String get onboardingGetStartedButton => 'ابدأ الآن';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String get offlineBannerMessage =>
      'أنت غير متصل بالإنترنت. بعض الميزات قد لا تكون متاحة.';

  @override
  String get offlineBannerSemanticsLabel =>
      'أنت حالياً غير متصل بالإنترنت. بعض الميزات قد لا تكون متاحة.';

  @override
  String get offlineSaveMessage =>
      'تم حفظ التغييرات بدون اتصال — ستتم المزامنة عند الاتصال.';

  @override
  String get exploreTitle => 'استكشاف';

  @override
  String get exploreLoadError => 'تعذّر تحميل المستخدمين';

  @override
  String get exploreLoadErrorBody =>
      'حدث خطأ أثناء تحميل القائمة. يرجى المحاولة مرة أخرى.';

  @override
  String get exploreEmptyTitle => 'لا يوجد مستخدمون بعد';

  @override
  String get exploreEmptyBody => 'لا توجد ملفات شخصية للعرض حالياً.';

  @override
  String get exploreNoMoreResults => 'لا توجد نتائج أخرى';

  @override
  String get explorePageError => 'تعذّر تحميل المزيد من العناصر.';

  @override
  String get exploreRefreshLabel => 'تحديث قائمة المستخدمين';

  @override
  String exploreUserItemLabel(String name, String email) {
    return '$name، $email';
  }

  @override
  String get userDetailTitle => 'تفاصيل المستخدم';

  @override
  String get userDetailDisplayName => 'الاسم المعروض';

  @override
  String get userDetailEmail => 'البريد الإلكتروني';

  @override
  String get userDetailCreatedAt => 'تاريخ الانضمام';

  @override
  String get userDetailUpdatedAt => 'آخر تحديث';

  @override
  String get userDetailNoDate => 'غير متوفر';

  @override
  String get biometricLockTitle => 'التطبيق مقفل';

  @override
  String get biometricLockSubtitle => 'قم بالمصادقة للمتابعة';

  @override
  String get biometricReason => 'يرجى المصادقة لفتح التطبيق';

  @override
  String get biometricTryAgainButton => 'حاول مجدداً';

  @override
  String get biometricUsePasscodeButton => 'استخدم رمز المرور';

  @override
  String get biometricFailedTitle => 'فشلت المصادقة';

  @override
  String get biometricFailedSubtitle =>
      'فشلت المصادقة البيومترية. يرجى استخدام رمز مرور جهازك بدلاً من ذلك.';

  @override
  String get biometricSettingsTitle => 'المصادقة البيومترية';

  @override
  String get biometricSettingsSubtitle =>
      'طلب بصمة الوجه أو الإصبع عند فتح التطبيق';

  @override
  String get biometricNotAvailable =>
      'المصادقة البيومترية غير متاحة على هذا الجهاز.';

  @override
  String get biometricEnableReason =>
      'تحقق من هويتك لتفعيل المصادقة البيومترية';

  @override
  String get biometricEnabledLabel => 'المصادقة البيومترية: مفعّلة';

  @override
  String get biometricDisabledLabel => 'المصادقة البيومترية: معطّلة';

  @override
  String get phoneSignInButton => 'المتابعة بالهاتف';

  @override
  String get phoneInputTitle => 'تسجيل الدخول بالهاتف';

  @override
  String get phoneCountrySearchHint => 'ابحث عن الدولة أو رمز الاتصال';

  @override
  String get phoneNumberHint => 'رقم الهاتف';

  @override
  String get phoneSendCodeButton => 'إرسال رمز التحقق';

  @override
  String get phoneOtpTitle => 'تحقق من هاتفك';

  @override
  String phoneOtpDigitLabel(int position, int total) {
    return 'الرقم $position من $total';
  }

  @override
  String phoneResendCountdown(String time) {
    return 'إعادة إرسال الرمز خلال $time';
  }

  @override
  String get phoneResendButton => 'إعادة إرسال الرمز';

  @override
  String get phoneCodeSentConfirmation => 'تم إرسال رمز التحقق.';

  @override
  String get phoneVerifyButton => 'تحقق';

  @override
  String get phoneInvalidNumberError =>
      'رقم هاتف غير صالح. يرجى التحقق والمحاولة مرة أخرى.';

  @override
  String get phoneTooManyRequestsError =>
      'طلبات كثيرة جداً. يرجى الانتظار قبل المحاولة مرة أخرى.';

  @override
  String get phoneNetworkError => 'تعذّر إرسال رمز التحقق. تحقق من اتصالك.';

  @override
  String get phoneInvalidCodeError =>
      'رمز التحقق غير صالح. يرجى المحاولة مرة أخرى.';

  @override
  String get phoneAccountExistsError => 'يوجد حساب مسجل بالفعل بهذا الرقم.';

  @override
  String playerCardLabel(String name, String position, String club) {
    return '$name، $position في $club';
  }

  @override
  String postCardLabel(String postType, String details) {
    return '$postType: $details';
  }

  @override
  String conversationCardLabel(String name, String lastMessage) {
    return 'محادثة مع $name: $lastMessage';
  }

  @override
  String get photoUploadLabel => 'رفع صورة';

  @override
  String documentSelectedLabel(String fileName) {
    return 'المستند المحدد: $fileName';
  }

  @override
  String get removeDocumentLabel => 'إزالة المستند';

  @override
  String uploadDocumentLabel(String label) {
    return 'رفع $label';
  }

  @override
  String familyContactLabel(String name, String relationship) {
    return '$name، $relationship';
  }

  @override
  String documentItemLabel(String label, String date) {
    return '$label، تم الرفع $date';
  }

  @override
  String noteItemLabel(String content) {
    return 'ملاحظة: $content';
  }

  @override
  String get editLabel => 'تعديل';

  @override
  String get deleteLabel => 'حذف';

  @override
  String get viewLabel => 'عرض';

  @override
  String get retryLabel => 'إعادة المحاولة';

  @override
  String get showcaseTitle => 'عرض المكونات';

  @override
  String get showcaseCards => 'البطاقات';

  @override
  String get showcaseFormElements => 'عناصر النموذج';

  @override
  String get showcaseButtons => 'الأزرار';

  @override
  String get showcaseListItems => 'عناصر القائمة';

  @override
  String get showcaseAvatars => 'الصور الرمزية';

  @override
  String get showcaseBadges => 'الشارات والعلامات';

  @override
  String get showcaseEmptyStates => 'حالات فارغة';

  @override
  String get showcaseFeedback => 'التغذية الراجعة';

  @override
  String get statusActiveClient => 'عميل نشط';

  @override
  String get statusProspect => 'مرشح';

  @override
  String get statusFormerClient => 'عميل سابق';

  @override
  String get postTypePlayerAvailable => 'لاعب متاح';

  @override
  String get postTypeNeedPlayer => 'مطلوب لاعب';

  @override
  String get emptyPlayersTitle => 'لا يوجد لاعبون بعد';

  @override
  String get emptyPlayersSubtitle => 'أضف أول لاعب للبدء.';

  @override
  String get errorLoadingData => 'فشل تحميل البيانات. يرجى المحاولة مرة أخرى.';
}
