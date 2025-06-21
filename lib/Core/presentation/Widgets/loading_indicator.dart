import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getWidth(20)),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
