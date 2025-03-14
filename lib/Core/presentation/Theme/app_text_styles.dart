import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';

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
        color: Colors.black,
      );

  static TextStyle title(BuildContext context) => _baseStyle(
        context,
        fontSize: 24,
        weight: FontWeight.w500,
        color: Colors.black,
      );

  static TextStyle title2(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w600,
        color: Colors.black,
      );

  // Body Styles
  static TextStyle subTitle(BuildContext context) => _baseStyle(
        context,
        fontSize: 16,
        weight: FontWeight.w400,
        color: Colors.black,
      );

  static TextStyle text(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
        weight: FontWeight.w400,
        color: const Color(0xFF838383),
      );

  // Action Styles
  static TextStyle textButton(BuildContext context) => _baseStyle(
        context,
        fontSize: 14,
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

  // Helper methods
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
  static TextStyle withSize(TextStyle style, double size) =>
      style.copyWith(fontSize: size);
  static TextStyle withWeight(TextStyle style, FontWeight weight) =>
      style.copyWith(fontWeight: weight);
}
