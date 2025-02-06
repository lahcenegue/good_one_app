import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/storage_keys.dart';
import 'app_routes.dart';

class NavigationState {
  final bool isFirstLaunch;
  final bool hasLanguage;
  final bool hasCompletedOnboarding;
  final bool hasToken;

  const NavigationState({
    required this.isFirstLaunch,
    required this.hasLanguage,
    required this.hasCompletedOnboarding,
    required this.hasToken,
  });

  factory NavigationState.fromPrefs(SharedPreferences prefs) {
    final hasLanguage = prefs.getString(StorageKeys.languageKey) != null;
    // First launch should be false if we have a language selected
    final isFirstLaunch =
        prefs.getBool(StorageKeys.firstLaunch) ?? !hasLanguage;

    return NavigationState(
      isFirstLaunch: isFirstLaunch,
      hasLanguage: hasLanguage,
      hasCompletedOnboarding: prefs.getBool(StorageKeys.onboardingKey) ?? false,
      hasToken: prefs.getString(StorageKeys.tokenKey) != null,
    );
  }

  String determineRoute() {
    // If we have a token, go directly to main screen
    if (hasToken) {
      return AppRoutes.userMain;
    }

    // If language is selected and we're not on first launch
    if (hasLanguage && !isFirstLaunch) {
      // Go to onboarding if not completed
      if (!hasCompletedOnboarding) {
        return AppRoutes.onBording;
      }
      // Otherwise go to main screen
      return AppRoutes.userMain;
    }

    // Default to language selection
    return AppRoutes.languageSelection;
  }

  @override
  String toString() => 'NavigationState(isFirstLaunch: $isFirstLaunch, '
      'hasLanguage: $hasLanguage, '
      'hasCompletedOnboarding: $hasCompletedOnboarding, '
      'hasToken: $hasToken)';
}
