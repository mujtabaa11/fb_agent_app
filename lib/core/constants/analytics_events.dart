/// Centralised event name constants for [AnalyticsService].
///
/// Use these instead of inline strings when calling
/// `analyticsService.logEvent(AnalyticsEvents.login)`.
abstract final class AnalyticsEvents {
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';
  static const String forgotPassword = 'forgot_password';
  static const String screenView = 'screen_view';
  static const String appError = 'app_error';
}
