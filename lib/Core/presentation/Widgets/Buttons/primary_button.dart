import 'package:flutter/material.dart';
import '../../Resources/app_colors.dart';
import '../../../Utils/size_config.dart';
import 'base_button.dart';

class PrimaryButton extends BaseButton {
  const PrimaryButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.width,
    super.height,
  });

  @override
  Widget buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.getAdaptiveSize(8),
          ),
        ),
        elevation: 0,
      ),
      child:
          isLoading ? buildLoadingIndicator(context) : buildButtonText(context),
    );
  }
}

class SmallPrimaryButton extends PrimaryButton {
  const SmallPrimaryButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
  }) : super(
          width: 150,
          height: 45,
        );
}
