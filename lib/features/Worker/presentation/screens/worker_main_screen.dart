import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/my_orders_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_home_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_profile_screen.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/worker_services_screen.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerMainScreen extends StatelessWidget {
  const WorkerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        if (workerManager.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(child: _buildCurrentScreen(context, workerManager)),
          bottomNavigationBar: _buildBottomNavigation(context, workerManager),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    switch (workerManager.currentIndex) {
      case 0:
        return const WorkerHomeScreen();
      case 1:
        return const WWorkerServicesScreen();
      case 2:
        return const MyOrdersScreen();
      case 3:
        return const WorkerProfileScreen();
      default:
        return const Text('Home Screen 2');
    }
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    final items = [
      _buildNavItem(
        context: context,
        index: 0,
        label: AppLocalizations.of(context)!.home,
        activeIcon: AppAssets.home2,
        inactiveIcon: AppAssets.home,
        currentIndex: workerManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 1,
        label: AppLocalizations.of(context)!.services,
        activeIcon: AppAssets.services2,
        inactiveIcon: AppAssets.services,
        currentIndex: workerManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 2,
        label: AppLocalizations.of(context)!.order,
        activeIcon: AppAssets.booking2,
        inactiveIcon: AppAssets.booking,
        currentIndex: workerManager.currentIndex,
      ),
      _buildNavItem(
        context: context,
        index: 3,
        label: AppLocalizations.of(context)!.profile,
        activeIcon: AppAssets.profile2,
        inactiveIcon: AppAssets.profile,
        currentIndex: workerManager.currentIndex,
      ),
    ];
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: workerManager.currentIndex,
      onTap: workerManager.setCurrentIndex,
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
