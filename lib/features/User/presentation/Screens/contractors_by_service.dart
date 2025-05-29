import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/contractor_list_item.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/contractor_profile.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContractorsByService extends StatefulWidget {
  final int? serviceId;
  final String? title;

  const ContractorsByService({
    super.key,
    required this.serviceId,
    required this.title,
  });

  @override
  State<ContractorsByService> createState() => _ContractorsByServiceState();
}

class _ContractorsByServiceState extends State<ContractorsByService> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userManager =
          Provider.of<UserManagerProvider>(context, listen: false);

      userManager.updateContractorsByServiceSearch('');
      userManager.fetchContractorsByService(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title ?? ''),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(context, userManager),
              _buildSubcategoryFilter(context, userManager),
              Expanded(
                child: _buildContractorsList(context, userManager),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          left: context.getWidth(16),
          right: context.getWidth(16),
          top: context.getHeight(12),
          bottom: context.getHeight(8)),
      child: TextField(
        onChanged: userManager.updateContractorsByServiceSearch,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            // Lighter border when not focused
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            // Highlight border when focused
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: context.getHeight(12)),
        ),
      ),
    );
  }

  Widget _buildSubcategoryFilter(
      BuildContext context, UserManagerProvider userManager) {
    final currentServiceCategory = userManager.currentViewedServiceCategory;
    if (currentServiceCategory == null ||
        currentServiceCategory.subcategories.isEmpty) {
      return const SizedBox.shrink(); // No subcategories to show
    }

    final subcategories = currentServiceCategory.subcategories;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(16), vertical: context.getHeight(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: Title for the filter section
          // Text(
          //   AppLocalizations.of(context)!.filterBySubcategory,
          //   style: AppTextStyles.subTitle(context).copyWith(fontSize: context.getAdaptiveSize(14)),
          // ),
          // SizedBox(height: context.getHeight(8)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: context.getWidth(8),
              runSpacing: context.getHeight(
                  4), // Not really used for horizontal scroll, but good practice
              children: subcategories.map((sub) {
                final bool isSelected =
                    userManager.selectedSubcategoryIds.contains(sub.id);
                return FilterChip(
                  label: Text(sub.name),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    userManager.toggleSubcategorySelection(sub.id);
                  },
                  backgroundColor: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade200,
                  selectedColor: AppColors.primaryColor
                      .withOpacity(0.8), // More distinct selected color
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: context.getAdaptiveSize(13)),
                  checkmarkColor: Colors.white,
                  shape: StadiumBorder(
                      side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey.shade400)),
                  elevation: isSelected ? 2 : 0,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractorsList(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    if (userManager.isLoadingContractorsByService &&
        userManager.allContractorsForCurrentService.isEmpty) {
      return LoadingIndicator();
    }

    if (userManager.contractorsByServiceError != null &&
        userManager.allContractorsForCurrentService.isEmpty) {
      return AppErrorWidget(
        message: userManager.contractorsByServiceError!,
        onRetry: () => userManager.fetchContractorsByService(widget.serviceId),
      );
    }

    final displayedContractors = userManager.contractorsByService;

    if (displayedContractors.isEmpty) {
      String message;
      bool isSubcategoryFilterActive =
          userManager.selectedSubcategoryIds.isNotEmpty;
      bool isSearchFilterActive =
          userManager.contractorsByServiceSearchTerm.isNotEmpty;

      if (isSubcategoryFilterActive || isSearchFilterActive) {
        message = AppLocalizations.of(context)!
            .noContractorsMatchFilters; // ADD THIS TO .arb
      } else if (userManager.allContractorsForCurrentService.isEmpty &&
          !userManager.isLoadingContractorsByService) {
        // This means API returned empty, not due to filters
        message =
            AppLocalizations.of(context)!.noContractorsAvailableInThisCategory;
      } else {
        message = AppLocalizations.of(context)!.noContractorsFound;
      }
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.getAdaptiveSize(20)),
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
          left: context.getWidth(16),
          right: context.getWidth(16),
          top: context.getHeight(8),
          bottom: context.getHeight(16)),
      itemCount: displayedContractors.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.getHeight(10)),
      itemBuilder: (context, index) {
        return ContractorListItem(
          contractor: displayedContractors[index],
          onTap: () {
            userManager.setSelectedContractor(displayedContractors[index]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContractorProfile(),
              ),
            );
          },
        );
      },
    );
  }
}
