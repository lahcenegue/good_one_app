import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/service_grid_item.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: () async {
              await userManager.fetchCategories();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(20),
                  vertical: context.getHeight(10),
                ),
                child: Column(
                  children: [
                    _buildSearchBar(context, userManager),
                    SizedBox(height: context.getHeight(20)),
                    _buildServicesGridContainer(context, userManager),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        AppLocalizations.of(context)!.services,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dimGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: userManager.searchServicesQuery,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchServices,
          prefixIcon: Icon(
            Icons.search,
            size: context.getAdaptiveSize(22),
            color: Colors.grey.shade700,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.getWidth(15),
            vertical: context.getHeight(12),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGridContainer(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    if (userManager.isLoadingCategories && userManager.categories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.getHeight(50)),
        child: LoadingIndicator(),
      );
    }

    if (userManager.categoriesError != null && userManager.categories.isEmpty) {
      return AppErrorWidget(
        message: userManager.categoriesError!,
        onRetry: () => userManager.fetchCategories(),
      );
    }

    // Filter categories based on search query
    final filteredCategories = userManager.searchQuery.isEmpty
        ? userManager.categories
        : userManager.categories
            .where((category) => category.name
                .toLowerCase()
                .contains(userManager.searchQuery.toLowerCase()))
            .toList();

    if (filteredCategories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.getHeight(50)),
        child: Center(
          child: Text(
            userManager.searchQuery.isEmpty
                ? AppLocalizations.of(context)!.noServicesAvailable
                : AppLocalizations.of(context)!.noServiceFound,
            style: AppTextStyles.text(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: context.getWidth(12),
        mainAxisSpacing: context.getHeight(12),
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        return ServiceGridItem(
          category: filteredCategories[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.contractorsByService,
              arguments: {
                'id': filteredCategories[index].id,
                'name': filteredCategories[index].name,
              },
            );
          },
        );
      },
    );
  }
}
