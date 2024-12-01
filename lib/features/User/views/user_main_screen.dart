import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_assets.dart';
import '../../../Core/Constants/app_colors.dart';
import '../../../Providers/user_manager_provider.dart';

import 'services_screen.dart';
import 'user_home_screen.dart';
import 'user_profile_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserMainScreen extends StatelessWidget {
  const UserMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          body: _buildCurrentScreen(context, userManager),
          bottomNavigationBar: _buildBottomNavigation(context, userManager),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
      BuildContext context, UserManagerProvider userManager) {
    switch (userManager.currentIndex) {
      case 0:
        return const UserHomeScreen();
      case 1:
        return Center(
          child: Text(
            'comingSoon',
            style: const TextStyle(fontSize: 20),
          ),
        );
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
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: userManager.currentIndex,
      onTap: userManager.setCurrentIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.hintColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            userManager.currentIndex == 0 ? AppAssets.home2 : AppAssets.home,
            width: context.getAdaptiveSize(24),
          ),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            userManager.currentIndex == 1
                ? AppAssets.booking2
                : AppAssets.booking,
            width: context.getAdaptiveSize(24),
          ),
          label: AppLocalizations.of(context)!.booking,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            userManager.currentIndex == 2
                ? AppAssets.services2
                : AppAssets.services,
            width: context.getAdaptiveSize(24),
          ),
          label: AppLocalizations.of(context)!.services,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            userManager.currentIndex == 3
                ? AppAssets.profile2
                : AppAssets.profile,
            width: context.getAdaptiveSize(24),
          ),
          label: AppLocalizations.of(context)!.profile,
        ),
      ],
    );
  }
}
