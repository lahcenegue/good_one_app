import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/secondary_button.dart';

import '../resources/app_assets.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmText = 'Confirm',
    this.cancelText = 'Close',
    required this.onConfirm,
    required this.onCancel,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: context.getWidth(120),
                  child: SmallPrimaryButton(
                    text: confirmText,
                    onPressed: onConfirm,
                  ),
                ),
                SizedBox(
                  width: context.getWidth(120),
                  child: SmallSecondaryButton(
                    text: cancelText,
                    onPressed: onCancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
