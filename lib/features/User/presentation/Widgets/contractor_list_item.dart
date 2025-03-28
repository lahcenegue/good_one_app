import 'package:flutter/material.dart';

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
      child: Container(
        padding: EdgeInsets.all(
          context.getWidth(10),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
    return Container(
      width: context.getWidth(88),
      height: context.getWidth(96),
      decoration: BoxDecoration(
        color: AppColors.dimGray,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: UserAvatar(
        picture: contractor.picture,
        size: context.getWidth(88),
      ),
    );
  }

  Widget _buildContractorInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          contractor.fullName!,
          style: AppTextStyles.text(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          contractor.service!,
          style: AppTextStyles.title2(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          contractor.costPerHour.toString(),
          style: AppTextStyles.price(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Icon(
              Icons.star_outlined,
              size: context.getAdaptiveSize(18),
              color: AppColors.rating,
            ),
            SizedBox(width: context.getWidth(4)),
            Text(
              contractor.rating!.rating.toStringAsFixed(1),
              style: AppTextStyles.text(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: context.getWidth(4)),
            Text(
              "(${contractor.orders} ${AppLocalizations.of(context)!.order})",
              style: AppTextStyles.text(context).copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
