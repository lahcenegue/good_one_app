import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Models/service_category.dart';

class ServiceGridItem extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback? onTap;

  const ServiceGridItem({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(4)),
        width: context.getAdaptiveSize(110),
        decoration: BoxDecoration(
          color: AppColors.dimGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildServiceIcon(context),
            SizedBox(height: context.getHeight(10)), // Increased spacing
            _buildServiceName(context),
            SizedBox(height: context.getHeight(6)), // Add bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context) {
    return SizedBox(
      width: context.getWidth(55),
      height: context.getAdaptiveSize(40),
      child: category.image.isNotEmpty
          ? Image.network(
              '${ApiEndpoints.imageBaseUrl}/${category.image}',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildErrorIcon(context),
            )
          : _buildErrorIcon(context),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    return Icon(
      Icons.handyman_outlined,
      size: context.getAdaptiveSize(40),
      color: AppColors.primaryColor,
    );
  }

  Widget _buildServiceName(BuildContext context) {
    // Dynamic font size based on name length
    final double fontSize = category.name.length > 15
        ? context.getAdaptiveSize(12)
        : category.name.length > 10
            ? context.getAdaptiveSize(13)
            : context.getAdaptiveSize(14);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.getWidth(8)),
      child: Text(
        category.name,
        style: AppTextStyles.subTitle(context).copyWith(
          fontSize: fontSize,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
