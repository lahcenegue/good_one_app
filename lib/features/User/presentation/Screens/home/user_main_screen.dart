import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/booking/booking_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/home/user_home_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/user_profile_screen.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/services_screen.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userManager =
          Provider.of<UserManagerProvider>(context, listen: false);
      await userManager.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        if (userManager.isGlobalLoading &&
            userManager.categories.isEmpty &&
            userManager.bestContractors.isEmpty &&
            userManager.userInfo == null) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }
        if (userManager.globalError != null &&
            userManager.categories.isEmpty &&
            userManager.bestContractors.isEmpty) {
          return Scaffold(
              body: AppErrorWidget(
            message: userManager.globalError!,
            onRetry: () => userManager.initialize(),
          ));
        }

        return Scaffold(
          body: _buildCurrentScreen(context, userManager),
          bottomNavigationBar: _buildBottomNavigation(context, userManager),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    switch (userManager.currentIndex) {
      case 0:
        return const UserHomeScreen();

      case 1:
        return const BookingScreen();
      case 2:
        return const ServicesScreen();
      case 3:
        return const UserProfileScreen();
      default:
        return const UserHomeScreen();
    }
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    final items = [
      _buildNavItem(
        context: context,
        index: 0,
        label: AppLocalizations.of(context)!.home,
        activeIcon: AppAssets.home2,
        inactiveIcon: AppAssets.home,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 1,
        label: AppLocalizations.of(context)!.booking,
        activeIcon: AppAssets.booking2,
        inactiveIcon: AppAssets.booking,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 2,
        label: AppLocalizations.of(context)!.services,
        activeIcon: AppAssets.services2,
        inactiveIcon: AppAssets.services,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 3,
        label: AppLocalizations.of(context)!.profile,
        activeIcon: AppAssets.profile2,
        inactiveIcon: AppAssets.profile,
        currentIndex: userManager.currentIndex,
      ),
    ];
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: userManager.currentIndex,
      onTap: userManager.setCurrentIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.hintColor,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required String activeIcon,
    required String inactiveIcon,
    required int currentIndex,
  }) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        currentIndex == index ? activeIcon : inactiveIcon,
        width: context.getAdaptiveSize(24),
      ),
      label: label,
    );
  }
}
