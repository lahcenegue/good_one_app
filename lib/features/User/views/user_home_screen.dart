import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Errors/error_widget.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Core/Utils/size_config.dart';
import '../../../Providers/user_manager_provider.dart';
import '../Widgets/contractor_list_item.dart';
import '../Widgets/service_grid_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
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
                  _buildSearchBar(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildServicesSection(context, userManager),
                  SizedBox(height: context.getHeight(20)),
                  _buildContractorsSection(context, userManager),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildHeader(BuildContext context) {
  //   return Row(
  //     children: [
  //       CircleAvatar(
  //         radius: context.getWidth(20),
  //         backgroundImage: const NetworkImage(
  //             '${AppLinks.baseUrl}/storage/profile.jpg'), // Replace with actual profile image
  //       ),
  //       SizedBox(width: context.getWidth(10)),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //              '${AppLocalizations.of(context)!.hello}, Lahsen',
  //             style: AppTextStyles.title(context),
  //           ),
  //           Text(
  //             'Yonge Street',
  //             style: AppTextStyles.text(context).copyWith(
  //               color: AppColors.hintColor,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const Spacer(),
  //       _buildNotificationIcon(context),
  //       _buildMessageIcon(context),
  //     ],
  //   );
  // }

  // Widget _buildNotificationIcon(BuildContext context) {
  //   return Stack(
  //     children: [
  //       IconButton(
  //         icon: const Icon(Icons.notifications_outlined),
  //         onPressed: () {},
  //       ),
  //       Positioned(
  //         right: 8,
  //         top: 8,
  //         child: Container(
  //           width: 8,
  //           height: 8,
  //           decoration: const BoxDecoration(
  //             color: AppColors.primaryColor,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildMessageIcon(BuildContext context) {
  //   return Stack(
  //     children: [
  //       IconButton(
  //         icon: const Icon(Icons.chat_bubble_outline),
  //         onPressed: () {},
  //       ),
  //       Positioned(
  //         right: 8,
  //         top: 8,
  //         child: Container(
  //           width: 8,
  //           height: 8,
  //           decoration: const BoxDecoration(
  //             color: AppColors.primaryColor,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.ourServices,
              style: AppTextStyles.subTitle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                userManager.setCurrentIndex(2);
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(10)),
        if (userManager.isLoading && userManager.categories.isEmpty)
          const CircularProgressIndicator()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: context.getWidth(10),
              mainAxisSpacing: context.getHeight(10),
            ),
            itemCount: userManager.categories.length,
            itemBuilder: (context, index) {
              return ServiceGridItem(
                category: userManager.categories[index],
              );
            },
          ),
      ],
    );
  }

  Widget _buildContractorsSection(
      BuildContext context, UserManagerProvider userManager) {
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
                //TODO
              },
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(10)),
        if (userManager.isLoading && userManager.contractors.isEmpty)
          const CircularProgressIndicator()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userManager.filteredContractors.length,
            itemBuilder: (context, index) {
              return ContractorListItem(
                contractor: userManager.filteredContractors[index],
                onFavorite: () => userManager
                    .toggleFavorite(userManager.filteredContractors[index].id),
              );
            },
          ),
      ],
    );
  }
}
