import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/User/models/service_category.dart';

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
        width: context.getAdaptiveSize(110),
        height: context.getAdaptiveSize(103),
        decoration: BoxDecoration(
          color: AppColors.dimGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildServiceIcon(context),
            SizedBox(height: context.getHeight(8)),
            _buildServiceName(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context) {
    return SizedBox(
      width: context.getWidth(40),
      height: context.getWidth(40),
      child: category.image.isNotEmpty
          ? ClipRRect(
              child: Image.network(
                '${ApiEndpoints.imageBaseUrl}/${category.image}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorIcon(context),
              ),
            )
          : _buildErrorIcon(context),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    return Icon(
      Icons.handyman_outlined,
      size: context.getAdaptiveSize(24),
      color: AppColors.primaryColor,
    );
  }

  Widget _buildServiceName(BuildContext context) {
    return Text(
      category.name,
      style: AppTextStyles.subTitle(context),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
