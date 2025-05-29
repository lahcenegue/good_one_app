import 'package:flutter/material.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/search_drop_down.dart';
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
        return RefreshIndicator(
          onRefresh: () async {
            await userManager.initialize();
          },
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
                  _buildHeader(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildSearchBar(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildServicesSection(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildBestContractorsSection(context, userManager),
                  SizedBox(height: context.getHeight(20)),
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
    if (userManager.isLoadingUserInfo && userManager.userInfo == null) {
      return SizedBox(
        height: context.getWidth(40) + context.getHeight(10),
        child: Center(child: LoadingIndicator()),
      );
    }

    if (!userManager.isAuthenticated || userManager.userInfo == null) {
      return const SizedBox.shrink(); // Or a "Guest" view
    }

    final user = userManager.userInfo!;

    return Row(
      children: [
        UserAvatar(
          picture: user.picture,
          size: context.getWidth(40),
        ),
        SizedBox(width: context.getWidth(10)),
        Expanded(
          child: _buildUserInfo(
            context,
            user.fullName,
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
          (name != null && name.isNotEmpty)
              ? '${AppLocalizations.of(context)!.hello}, $name'
              : AppLocalizations.of(context)!.hello,
          style: AppTextStyles.title2(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
  ) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.dimGray,
          ),
          child: IconButton(
            icon: Image.asset(
              AppAssets.notification,
              width: context.getAdaptiveSize(20),
              height: context.getAdaptiveSize(20),
            ),
            onPressed: () {
              NavigationService.navigateTo(AppRoutes.userNotificationsScreen);
            },
          ),
        ),
        //TODO hasUnreadNotifications
      ],
    );
  }

  Widget _buildMessageIcon(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dimGray,
      ),
      child: IconButton(
        icon: Image.asset(
          AppAssets.message,
          width: context.getAdaptiveSize(25),
          height: context.getAdaptiveSize(25),
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
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Column(
      children: [
        SearchDropdown(
          searchController: userManager.searchController,
          onSearch: userManager.searchServiceAndContractor,
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              userManager.searchServiceAndContractor(query);
            } else {
              userManager.searchResults.clear();
              userManager.searchController.clear();
            }
          },
          searchResults: userManager.searchResults,
          hintText: AppLocalizations.of(context)!.searchServices,
          onResultTap: (contractor) {
            userManager.setSelectedContractor(contractor);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContractorProfile(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: AppLocalizations.of(context)!.ourServices,
          onSeeAll: () => userManager.setCurrentIndex(2),
        ),
        SizedBox(height: context.getHeight(10)),
        if (userManager.isLoadingCategories)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: LoadingIndicator(),
          )
        else if (userManager.categoriesError != null)
          AppErrorWidget(
            message: userManager.categoriesError!,
            onRetry: () => userManager.fetchCategories(),
          )
        else if (userManager.categories.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noServicesAvailable,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
          )
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
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    final displayedCategories = userManager.categories.take(6).toList();
    if (displayedCategories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: context.getWidth(10),
        mainAxisSpacing: context.getHeight(10),
      ),
      itemCount: displayedCategories.length,
      itemBuilder: (context, index) => ServiceGridItem(
        category: displayedCategories[index],
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.contractorsByService,
            arguments: {
              'id': displayedCategories[index].id,
              'name': displayedCategories[index].name,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Navigator.pushNamed(
                  context,
                  AppRoutes.contractorsByService,
                  arguments: {
                    'id': 1,
                    'name': AppLocalizations.of(context)!.bestContractors,
                  },
                );
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        if (userManager.isLoadingBestContractors)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: const Center(child: LoadingIndicator()),
          )
        else if (userManager.bestContractorsError != null)
          AppErrorWidget(
            message: userManager.bestContractorsError!,
            onRetry: () => userManager.fetchBestContractors(),
          )
        else if (userManager.bestContractors.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noContractorsFound,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          _buildBestContractorsList(context, userManager),
      ],
    );
  }

  _buildBestContractorsList(
      BuildContext context, UserManagerProvider userManager) {
    final displayedContractors = userManager.bestContractors.toList();
    if (displayedContractors.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedContractors.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: context.getHeight(12)),
        itemBuilder: (context, index) {
          return ContractorListItem(
            contractor: displayedContractors[index],
            onTap: () async {
              userManager.setSelectedContractor(displayedContractors[index]);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContractorProfile()),
              );
            },
          );
        });
  }
}
