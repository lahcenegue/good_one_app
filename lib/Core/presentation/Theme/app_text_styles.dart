import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Base style generator
  static TextStyle _baseStyle(
    BuildContext context, {
    required double fontSize,
    required FontWeight weight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(fontSize),
      fontWeight: weight,
      color: color,
    );
  }

  // Heading Styles
  static TextStyle appBarTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 20,
        weight: FontWeight.w700,
        color: AppColors.blackText,
      );

  static TextStyle title(BuildContext context) => _baseStyle(
        context,
        fontSize: 24,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  static TextStyle title2(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.blackText,
      );

  static TextStyle titleLarge(BuildContext context) => _baseStyle(
        context,
        fontSize: 18,
        weight: FontWeight.w600,
        color: AppColors.primaryColor,
      );

  // Body Styles
  static TextStyle subTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w400,
        color: AppColors.blackText,
      );

  static TextStyle text(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.textGray,
      );

  static TextStyle bodyText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.blackText,
      );

  static TextStyle bodyTextMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  static TextStyle bodyTextBold(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.bold,
        color: AppColors.textDark,
      );

  // Small Text Styles
  static TextStyle smallText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.textGray,
      );

  static TextStyle caption(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.textMedium,
      );

  static TextStyle captionMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  // Button Styles
  static TextStyle buttonText(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w500,
        color: AppColors.whiteText,
      );

  static TextStyle buttonTextMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.whiteText,
      );

  // Action Styles
  static TextStyle textButton(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.oxblood,
      );

  static TextStyle linkText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.primaryColor,
      );

  // Form Styles
  static TextStyle inputText(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w400,
        color: AppColors.blackText,
      );

  static TextStyle hintText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.hintColor,
      );

  static TextStyle labelText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  static TextStyle floatingLabelText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  static TextStyle errorText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.oxblood,
      );

  // Special Styles
  static TextStyle price(BuildContext context) => _baseStyle(
        context,
        fontSize: 20,
        weight: FontWeight.w700,
        color: AppColors.primaryColor,
      );

  static TextStyle priceSmall(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.primaryColor,
      );

  static TextStyle rating(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.textGray,
      );

  // Status Styles
  static TextStyle successText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.successDark,
      );

  static TextStyle errorTextStyle(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.errorColor,
      );

  static TextStyle warningText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.warningDark,
      );

  static TextStyle infoText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.infoDark,
      );

  // Language Selection Styles
  static TextStyle languageTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w500,
        color: AppColors.blackText,
      );

  static TextStyle languageSubtitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.textMedium,
      );

  // Dynamic font size helpers
  static TextStyle dynamicText(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      _baseStyle(
        context,
        fontSize: fontSize,
        weight: fontWeight ?? FontWeight.w400,
        color: color ?? AppColors.blackText,
      );

  // Helper methods
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  static TextStyle withSize(TextStyle style, double size) =>
      style.copyWith(fontSize: size);

  static TextStyle withWeight(TextStyle style, FontWeight weight) =>
      style.copyWith(fontWeight: weight);

  static TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withValues(alpha: opacity));

  static TextStyle withHeight(TextStyle style, double height) =>
      style.copyWith(height: height);
  static TextStyle italic(TextStyle style) =>
      style.copyWith(fontStyle: FontStyle.italic);
}
