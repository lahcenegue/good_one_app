import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/presentation/resources/app_assets.dart';
import '../../../Core/presentation/resources/app_colors.dart';
import '../../../Core/presentation/Widgets/error/error_widget.dart';
import '../../../Providers/user_manager_provider.dart';

import 'booking/booking_screen.dart';
import 'services_screen.dart';
import 'user_home_screen.dart';
import 'profile/user_profile_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        // Show loading indicator while initializing
        if (userManager.isLoading && userManager.currentIndex == 0) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error widget if there's an error
        if (userManager.error != null && userManager.currentIndex == 0) {
          return Scaffold(
            body: Center(
              child: AppErrorWidget(
                message: userManager.error!,
                onRetry: () => userManager.initialize(),
              ),
            ),
          );
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
        index: 0,
        label: AppLocalizations.of(context)!.home,
        activeIcon: AppAssets.home2,
        inactiveIcon: AppAssets.home,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
        index: 1,
        label: AppLocalizations.of(context)!.booking,
        activeIcon: AppAssets.booking2,
        inactiveIcon: AppAssets.booking,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
        index: 2,
        label: AppLocalizations.of(context)!.services,
        activeIcon: AppAssets.services2,
        inactiveIcon: AppAssets.services,
        currentIndex: userManager.currentIndex,
      ),
      _buildNavItem(
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
