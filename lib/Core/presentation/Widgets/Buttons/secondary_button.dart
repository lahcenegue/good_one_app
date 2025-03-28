import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/base_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

class SecondaryButton extends BaseButton {
  final bool isPressed;

  const SecondaryButton({
    super.key,
    required super.text,
    required super.onPressed,
    this.isPressed = false,
    super.isLoading,
    super.width,
    super.height,
  }) : super(
          backgroundColor: AppColors.dimGray,
          textColor: Colors.black54,
        );

  @override
  Widget buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPressed ? const Color(0xFFFCCDCE) : AppColors.dimGray,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: isPressed ? AppColors.primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(
            context.getAdaptiveSize(8),
          ),
        ),
        elevation: 0,
      ),
      child: buildButtonText(context),
    );
  }
}

class SmallSecondaryButton extends SecondaryButton {
  const SmallSecondaryButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.isPressed,
  }) : super(
          width: 150,
          height: 45,
        );
}
