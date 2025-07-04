import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

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
        padding: EdgeInsets.all(context.getAdaptiveSize(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                text: AppLocalizations.of(context)!.retry,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructor for common error states
  factory AppErrorWidget.network(
      {required BuildContext context, VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: AppLocalizations.of(context)!.networkError,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.general(
      {required BuildContext context, VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: AppLocalizations.of(context)!.generalError,
      onRetry: onRetry,
    );
  }

  factory AppErrorWidget.custom({
    required String message,
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      message: message,
      onRetry: onRetry,
    );
  }
}
