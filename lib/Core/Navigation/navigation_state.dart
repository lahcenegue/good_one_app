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

  static Future<NavigationState> fromPrefs() async {
    final results = await Future.wait([
      StorageManager.getString(StorageKeys.languageKey),
      StorageManager.getBool(StorageKeys.firstLaunch),
      StorageManager.getBool(StorageKeys.onboardingKey),
      StorageManager.getString(StorageKeys.tokenKey),
      StorageManager.getString(StorageKeys.accountTypeKey),
    ]);

    final savedLanguage = results[0] as String?;
    final hasLanguage = savedLanguage != null;
    final firstLaunchValue = results[1] as bool?;
    final onboardingValue = results[2] as bool?;
    final token = results[3] as String?;
    final accountType = results[4] as String?;

    return NavigationState(
      isFirstLaunch: firstLaunchValue ?? !hasLanguage,
      hasLanguage: hasLanguage,
      hasCompletedOnboarding: onboardingValue ?? false,
      hasToken: token != null,
      isAWorker: accountType == AppStrings.service,
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
