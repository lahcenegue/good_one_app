import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_strings.dart';
import '../../Theme/app_text_styles.dart';
import '../../../Utils/size_config.dart';
import '../Buttons/primary_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;
  final Color? iconColor;
  final double? iconSize;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showIcon = true,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.error_outline,
                size: iconSize ?? context.getWidth(48),
                color: iconColor ?? AppColors.oxblood,
              ),
              SizedBox(height: context.getHeight(16)),
            ],
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
                text: AppStrings.retry,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructor for common error states
  factory AppErrorWidget.network({VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: AppStrings.networkError,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.general({VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: AppStrings.generalError,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.custom({
    required String message,
    VoidCallback? onRetry,
    bool showIcon = true,
  }) {
    return AppErrorWidget(
      message: message,
      onRetry: onRetry,
      showIcon: showIcon,
    );
  }
}
