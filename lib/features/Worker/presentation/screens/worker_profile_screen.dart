import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/presentation/resources/app_assets.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, workerManager),
                SizedBox(height: context.getHeight(12)),
                _buildMenuItems(context, workerManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WorkerManagerProvider WorkerManager,
  ) {
    final worker = WorkerManager.workerInfo;
    if (worker == null) return const SizedBox.shrink();

    return SizedBox(
      height: context.getHeight(320),
      child: Stack(
        children: [
          // Background container
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              height: context.getHeight(150),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
          ),

          // User Avatar
          Align(
            alignment: Alignment.center,
            child: UserAvatar(
              picture: worker.picture,
              size: context.getWidth(120),
              backgroundColor: Colors.white,
            ),
          ),

          // User Info
          Positioned(
            bottom: context.getHeight(40),
            child: SizedBox(
              width: context.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    worker.fullName!,
                    style: AppTextStyles.title(context),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItems(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          image: AppAssets.profile,
          title: AppLocalizations.of(context)!.accountDetails,
          onTap: () {
            NavigationService.navigateTo(AppRoutes.workerAccountDetails);
          },
        ),
        _buildMenuItem(
          context,
          image: AppAssets.translate,
          title: AppLocalizations.of(context)!.language,
          onTap: () {
            NavigationService.navigateTo(AppRoutes.languageSettingsScreen);
          },
        ),
        _buildMenuItem(
          context,
          image: AppAssets.support,
          title: AppLocalizations.of(context)!.support,
          onTap: () {
            NavigationService.navigateTo(AppRoutes.supportPage);
          },
        ),
        _buildMenuItem(
          context,
          image: AppAssets.privancy,
          title: AppLocalizations.of(context)!.privacyPolicy,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          image: AppAssets.logout,
          title: AppLocalizations.of(context)!.logout,
          onTap: () async {
            await workerManager.clearAuthData();
            if (context.mounted) {
              NavigationService.navigateToAndReplace(AppRoutes.userMain);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.dimGray,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Image.asset(
          image,
          color: Colors.black,
          width: context.getAdaptiveSize(25),
        ),
        title: Text(
          title,
          style: AppTextStyles.title2(context),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: context.getAdaptiveSize(15),
        ),
        onTap: onTap,
      ),
    );
  }
}
