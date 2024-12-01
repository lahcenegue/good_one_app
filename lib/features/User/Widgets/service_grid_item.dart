import 'package:flutter/material.dart';
import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Constants/app_links.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Core/Utils/size_config.dart';
import '../models/service_category.dart';

class ServiceGridItem extends StatelessWidget {
  final ServiceCategory category;

  const ServiceGridItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: context.getAdaptiveSize(110),
      // height: context.getAdaptiveSize(103),
      decoration: BoxDecoration(
        color: AppColors.dimGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            '${AppLinks.image}/${category.image}',
            width: context.getAdaptiveSize(40),
            height: context.getAdaptiveSize(40),
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.error_outline,
                size: context.getWidth(24),
                color: AppColors.primaryColor,
              );
            },
          ),
          SizedBox(height: context.getHeight(8)),
          Text(
            category.name,
            style: AppTextStyles.subTitle(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
