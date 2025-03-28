import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/base_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

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
