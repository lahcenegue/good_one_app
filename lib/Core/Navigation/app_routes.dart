import 'package:flutter/material.dart';
import 'package:good_one_app/Features/Chat/presentation/screens/conversations_screen.dart';
import 'package:good_one_app/Features/Onboarding/Views/onbording_view.dart';
import 'package:good_one_app/Features/Setup/Views/account_type_screen.dart';
import 'package:good_one_app/Features/Setup/Views/language_selection_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/booking/booking_summary_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/booking/calender_booking_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/booking/location_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/contractors_by_service.dart';
import 'package:good_one_app/Features/User/presentation/views/home/user_main_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/notifications_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/profile/account_details_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/profile/language_settings_screen.dart';
import 'package:good_one_app/Features/User/presentation/views/support_screen.dart';
import 'package:good_one_app/Features/Worker/views/worker_main_screen.dart';
import 'package:good_one_app/Features/auth/views/login_screen.dart';
import 'package:good_one_app/Features/auth/views/registration_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String languageSelection = '/';
  static const String onBording = '/onBording';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountSelection = '/accountSelection';

  static const String userMain = '/userMainScreen';
  static const String conversations = '/conversations';
  static const String contractorsByService = '/contractorsByService';
  static const String languageSettingsScreen = '/LanguageSettingsScreen';
  static const String calendarBookingScreen = '/calendarBookingScreen';
  static const String locationScreen = '/locationScreen';
  static const String bookingSummaryScreen = '/bookingSummaryScreen';
  static const String notificationsScreen = '/NotificationsScreen';
  static const String accountDetails = '/accountDetails';
  static const String supportPage = '/supportPage';

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
      notificationsScreen: (_) => const NotificationsScreen(),
      accountDetails: (_) => AccountDetailsScreen(),
      supportPage: (_) => const SupportPage(),

      //
      workerMain: (_) => const WorkerMainScreen(),
    };
  }

  // Route Validation
  static bool isValidRoute(String route) {
    return define().containsKey(route);
  }
}
