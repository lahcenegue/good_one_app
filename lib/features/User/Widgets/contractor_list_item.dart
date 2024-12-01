import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_assets.dart';
import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Constants/app_links.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Core/Utils/size_config.dart';
import '../models/contractor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContractorListItem extends StatelessWidget {
  final Contractor contractor;
  final VoidCallback onFavorite;

  const ContractorListItem({
    super.key,
    required this.contractor,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.white,
          margin: EdgeInsets.only(bottom: context.getAdaptiveSize(12)),
          child: Padding(
            padding: EdgeInsets.all(context.getWidth(10)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${AppLinks.image}/${contractor.picture}',
                    width: context.getAdaptiveSize(88),
                    height: context.getAdaptiveSize(96),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: context.getAdaptiveSize(88),
                        height: context.getAdaptiveSize(96),
                        color: AppColors.dimGray,
                        child: Icon(
                          Icons.person,
                          size: context.getAdaptiveSize(40),
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: context.getWidth(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contractor.fullName,
                        style: AppTextStyles.text(context),
                      ),
                      Text(
                        contractor.service,
                        style: AppTextStyles.title2(context),
                      ),
                      Text(
                        '\$${contractor.costPerHour}',
                        style: AppTextStyles.price(context),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rate_rounded,
                            size: context.getWidth(18),
                            color: Colors.amber,
                          ),
                          SizedBox(width: context.getWidth(4)),
                          Text(
                            '4.6', //TODO
                            style: AppTextStyles.subTitle(context),
                          ),
                          SizedBox(width: context.getWidth(4)),
                          Text(
                            '(20 customers)', //TODO
                            style: AppTextStyles.text(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Image.asset(
              contractor.isFavorite ? AppAssets.bookMark2 : AppAssets.bookMark,
              width: context.getAdaptiveSize(24),
              height: context.getAdaptiveSize(24),
            ),
            onPressed: onFavorite,
          ),
        ),
      ],
    );
  }
}
