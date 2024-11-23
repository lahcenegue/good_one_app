import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import '../Constants/app_colors.dart';
import '../Themes/app_text_styles.dart';
import '../Widgets/custom_buttons.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.getWidth(48),
              color: AppColors.oxblood,
            ),
            SizedBox(height: context.getHeight(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.text(context).copyWith(
                color: AppColors.oxblood,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.getHeight(16)),
              SmallPrimaryButton(
                text: 'Retry',
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
