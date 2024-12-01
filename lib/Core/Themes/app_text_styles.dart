import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_colors.dart';

import '../Utils/size_config.dart';

class AppTextStyles {
  static TextStyle appBarTitle(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(20),
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
  }

  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(24),
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  static TextStyle title2(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(16),
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  static TextStyle subTitle(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(16),
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );
  }

  static TextStyle text(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(14),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF838383),
    );
  }

  static TextStyle textButton(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(14),
      fontWeight: FontWeight.w400,
      color: AppColors.oxblood,
    );
  }

  static TextStyle price(BuildContext context) {
    return TextStyle(
      fontSize: context.getAdaptiveSize(20),
      fontWeight: FontWeight.w700,
      color: AppColors.primaryColor,
    );
  }
}
