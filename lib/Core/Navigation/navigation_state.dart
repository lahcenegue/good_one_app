import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';

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
      isAWorker: accountType == AppConfig.service,
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
