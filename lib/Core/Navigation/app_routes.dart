import 'package:flutter/material.dart';
import 'package:good_one_app/Features/Worker/views/worker_main_screen.dart';
import '../../Features/Chat/Views/conversations_screen.dart';
import '../../Features/User/views/contractors_by_service.dart';
import '../../Features/User/views/profile/language_settings_screen.dart';
import '../../Features/auth/views/registration_screen.dart';
import '../../Features/Chat/Views/chat_screen.dart';
import '../../Features/Setup/Views/account_type_screen.dart';
import '../../Features/Setup/Views/language_selection_screen.dart';
import '../../Features/auth/views/login_screen.dart';
import '../../Features/Onboarding/Views/onbording_view.dart';
import '../../Features/User/views/home/user_main_screen.dart';

class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Route Names
  static const String languageSelection = '/';
  static const String onBording = '/onBording';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountSelection = '/accountSelection';
  static const String chat = '/chat';
  static const String userMain = '/userMainScreen';
  static const String conversations = '/conversations';
  static const String contractorsByService = '/contractorsByService';
  static const String languageSettingsScreen = '/LanguageSettingsScreen';

  static const String workerMain = '/workerMainScreen';

  // Route Definitions
  static Map<String, WidgetBuilder> define() {
    return {
      languageSelection: (_) => const LanguageSelectionScreen(),
      languageSettingsScreen: (_) => const LanguageSettingsScreen(),
      userMain: (_) => const UserMainScreen(),
      onBording: (_) => const OnBordingView(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegistrationScreen(),
      accountSelection: (_) => const AccountTypeSelectionOverlay(),
      chat: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return ChatScreen(
          otherUserId: args['otherUserId']!,
          otherUserName: args['otherUserName']!,
        );
      },
      conversations: (_) => const ConversationsScreen(),
      contractorsByService: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ContractorsByService(
          serviceId: args['id'],
          title: args['name'],
        );
      },

      //
      workerMain: (_) => const WorkerMainScreen(),
    };
  }

  // Route Validation
  static bool isValidRoute(String route) {
    return define().containsKey(route);
  }
}
