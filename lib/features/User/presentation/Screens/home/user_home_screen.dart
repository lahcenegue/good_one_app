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
import 'package:good_one_app/Core/Utils/message_helper.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserManagerProvider, ChatProvider>(
      builder: (context, userManager, chatProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            final currentUserId = userManager.userInfo?.id?.toString();
            await Future.wait([
              userManager.initialize(),
              if (currentUserId != null)
                Provider.of<ChatProvider>(context, listen: false)
                    .initialize(currentUserId),
            ]);
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

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, child) {
        final count = userManager.unreadNotificationCount;

        return GestureDetector(
          onTap: () async {
            NavigationService.navigateTo(AppRoutes.userNotificationsScreen);

            // Mark notifications as seen when tapping
            if (count > 0) {
              Future.delayed(const Duration(milliseconds: 100), () {
                userManager.markAllNotificationsAsSeenNew();
              });
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
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
                  onPressed: null, // We handle tap in GestureDetector
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: context.getAdaptiveSize(20),
                      minHeight: context.getAdaptiveSize(20),
                    ),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: count > 9 ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageIcon(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return MessageHelper.buildMessageIconWithBadge(
      context: context,
      icon: Container(
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
          onPressed: null, // We handle tap in MessageHelper
        ),
      ),
      onTap: userManager.userInfo != null
          ? () {
              // Initialize chat with current user ID before navigation
              final currentUserId = userManager.userInfo?.id?.toString();
              if (currentUserId != null) {
                Provider.of<ChatProvider>(context, listen: false)
                    .initialize(currentUserId);
              }
              NavigationService.navigateTo(AppRoutes.conversations);
            }
          : null,
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
        if (userManager.isLoadingCategories)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: Center(
              child: CircularProgressIndicator(),
            ),
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
            Row(
              children: [
                // Enhanced sort button for best contractors
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.sort,
                    color: AppColors.primaryColor,
                    size: context.getAdaptiveSize(20),
                  ),
                  onSelected: (String sortBy) {
                    userManager.setHomeScreenSortBy(sortBy);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.list,
                              size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.defaultOrder),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'rating',
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.highestRating),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              size: 16, color: Colors.green),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.lowestPrice),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward,
                              size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.highestPrice),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'orders',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.mostPopular),
                        ],
                      ),
                    ),
                    // New pricing type options
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'hourly',
                      child: Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: AppColors.primaryColor),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!
                              .hourlyServicesFirst),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'daily',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                              AppLocalizations.of(context)!.dailyServicesFirst),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'fixed',
                      child: Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: Colors.green),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.fixedPriceFirst),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (userManager.isLoadingBestContractors)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
            child: const Center(child: CircularProgressIndicator()),
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

  Widget _buildBestContractorsList(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    // Use the new sorted method from provider
    final sortedContractors = userManager.getSortedBestContractors();
    final displayedContractors = sortedContractors.take(30).toList();

    if (displayedContractors.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Show current sort indicator if not default
        if (userManager.homeScreenSortBy != 'default')
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(12),
              vertical: context.getHeight(6),
            ),
            margin: EdgeInsets.only(bottom: context.getHeight(8)),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.getWidth(8)),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSortIcon(userManager.homeScreenSortBy),
                  size: context.getAdaptiveSize(14),
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: context.getWidth(6)),
                Text(
                  '${AppLocalizations.of(context)!.sortBy} ${_getSortLabel(context, userManager.homeScreenSortBy)}',
                  style: AppTextStyles.text(context).copyWith(
                    fontSize: context.getAdaptiveSize(12),
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => userManager.setHomeScreenSortBy('default'),
                  child: Icon(
                    Icons.close,
                    size: context.getAdaptiveSize(16),
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedContractors.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: context.getHeight(12)),
            itemBuilder: (context, index) {
              return ContractorListItem(
                contractor: displayedContractors[index],
                onTap: () async {
                  userManager
                      .setSelectedContractor(displayedContractors[index]);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContractorProfile()),
                  );
                },
              );
            }),
      ],
    );
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return Icons.star;
      case 'price_asc':
        return Icons.arrow_upward;
      case 'price_desc':
        return Icons.arrow_downward;
      case 'orders':
        return Icons.trending_up;
      case 'hourly':
        return Icons.schedule;
      case 'daily':
        return Icons.calendar_today;
      case 'fixed':
        return Icons.attach_money;
      default:
        return Icons.list;
    }
  }

  String _getSortLabel(BuildContext context, String sortBy) {
    switch (sortBy) {
      case 'rating':
        return AppLocalizations.of(context)!.highestRating;
      case 'price_asc':
        return AppLocalizations.of(context)!.lowestPrice;
      case 'price_desc':
        return AppLocalizations.of(context)!.highestPrice;
      case 'orders':
        return AppLocalizations.of(context)!.mostPopular;
      case 'hourly':
        return AppLocalizations.of(context)!.hourlyServices;
      case 'daily':
        return AppLocalizations.of(context)!.dailyServices;
      case 'fixed':
        return AppLocalizations.of(context)!.fixedPriceServices;
      default:
        return AppLocalizations.of(context)!.defaultOrder;
    }
  }
}
