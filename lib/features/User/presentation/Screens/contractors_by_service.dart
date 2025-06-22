import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/contractor_list_item.dart';
import 'package:good_one_app/Features/User/Presentation/Widgets/pricing_filter_widget.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/contractor_profile.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/User/contractors_by_service_provider.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

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
      final contractorsProvider =
          Provider.of<ContractorsByServiceProvider>(context, listen: false);
      final userManager =
          Provider.of<UserManagerProvider>(context, listen: false);

      contractorsProvider.updateContractorsByServiceSearch('');
      contractorsProvider.clearAllFilters();
      contractorsProvider.fetchContractorsByService(
          widget.serviceId, userManager.categories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserManagerProvider, ContractorsByServiceProvider>(
      builder: (context, userManager, contractorsProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title ?? ''),
            actions: [
              // Filter indicator
              if (contractorsProvider.hasActiveFilters)
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      '${_getActiveFiltersCount(contractorsProvider)}',
                      style: AppTextStyles.withColor(
                        AppTextStyles.withSize(
                            AppTextStyles.captionMedium(context), 12),
                        AppColors.whiteText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(context, contractorsProvider),
              _buildSubcategoryFilter(context, contractorsProvider),
              _buildPricingFilter(context, contractorsProvider),
              Expanded(
                child: _buildContractorsList(
                    context, userManager, contractorsProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    ContractorsByServiceProvider contractorsProvider,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          left: context.getWidth(16),
          right: context.getWidth(16),
          top: context.getHeight(12),
          bottom: context.getHeight(8)),
      child: TextField(
        onChanged: contractorsProvider.updateContractorsByServiceSearch,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
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
      BuildContext context, ContractorsByServiceProvider contractorsProvider) {
    final currentServiceCategory =
        contractorsProvider.currentViewedServiceCategory;
    if (currentServiceCategory == null ||
        currentServiceCategory.subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final subcategories = currentServiceCategory.subcategories;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(16), vertical: context.getHeight(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: context.getWidth(8),
              runSpacing: context.getHeight(4),
              children: subcategories.map((sub) {
                final bool isSelected =
                    contractorsProvider.selectedSubcategoryIds.contains(sub.id);
                return FilterChip(
                  label: Text(sub.name),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    contractorsProvider.toggleSubcategorySelection(sub.id);
                  },
                  backgroundColor: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade200,
                  selectedColor: AppColors.primaryColor.withOpacity(0.8),
                  labelStyle: AppTextStyles.withColor(
                    AppTextStyles.withWeight(
                      AppTextStyles.withSize(AppTextStyles.bodyText(context),
                          context.getAdaptiveSize(13)),
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    isSelected ? AppColors.whiteText : AppColors.blackAlpha87,
                  ),
                  checkmarkColor: AppColors.whiteText,
                  shape: StadiumBorder(
                      side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.borderGray)),
                  elevation: isSelected ? 2 : 0,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingFilter(
      BuildContext context, ContractorsByServiceProvider contractorsProvider) {
    if (contractorsProvider.contractorsByService.isEmpty) {
      return const SizedBox.shrink();
    }

    final priceRange = contractorsProvider.getPriceRange();
    final availablePricingTypes =
        contractorsProvider.getAvailablePricingTypes();
    final availableRatingCounts =
        contractorsProvider.getAvailableRatingCounts();

    return PricingFilterWidget(
      availablePricingTypes: availablePricingTypes,
      selectedPricingType: contractorsProvider.selectedPricingTypeFilter,
      minPrice: priceRange['min']!,
      maxPrice: priceRange['max']!,
      selectedPriceRange: contractorsProvider.selectedPriceRange,
      selectedSortBy: contractorsProvider.selectedSortBy,
      selectedMinRating: contractorsProvider.minRatingFilter,
      availableRatingCounts: availableRatingCounts,
      onPricingTypeChanged: (String? type) {
        contractorsProvider.setPricingTypeFilter(type);
      },
      onPriceRangeChanged: (RangeValues? range) {
        contractorsProvider.setPriceRangeFilter(range);
      },
      onSortByChanged: (String sortBy) {
        contractorsProvider.setSortBy(sortBy);
      },
      onMinRatingChanged: (int? minRating) {
        contractorsProvider.setMinRatingFilter(minRating);
      },
      onClearFilters: () {
        contractorsProvider.clearAllFilters();
      },
    );
  }

  Widget _buildContractorsList(
    BuildContext context,
    UserManagerProvider userManager,
    ContractorsByServiceProvider contractorsProvider,
  ) {
    if (contractorsProvider.isLoadingContractorsByService &&
        contractorsProvider.allContractorsForCurrentService.isEmpty) {
      return LoadingIndicator();
    }

    if (contractorsProvider.contractorsByServiceError != null &&
        contractorsProvider.allContractorsForCurrentService.isEmpty) {
      return AppErrorWidget(
        message: contractorsProvider.contractorsByServiceError!,
        onRetry: () => contractorsProvider.fetchContractorsByService(
            widget.serviceId, userManager.categories),
      );
    }

    // Use the filtered and sorted contractors
    final displayedContractors =
        contractorsProvider.filteredAndSortedContractors;

    if (displayedContractors.isEmpty) {
      String message;
      bool isSubcategoryFilterActive =
          contractorsProvider.selectedSubcategoryIds.isNotEmpty;
      bool isSearchFilterActive =
          contractorsProvider.contractorsByServiceSearchTerm.isNotEmpty;
      bool hasOtherFilters = contractorsProvider.hasActiveFilters;

      if (isSubcategoryFilterActive ||
          isSearchFilterActive ||
          hasOtherFilters) {
        message = 'No contractors match your filters'; // Fallback text
        try {
          message = AppLocalizations.of(context)!.noContractorsMatchFilters;
        } catch (e) {
          // Use fallback if localization key doesn't exist
        }
      } else if (contractorsProvider.allContractorsForCurrentService.isEmpty &&
          !contractorsProvider.isLoadingContractorsByService) {
        message = 'No contractors available in this category'; // Fallback text
        try {
          message = AppLocalizations.of(context)!
              .noContractorsAvailableInThisCategory;
        } catch (e) {
          // Use fallback if localization key doesn't exist
        }
      } else {
        message = AppLocalizations.of(context)!.noContractorsFound;
      }

      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.getAdaptiveSize(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_list_off,
                size: context.getAdaptiveSize(64),
                color: Colors.grey.shade400,
              ),
              SizedBox(height: context.getHeight(16)),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (contractorsProvider.hasActiveFilters) ...[
                SizedBox(height: context.getHeight(16)),
                ElevatedButton(
                  onPressed: () {
                    contractorsProvider.clearAllFilters();
                  },
                  child: Text(AppLocalizations.of(context)!
                      .clearFilters), // Fallback text
                ),
              ],
            ],
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

  int _getActiveFiltersCount(ContractorsByServiceProvider contractorsProvider) {
    int count = 0;
    if (contractorsProvider.selectedPricingTypeFilter != null) count++;
    if (contractorsProvider.selectedPriceRange != null) count++;
    if (contractorsProvider.selectedSortBy != 'default') count++;
    if (contractorsProvider.minRatingFilter != null) count++;
    return count;
  }
}
