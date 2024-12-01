import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Errors/error_widget.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Providers/user_manager_provider.dart';
import '../Widgets/service_grid_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        if (userManager.error != null) {
          return AppErrorWidget(
            message: userManager.error!,
            onRetry: userManager.fetchCategories,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.services,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: userManager.fetchCategories,
            child: userManager.isLoading && userManager.categories.isEmpty
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
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
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                      ),
                    ),
                  ),
          ),
        );
      },
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
}
