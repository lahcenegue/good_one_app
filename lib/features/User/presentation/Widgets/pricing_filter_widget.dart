import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PricingFilterWidget extends StatefulWidget {
  final Set<String> availablePricingTypes;
  final String? selectedPricingType;
  final double minPrice;
  final double maxPrice;
  final RangeValues? selectedPriceRange;
  final String selectedSortBy;
  final int? selectedMinRating;
  final List<int> availableRatingCounts;
  final Function(String?) onPricingTypeChanged;
  final Function(RangeValues?) onPriceRangeChanged;
  final Function(String) onSortByChanged;
  final Function(int?) onMinRatingChanged;
  final VoidCallback onClearFilters;

  const PricingFilterWidget({
    super.key,
    required this.availablePricingTypes,
    this.selectedPricingType,
    required this.minPrice,
    required this.maxPrice,
    this.selectedPriceRange,
    required this.selectedSortBy,
    this.selectedMinRating,
    required this.availableRatingCounts,
    required this.onPricingTypeChanged,
    required this.onPriceRangeChanged,
    required this.onSortByChanged,
    required this.onMinRatingChanged,
    required this.onClearFilters,
  });

  @override
  State<PricingFilterWidget> createState() => _PricingFilterWidgetState();
}

class _PricingFilterWidgetState extends State<PricingFilterWidget> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.getWidth(16)),
      child: Column(
        children: [
          _buildFilterToggle(context),
          if (_showFilters) _buildFilterOptions(context),
        ],
      ),
    );
  }

  Widget _buildRatingFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.minimumRatings,
          style: AppTextStyles.subTitle(context).copyWith(
            fontSize: context.getAdaptiveSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        Wrap(
          spacing: context.getWidth(8),
          runSpacing: context.getHeight(4),
          children: widget.availableRatingCounts.map((count) {
            final bool isSelected = widget.selectedMinRating == count;
            return FilterChip(
              label: Text('${count}+ ${AppLocalizations.of(context)!.ratings}'),
              selected: isSelected,
              onSelected: (bool selected) {
                widget.onMinRatingChanged(selected ? count : null);
              },
              backgroundColor: AppColors.backgroundCard,
              selectedColor: AppColors.amberDark,
              labelStyle: AppTextStyles.withColor(
                AppTextStyles.withWeight(
                  AppTextStyles.withSize(AppTextStyles.captionMedium(context),
                      context.getAdaptiveSize(12)),
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                isSelected ? AppColors.whiteText : AppColors.amberLight,
              ),
              checkmarkColor: AppColors.whiteText,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(12),
        vertical: context.getHeight(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: context.getAdaptiveSize(20),
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: context.getWidth(8)),
                Text(
                  AppLocalizations.of(context)!.filterAndSort,
                  style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_hasActiveFilters())
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(8),
                vertical: context.getHeight(4),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(context.getWidth(10)),
              ),
              child: Text(
                _getActiveFiltersCount().toString(),
                style: AppTextStyles.text(context).copyWith(
                  color: Colors.white,
                  fontSize: context.getAdaptiveSize(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.getWidth(12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortBySection(context),
          if (widget.availablePricingTypes.isNotEmpty) ...[
            SizedBox(height: context.getHeight(16)),
            _buildPricingTypeSection(context),
          ],
          if (widget.maxPrice > widget.minPrice) ...[
            SizedBox(height: context.getHeight(16)),
            _buildPriceRangeSection(context),
          ],
          if (widget.availableRatingCounts.isNotEmpty) ...[
            SizedBox(height: context.getHeight(16)),
            _buildRatingFilterSection(context),
          ],
          SizedBox(height: context.getHeight(16)),
          _buildClearFiltersButton(context),
        ],
      ),
    );
  }

  Widget _buildSortBySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.sortBy,
          style: AppTextStyles.subTitle(context).copyWith(
            fontSize: context.getAdaptiveSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        Wrap(
          spacing: context.getWidth(8),
          runSpacing: context.getHeight(4),
          children: [
            _buildSortChip(context, 'default', 'Default Order', Icons.list),
            _buildSortChip(context, 'rating', 'Highest Rating', Icons.star),
            _buildSortChip(
                context, 'price_asc', 'Price: Low to High', Icons.arrow_upward),
            _buildSortChip(context, 'price_desc', 'Price: High to Low',
                Icons.arrow_downward),
            _buildSortChip(
                context, 'orders', 'Most Popular', Icons.trending_up),
            _buildSortChip(
                context, 'ratings_count', 'Most Rated', Icons.reviews),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(
      BuildContext context, String value, String label, IconData icon) {
    final bool isSelected = widget.selectedSortBy == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: context.getAdaptiveSize(14),
            color: isSelected ? Colors.white : AppColors.primaryColor,
          ),
          SizedBox(width: context.getWidth(4)),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        widget.onSortByChanged(value);
      },
      backgroundColor: AppColors.backgroundCard,
      selectedColor: AppColors.primaryColor,
      labelStyle: AppTextStyles.withColor(
        AppTextStyles.withWeight(
          AppTextStyles.withSize(AppTextStyles.captionMedium(context),
              context.getAdaptiveSize(12)),
          isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        isSelected ? AppColors.whiteText : AppColors.primaryColor,
      ),
      checkmarkColor: AppColors.whiteText,
    );
  }

  Widget _buildPricingTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.pricingType,
          style: AppTextStyles.subTitle(context).copyWith(
            fontSize: context.getAdaptiveSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        Wrap(
          spacing: context.getWidth(8),
          runSpacing: context.getHeight(4),
          children: widget.availablePricingTypes.map((type) {
            final bool isSelected = widget.selectedPricingType == type;
            return FilterChip(
              label: Text(_getPricingTypeLabel(context, type)),
              selected: isSelected,
              onSelected: (bool selected) {
                widget.onPricingTypeChanged(selected ? type : null);
              },
              backgroundColor: AppColors.backgroundCard,
              selectedColor: _getPricingTypeColor(type),
              labelStyle: AppTextStyles.withColor(
                AppTextStyles.withWeight(
                  AppTextStyles.withSize(AppTextStyles.captionMedium(context),
                      context.getAdaptiveSize(12)),
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                isSelected ? AppColors.whiteText : _getPricingTypeColor(type),
              ),
              checkmarkColor: AppColors.whiteText,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(BuildContext context) {
    final currentRange = widget.selectedPriceRange ??
        RangeValues(widget.minPrice, widget.maxPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.priceRange,
          style: AppTextStyles.subTitle(context).copyWith(
            fontSize: context.getAdaptiveSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        RangeSlider(
          values: currentRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: 20,
          labels: RangeLabels(
            '\$${currentRange.start.round()}',
            '\$${currentRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            widget.onPriceRangeChanged(values);
          },
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.primaryColor.withOpacity(0.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${widget.minPrice.round()}',
              style: AppTextStyles.text(context).copyWith(
                fontSize: context.getAdaptiveSize(12),
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '\$${widget.maxPrice.round()}',
              style: AppTextStyles.text(context).copyWith(
                fontSize: context.getAdaptiveSize(12),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton(BuildContext context) {
    if (!_hasActiveFilters()) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.onClearFilters,
        icon: Icon(
          Icons.clear_all,
          size: context.getAdaptiveSize(16),
          color: AppColors.errorDark,
        ),
        label: Text(
          AppLocalizations.of(context)!.clearFilters,
          style: AppTextStyles.withColor(
              AppTextStyles.bodyText(context), AppColors.errorDark),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.errorDark),
          padding: EdgeInsets.symmetric(vertical: context.getHeight(12)),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.selectedPricingType != null ||
        widget.selectedPriceRange != null ||
        widget.selectedSortBy != 'default' ||
        widget.selectedMinRating != null;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.selectedPricingType != null) count++;
    if (widget.selectedPriceRange != null) count++;
    if (widget.selectedSortBy != 'default') count++;
    if (widget.selectedMinRating != null) count++;
    return count;
  }

  String _getPricingTypeLabel(BuildContext context, String type) {
    switch (type) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourly;
      case 'daily':
        return AppLocalizations.of(context)!.daily;
      case 'fixed':
        return AppLocalizations.of(context)!.fixed;
      default:
        return type.toUpperCase();
    }
  }

  Color _getPricingTypeColor(String type) {
    switch (type) {
      case 'hourly':
        return AppColors.primaryColor;
      case 'daily':
        return Colors.orange.shade600;
      case 'fixed':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
