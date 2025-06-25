import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Base style generator with platform-aware sizing
  static TextStyle _baseStyle(
    BuildContext context, {
    required double fontSize,
    required FontWeight weight,
    required Color color,
    double? height,
  }) {
    return TextStyle(
      fontSize: _getConsistentFontSize(context, fontSize),
      fontWeight: weight,
      color: color,
      height: height,
      // Disable text scaling to ensure consistency
      textBaseline: TextBaseline.alphabetic,
    );
  }

  // Platform-aware font size calculation
  static double _getConsistentFontSize(BuildContext context, double fontSize) {
    // Adaptive sizing with platform-specific adjustments
    final adaptiveSize = context.getAdaptiveSize(fontSize);
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return adaptiveSize * 0.9; // Reduce iOS font size by 10%
    }
    return adaptiveSize;
  }

  // Heading Styles
  static TextStyle appBarTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 20,
        weight: FontWeight.w700,
        color: AppColors.blackText,
        height: 1.2,
      );

  static TextStyle title(BuildContext context) => _baseStyle(
        context,
        fontSize: 24,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.3,
      );

  static TextStyle title2(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.blackText,
        height: 1.25,
      );

  static TextStyle titleLarge(BuildContext context) => _baseStyle(
        context,
        fontSize: 18,
        weight: FontWeight.w600,
        color: AppColors.primaryColor,
        height: 1.25,
      );

  // Body Styles
  static TextStyle subTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w400,
        color: AppColors.blackText,
        height: 1.4,
      );

  static TextStyle text(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.textGray,
        height: 1.4,
      );

  static TextStyle bodyText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.blackText,
        height: 1.4,
      );

  static TextStyle bodyTextMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.4,
      );

  static TextStyle bodyTextBold(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.bold,
        color: AppColors.textDark,
        height: 1.4,
      );

  // Small Text Styles
  static TextStyle smallText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.textGray,
        height: 1.3,
      );

  static TextStyle caption(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.textMedium,
        height: 1.3,
      );

  static TextStyle captionMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.3,
      );

  // Button Styles
  static TextStyle buttonText(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w500,
        color: AppColors.whiteText,
        height: 1.2,
      );

  static TextStyle buttonTextMedium(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.whiteText,
        height: 1.2,
      );

  // Action Styles
  static TextStyle textButton(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.oxblood,
        height: 1.3,
      );

  static TextStyle linkText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.primaryColor,
        height: 1.3,
      );

  // Form Styles
  static TextStyle inputText(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w400,
        color: AppColors.blackText,
        height: 1.3,
      );

  static TextStyle hintText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.hintColor,
        height: 1.3,
      );

  static TextStyle labelText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.3,
      );

  static TextStyle floatingLabelText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.2,
      );

  static TextStyle errorText(BuildContext context) => _baseStyle(
        context,
        fontSize: 12,
        weight: FontWeight.w400,
        color: AppColors.oxblood,
        height: 1.2,
      );

  // Special Styles
  static TextStyle price(BuildContext context) => _baseStyle(
        context,
        fontSize: 20,
        weight: FontWeight.w700,
        color: AppColors.primaryColor,
        height: 1.2,
      );

  static TextStyle priceSmall(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: AppColors.primaryColor,
        height: 1.2,
      );

  static TextStyle rating(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.textGray,
        height: 1.3,
      );

  // Status Styles
  static TextStyle successText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.successDark,
        height: 1.3,
      );

  static TextStyle errorTextStyle(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.errorColor,
        height: 1.3,
      );

  static TextStyle warningText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.warningDark,
        height: 1.3,
      );

  static TextStyle infoText(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w500,
        color: AppColors.infoDark,
        height: 1.3,
      );

  // Language Selection Styles
  static TextStyle languageTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w500,
        color: AppColors.blackText,
        height: 1.25,
      );

  static TextStyle languageSubtitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: AppColors.textMedium,
        height: 1.3,
      );

  // Dynamic font size helpers
  static TextStyle dynamicText(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      _baseStyle(
        context,
        fontSize: fontSize,
        weight: fontWeight ?? FontWeight.w400,
        color: color ?? AppColors.blackText,
        height: height,
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
