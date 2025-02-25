import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Core/presentation/Widgets/Buttons/primary_button.dart';
import '../../../../Core/presentation/Widgets/Buttons/secondary_button.dart';
import '../../../../Core/presentation/Widgets/user_avatar.dart';
import '../../../../Core/presentation/resources/app_assets.dart';
import '../../../../Core/presentation/resources/app_colors.dart';
import '../../../../Core/Navigation/app_routes.dart';
import '../../../../Core/Navigation/navigation_service.dart';
import '../../../../Core/Utils/size_config.dart';
import '../../../../Core/presentation/Theme/app_text_styles.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Providers/user_manager_provider.dart';

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

                // Profile Info - Only shown when authenticated
                if (userManager.isAuthenticated) ...[
                  _buildProfileInfo(context, userManager),
                  SizedBox(height: context.getHeight(12)),
                ],

                // Common menu items that don't require authentication
                _buildCommonMenuItems(context),

                // Authentication-specific menu items
                if (userManager.token != null)
                  _buildAuthenticatedMenuItems(context, userManager),

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
      BuildContext context, UserManagerProvider userManager) {
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
          // Align(
          //   alignment: Alignment.center,
          //   child: Container(
          //     width: context.getAdaptiveSize(120),
          //     height: context.getAdaptiveSize(120),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         width: 4,
          //         color: Colors.white,
          //       ),
          //       image: user?.picture != null
          //           ? DecorationImage(
          //               image: NetworkImage(
          //                 '${ApiEndpoints.imageBaseUrl}/${user!.picture}',
          //               ),
          //               fit: BoxFit.cover,
          //               onError: (_, __) {},
          //             )
          //           : null,
          //     ),
          //     child: user?.picture == null
          //         ? Icon(
          //             Icons.person,
          //             size: context.getAdaptiveSize(50),
          //             color: AppColors.primaryColor,
          //           )
          //         : null,
          //   ),
          // ),

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
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  user.fullName!,
                  style: AppTextStyles.title(context),
                ),
                SizedBox(height: context.getHeight(8)),
                SmallSecondaryButton(
                  text: AppLocalizations.of(context)!.edit,
                  onPressed: () {},
                )
              ],
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
                  AppLocalizations.of(context)!.loginToAccess,
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

  Widget _buildProfileInfo(
      BuildContext context, UserManagerProvider userManager) {
    final user = userManager.userInfo;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(context.getWidth(16)),
      child: Column(
        children: [
          _buildInfoItem(
            context,
            title: AppLocalizations.of(context)!.phone,
            value: user.phone.toString(),
          ),
          SizedBox(height: context.getHeight(16)),
          _buildInfoItem(
            context,
            title: AppLocalizations.of(context)!.location,
            value: user.location ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context,
      {required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.text(context),
        ),
        Text(
          value,
          style: AppTextStyles.subTitle(context),
        ),
      ],
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
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          image: AppAssets.profile,
          title: AppLocalizations.of(context)!.savedAddress,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          image: AppAssets.profile,
          title: AppLocalizations.of(context)!.support,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          image: AppAssets.profile,
          title: AppLocalizations.of(context)!.logout,
          onTap: () async {
            await userManager.clearAuthData();
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
