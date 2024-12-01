import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_assets.dart';
import 'package:good_one_app/Core/Widgets/custom_buttons.dart';
import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Utils/size_config.dart';
import '../../../Core/Themes/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            SizedBox(height: context.getHeight(12)),
            _buildProfileInfo(context),
            SizedBox(height: context.getHeight(12)),
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return SizedBox(
      height: 320,
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
              width: context.getAdaptiveSize(120),
              height: context.getAdaptiveSize(120),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 4,
                  color: Colors.white,
                ),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.profile2),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lahsen',
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

  Widget _buildProfileInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.getWidth(16)),
      child: Column(
        children: [
          _buildInfoItem(
            context,
            title: AppLocalizations.of(context)!.phone,
            value: '+213673459640',
          ),
          SizedBox(height: context.getHeight(16)),
          _buildInfoItem(
            context,
            title: AppLocalizations.of(context)!.location,
            value: 'Yonge Street, Kanada',
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

  Widget _buildMenuItems(BuildContext context) {
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
          title: AppLocalizations.of(context)!.language,
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
          title: AppLocalizations.of(context)!.privacyPolicy,
          onTap: () {},
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
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.dimGray,
            width: 1,
          ),
          //bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: Image.asset(
          image,
          color: Colors.black,
          width: context.getAdaptiveSize(20),
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
