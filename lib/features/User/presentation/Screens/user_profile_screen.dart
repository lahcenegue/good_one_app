import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (userManager.isAuthenticated)
                  _buildAuthenticatedHeader(context, userManager)
                else
                  _buildUnauthenticatedHeader(context),

                SizedBox(height: context.getHeight(12)),

                // Authentication-specific menu items
                if (userManager.token != null)
                  _buildAuthenticatedMenuItems(context, userManager),

                // Common menu items
                _buildCommonMenuItems(context),

                // Login button for unauthenticated users
                if (userManager.token == null)
                  _buildLoginButton(context, userManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedHeader(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    final user = userManager.userInfo;
    if (user == null) return const SizedBox.shrink();

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
              picture: user.picture,
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
                    user.fullName!,
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

  Widget _buildUnauthenticatedHeader(BuildContext context) {
    return SizedBox(
      height: context.getHeight(320),
      child: Stack(
        children: [
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
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.account_circle,
                size: context.getHeight(150),
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context)!.loginToContinue,
                  style: AppTextStyles.title(context),
                ),
                SizedBox(height: context.getHeight(40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMenuItems(BuildContext context) {
    return Column(
      children: [
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
          image: AppAssets.privancy,
          title: AppLocalizations.of(context)!.privacyPolicy,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAuthenticatedMenuItems(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          image: AppAssets.profile,
          title: AppLocalizations.of(context)!.accountDetails,
          onTap: () {
            NavigationService.navigateTo(AppRoutes.userAccountDetails);
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
          image: AppAssets.logout,
          title: AppLocalizations.of(context)!.logout,
          onTap: () async {
            await userManager.clearData();
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

  Widget _buildLoginButton(
      BuildContext context, UserManagerProvider userManager) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(20),
        vertical: context.getHeight(20),
      ),
      child: PrimaryButton(
        text: AppLocalizations.of(context)!.login,
        onPressed: () {
          NavigationService.navigateTo(AppRoutes.accountSelection);
        },
      ),
    );
  }
}
