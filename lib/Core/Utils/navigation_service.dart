import 'package:flutter/material.dart';

import '../../Views/Both/language_selection_view.dart';
import '../../Views/Both/splash_view.dart';
import '../../Views/User/user_home_screen.dart';

class AppRoutes {
  // Both Screens
  static const String splash = '/';
  static const String languageSelection = '/LanguageSelectionScreen';

  //User Screens
  static const String userHome = '/userHomeScreen';

  static Map<String, WidgetBuilder> define() {
    return {
      splash: (BuildContext context) => const SplashScreen(),
      languageSelection: (BuildContext context) =>
          const LanguageSelectionScreen(),
      userHome: (BuildContext context) => const UserHomeScreen(),
    };
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName) async {
    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator is not ready yet');
        return null;
      }
      return navigator.pushNamed(routeName);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<dynamic> navigateToAndReplace(String routeName) async {
    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator is not ready yet');
        return null;
      }
      return navigator.pushNamedAndRemoveUntil(routeName, (route) => false);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static void goBack() {
    final navigator = navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    }
  }
}
