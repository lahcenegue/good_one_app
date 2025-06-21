import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Models/contractor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContractorListItem extends StatelessWidget {
  final Contractor contractor;
  final VoidCallback? onTap;

  const ContractorListItem({
    super.key,
    required this.contractor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GeneralBox(
        child: Row(
          children: [
            _buildContractorImage(context),
            SizedBox(width: context.getWidth(12)),
            Expanded(child: _buildContractorInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContractorImage(BuildContext context) {
    return UserAvatar(
      picture: contractor.picture,
      size: context.getWidth(90),
    );
  }

  Widget _buildContractorInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          contractor.fullName ?? AppLocalizations.of(context)!.unknown,
          style: AppTextStyles.text(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          contractor.service ?? AppLocalizations.of(context)!.service,
          style: AppTextStyles.title2(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        _buildPriceDisplay(context),
        _buildRatingRow(context),
      ],
    );
  }

  Widget _buildPriceDisplay(BuildContext context) {
    // Use the new pricing display system
    String priceText = contractor.getPriceDisplayText();

    return Row(
      children: [
        Expanded(
          child: Text(
            priceText,
            style: AppTextStyles.price(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: context.getWidth(4)),
        _buildPriceTypeChip(context),
      ],
    );
  }

  Widget _buildPriceTypeChip(BuildContext context) {
    // Only show chip if we have pricing type information
    String? pricingType =
        contractor.displayPrice?.type ?? contractor.pricingType;
    if (pricingType == null ||
        pricingType.isEmpty ||
        pricingType == 'unknown') {
      return const SizedBox.shrink();
    }

    Color chipColor = _getPricingTypeColor(pricingType);
    IconData chipIcon = _getPricingTypeIcon(pricingType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(6),
        vertical: context.getHeight(2),
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.getWidth(8)),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: context.getAdaptiveSize(12),
            color: chipColor,
          ),
          SizedBox(width: context.getWidth(2)),
          Text(
            _getPriceTypeLabel(context, pricingType),
            style: AppTextStyles.text(context).copyWith(
              fontSize: context.getAdaptiveSize(10),
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    // Safely handle rating display
    double rating = contractor.rating?.rating ?? 0.0;
    int orders = contractor.orders ?? 0;

    return Row(
      children: [
        Icon(
          Icons.star_outlined,
          size: context.getAdaptiveSize(18),
          color: AppColors.rating,
        ),
        SizedBox(width: context.getWidth(4)),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.text(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: context.getWidth(4)),
        Text(
          "($orders ${AppLocalizations.of(context)!.orders})",
          style: AppTextStyles.text(context).copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getPricingTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hourly':
        return AppColors.primaryColor;
      case 'daily':
        return AppColors.warningDark;
      case 'fixed':
        return AppColors.successDark;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPricingTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hourly':
        return Icons.access_time;
      case 'daily':
        return Icons.calendar_today;
      case 'fixed':
        return Icons.receipt_long;
      default:
        return Icons.attach_money;
    }
  }

  String _getPriceTypeLabel(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourly;
      case 'daily':
        return AppLocalizations.of(context)!.daily;
      case 'fixed':
        return AppLocalizations.of(context)!.fixed;
      default:
        return '';
    }
  }
}
