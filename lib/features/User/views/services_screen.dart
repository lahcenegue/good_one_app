import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/Navigation/app_routes.dart';
import '../../../Core/presentation/resources/app_colors.dart';
import '../../../Core/presentation/Widgets/error/error_widget.dart';
import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Providers/user_manager_provider.dart';
import '../Widgets/service_grid_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh services when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagerProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        // Handle error state
        if (userManager.error != null) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: AppErrorWidget(
              message: userManager.error!,
              onRetry: userManager.fetchCategories,
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: userManager.fetchCategories,
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
                    _buildServicesGrid(context, userManager),
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

  Widget _buildServicesGrid(
      BuildContext context, UserManagerProvider userManager) {
    if (userManager.isLoading && userManager.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userManager.categories.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noServicesAvailable,
          style: AppTextStyles.text(context),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: context.getWidth(10),
        mainAxisSpacing: context.getHeight(10),
      ),
      itemCount: userManager.categories.length,
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
}
