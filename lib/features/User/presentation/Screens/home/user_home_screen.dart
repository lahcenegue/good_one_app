import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/contractor_list_item.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/service_grid_item.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/contractor_profile.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        if (userManager.isLoading) {
          return LoadingIndicator();
        }

        if (userManager.error != null) {
          return AppErrorWidget(
            message: userManager.error!,
            onRetry: userManager.initialize,
          );
        }

        return RefreshIndicator(
          onRefresh: userManager.initialize,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(20),
                vertical: context.getHeight(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.getHeight(40)),
                  if (userManager.token != null)
                    _buildHeader(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildSearchBar(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildServicesSection(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildBestContractorsSection(context, userManager),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    if (!userManager.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final user = userManager.userInfo;

    return Row(
      children: [
        UserAvatar(
          picture: user?.picture,
          size: context.getWidth(40),
        ),
        SizedBox(width: context.getWidth(10)),
        Expanded(
          child: _buildUserInfo(
            context,
            user!.fullName,
          ),
        ),
        _buildNotificationIcon(context),
        SizedBox(width: context.getWidth(10)),
        _buildMessageIcon(context, userManager),
      ],
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    String? name,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null
              ? '${AppLocalizations.of(context)!.hello}, $name'
              : AppLocalizations.of(context)!.hello,
          style: AppTextStyles.title2(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dimGray,
      ),
      child: IconButton(
        icon: Image.asset(
          AppAssets.notification,
          width: context.getAdaptiveSize(20),
        ),
        onPressed: () {
          NavigationService.navigateTo(AppRoutes.userNotificationsScreen);
        },
      ),
    );
  }

  Widget _buildMessageIcon(
      BuildContext context, UserManagerProvider userManager) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dimGray,
      ),
      child: IconButton(
        icon: Image.asset(
          AppAssets.message,
          width: context.getAdaptiveSize(25),
        ),
        onPressed: () {
          if (userManager.userInfo != null) {
            NavigationService.navigateTo(AppRoutes.conversations);
          }
        },
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, UserManagerProvider userManager) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dimGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: userManager.updateSearchQuery,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          prefixIcon: Icon(
            Icons.search,
            size: context.getAdaptiveSize(24),
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(
      BuildContext context, UserManagerProvider userManager) {
    return Column(
      children: [
        _buildSectionHeader(
          context,
          title: AppLocalizations.of(context)!.ourServices,
          onSeeAll: () => userManager.setCurrentIndex(2),
        ),
        if (userManager.isLoading && userManager.categories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          _buildServicesGrid(context, userManager),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.subTitle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            AppLocalizations.of(context)!.seeAll,
            style: AppTextStyles.textButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(
      BuildContext context, UserManagerProvider userManager) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: context.getWidth(10),
        mainAxisSpacing: context.getHeight(10),
      ),
      itemCount:
          userManager.categories.length > 6 ? 6 : userManager.categories.length,
      itemBuilder: (context, index) => ServiceGridItem(
        category: userManager.categories[index],
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.contractorsByService,
            arguments: {
              'id': userManager.categories[index].id,
              'name': userManager.categories[index].name,
            },
          );
        },
      ),
    );
  }

  Widget _buildBestContractorsSection(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.bestContractors,
              style: AppTextStyles.title2(context),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all contractors
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(10)),
        if (userManager.isLoading && userManager.bestContractors.isEmpty)
          const LoadingIndicator()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userManager.bestContractors.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: context.getHeight(10)),
            itemBuilder: (context, index) {
              return ContractorListItem(
                contractor: userManager.bestContractors[index],
                onTap: () async {
                  userManager.setSelectedContractor(
                      userManager.bestContractors[index]);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContractorProfile(),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
