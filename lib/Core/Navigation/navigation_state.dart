import '../Utils/storage_keys.dart';
import '../infrastructure/storage/storage_manager.dart';
import '../presentation/resources/app_strings.dart';
import 'app_routes.dart';

class NavigationState {
  final bool isFirstLaunch;
  final bool hasLanguage;
  final bool hasCompletedOnboarding;
  final bool hasToken;
  final bool isAWorker;

  const NavigationState({
    required this.isFirstLaunch,
    required this.hasLanguage,
    required this.hasCompletedOnboarding,
    required this.hasToken,
    required this.isAWorker,
  });

  factory NavigationState.fromPrefs() {
    final hasLanguage =
        StorageManager.getString(StorageKeys.languageKey) != null;
    // First launch should be false if we have a language selected
    final isFirstLaunch =
        StorageManager.getBool(StorageKeys.firstLaunch) ?? !hasLanguage;

    return NavigationState(
      isFirstLaunch: isFirstLaunch,
      hasLanguage: hasLanguage,
      hasCompletedOnboarding:
          StorageManager.getBool(StorageKeys.onboardingKey) ?? false,
      hasToken: StorageManager.getString(StorageKeys.tokenKey) != null,
      isAWorker: StorageManager.getString(StorageKeys.accountTypeKey) ==
          AppStrings.service,
    );
  }

  String determineRoute() {
    // If we have a token, go directly to main screen
    if (hasToken) {
      if (isAWorker) {
        return AppRoutes.workerMain;
      } else {
        return AppRoutes.userMain;
      }
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
