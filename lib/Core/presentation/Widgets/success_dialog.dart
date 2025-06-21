import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final VoidCallback onConfirm;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmText = 'Confirm',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          context.getAdaptiveSize(12),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(16)),
              child: Image.asset(
                AppAssets.success,
                width: context.getAdaptiveSize(250),
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            // Title
            Text(
              title,
              style: AppTextStyles.title(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(8)),
            // Description
            Text(
              description,
              style: AppTextStyles.text(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            // Buttons
            PrimaryButton(
              text: confirmText,
              onPressed: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
