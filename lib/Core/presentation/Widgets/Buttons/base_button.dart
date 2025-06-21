import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

abstract class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color textColor;

  const BaseButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? context.getWidth(50),
      child: buildButton(context),
    );
  }

  Widget buildButton(BuildContext context);

  Widget buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      height: context.getAdaptiveSize(20),
      width: context.getAdaptiveSize(20),
      child: CircularProgressIndicator(
        color: textColor,
        strokeWidth: 2,
      ),
    );
  }

  Widget buildButtonText(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.buttonText(context).copyWith(
        color: textColor,
      ),
    );
  }
}
