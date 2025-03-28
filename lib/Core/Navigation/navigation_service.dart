import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    try {
      assert(AppRoutes.isValidRoute(routeName), 'Invalid route: $routeName');

      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator is not ready yet');
        return null;
      }

      return navigator.pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<T?> navigateToAndReplace<T>(String routeName,
      {Object? arguments}) async {
    try {
      assert(AppRoutes.isValidRoute(routeName), 'Invalid route: $routeName');

      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator is not ready yet');
        return null;
      }

      return navigator.pushNamedAndRemoveUntil<T>(routeName, (route) => false,
          arguments: arguments);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static bool goBack<T>([T? result]) {
    final navigator = navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop(result);
      return true;
    }
    return false;
  }

  static void popUntil(String routeName) {
    final navigator = navigatorKey.currentState;
    navigator?.popUntil(ModalRoute.withName(routeName));
  }
}
