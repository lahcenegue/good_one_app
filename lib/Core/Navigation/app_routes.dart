import 'package:flutter/material.dart';
import 'package:good_one_app/Features/Chat/Presentation/screens/conversations_screen.dart';
import 'package:good_one_app/Features/Onboarding/Presentation/Screens/onbording_view.dart';
import 'package:good_one_app/Features/Setup/Presentation/Screens/account_type_screen.dart';
import 'package:good_one_app/Features/Setup/Presentation/Screens/language_selection_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/booking/booking_summary_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/booking/calender_booking_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/booking/location_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/contractors_by_service.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/home/user_main_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/user_notifications_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/user_account_details_screen.dart';
import 'package:good_one_app/Features/Both/Presentation/Screens/language_settings_screen.dart';
import 'package:good_one_app/Features/Both/Presentation/Screens/support_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_account_details_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_main_screen.dart';
import 'package:good_one_app/Features/Auth/Presentation/Screens/login_screen.dart';
import 'package:good_one_app/Features/Auth/Presentation/Screens/registration_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_notification_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String languageSelection = '/';
  static const String onBording = '/onBording';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountSelection = '/accountSelection';

  // Both screens
  static const String conversations = '/conversations';

  // User Screens
  static const String userMain = '/userMainScreen';
  static const String contractorsByService = '/contractorsByService';
  static const String languageSettingsScreen = '/LanguageSettingsScreen';
  static const String calendarBookingScreen = '/calendarBookingScreen';
  static const String locationScreen = '/locationScreen';
  static const String bookingSummaryScreen = '/bookingSummaryScreen';
  static const String userNotificationsScreen = '/userNotificationsScreen';
  static const String userAccountDetails = '/userAccountDetails';
  static const String supportPage = '/supportPage';

  // Worker Screens
  static const String workerMain = '/workerMainScreen';
  static const String workerNotificationsScreen = '/workerNotificationsScreen';
  static const String workerAccountDetails = '/workerAccountDetails';

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

      conversations: (_) => const ConversationsScreen(),
      contractorsByService: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ContractorsByService(
          serviceId: args['id'],
          title: args['name'],
        );
      },

      calendarBookingScreen: (_) => const CalendarBookingScreen(),
      locationScreen: (_) => const LocationScreen(),
      bookingSummaryScreen: (_) => const BookingSummaryScreen(),
      userNotificationsScreen: (_) => const UserNotificationsScreen(),
      userAccountDetails: (_) => UserAccountDetailsScreen(),
      supportPage: (_) => const SupportPage(),

      // Worker
      workerMain: (_) => const WorkerMainScreen(),
      workerNotificationsScreen: (_) => const WorkerNotificationScreen(),
      workerAccountDetails: (_) => WorkerAccountDetailsScreen(),
    };
  }

  // Route Validation
  static bool isValidRoute(String route) {
    return define().containsKey(route);
  }
}
