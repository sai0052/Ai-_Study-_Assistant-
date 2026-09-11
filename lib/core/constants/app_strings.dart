/// App-wide string constants. Centralizing these makes future localization
/// (intl / .arb files) a much smaller migration later.
class AppStrings {
  AppStrings._();

  static const String appName = 'AI Student Assistant';

  // Auth
  static const String welcomeBack = 'Welcome back';
  static const String loginSubtitle = 'Sign in to continue your learning journey';
  static const String createAccount = 'Create your account';
  static const String signInWithGoogle = 'Continue with Google';

  // Dashboard
  static const String todaysTasks = "Today's Tasks";
  static const String upcomingDeadlines = 'Upcoming Deadlines';
  static const String studyProgress = 'Study Progress';
  static const String aiSuggestions = 'AI Suggestions';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection.';
}
