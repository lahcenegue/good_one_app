import 'package:flutter/material.dart';
import 'package:good_one_app/Features/auth/views/registration_screen.dart';

import '../../Features/Setup/Views/account_type_screen.dart';
import '../../Features/Setup/Views/language_selection_screen.dart';
import '../../Features/auth/views/login_screen.dart';
import '../../Features/Onboarding/Views/onbording_view.dart';
import '../../Features/User/views/user_home_screen.dart';

class AppRoutes {
  // Both Screens

  static const String languageSelection = '/';
  static const String onBording = '/onBording';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountSelection = '/accountSelection';

  //User Screens
  static const String userHome = '/userHomeScreen';

  static Map<String, WidgetBuilder> define() {
    return {
      languageSelection: (BuildContext context) =>
          const LanguageSelectionScreen(),
      userHome: (BuildContext context) => const UserHomeScreen(),
      onBording: (BuildContext context) => const OnBordingView(),
      login: (BuildContext context) => const LoginScreen(),
      register: (BuildContext context) => const RegistrationScreen(),
      accountSelection: (BuildContext context) =>
          const AccountTypeSelectionOverlay(),
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
