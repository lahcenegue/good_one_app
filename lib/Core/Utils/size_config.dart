import 'package:flutter/material.dart';

class SizeConfig {
  // Get screen width
  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  // Get screen height
  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  // Calculate proportionate width
  static double getProportionateScreenWidth(
      double inputWidth, BuildContext context) {
    double scaleFactor = _getWidthScaleFactor(context);
    double responsiveWidth = inputWidth * scaleFactor;

    return responsiveWidth.clamp(inputWidth * 0.8, inputWidth * 1.4);
  }

  // Calculate proportionate height
  static double getProportionateScreenHeight(
      double inputHeight, BuildContext context) {
    double scaleFactor = _getHeightScaleFactor(context);
    double responsiveHeight = inputHeight * scaleFactor;

    return responsiveHeight.clamp(inputHeight * 0.8, inputHeight * 1.4);
  }

  // Calculate adaptive size (can be used for padding, margin, etc.)
  static double adaptiveSize(double size, BuildContext context) {
    double scaleFactor = _getWidthScaleFactor(context);
    double responsiveSize = size * scaleFactor;

    return responsiveSize.clamp(size * 0.8, size * 1.4);
  }

  // Default Sizes
  static double defaultSize(BuildContext context) {
    return isLandscape(context)
        ? height(context) * 0.024
        : width(context) * 0.024;
  }

  // Responsive Values
  static double getResponsiveValue({
    required BuildContext context,
    required double small,
    required double medium,
    required double large,
  }) {
    double deviceWidth = width(context);
    if (deviceWidth < 600) return small;
    if (deviceWidth < 1200) return medium;
    return large;
  }

  // Device Information
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context);
  }

  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.paddingOf(context);
  }

  static double bottomInset(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom;
  }

  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.devicePixelRatioOf(context);
  }

  static double textScaleFactor(BuildContext context) {
    return MediaQuery.textScaleFactorOf(context);
  }

  // Brightness
  static Brightness brightness(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context);
  }

  static bool isDarkMode(BuildContext context) {
    return brightness(context) == Brightness.dark;
  }

// Scale Factors
  static double _getWidthScaleFactor(BuildContext context) {
    return MediaQuery.sizeOf(context).width / 375.0;
  }

  static double _getHeightScaleFactor(BuildContext context) {
    return MediaQuery.sizeOf(context).height / 812.0;
  }
}

// Extension for more convenient usage in widgets
extension SizeConfigExtension on BuildContext {
  // Screen Dimensions
  double get screenWidth => SizeConfig.width(this);
  double get screenHeight => SizeConfig.height(this);

  // Proportionate Sizing
  double getWidth(double width) =>
      SizeConfig.getProportionateScreenWidth(width, this);
  double getHeight(double height) =>
      SizeConfig.getProportionateScreenHeight(height, this);
  double getAdaptiveSize(double size) => SizeConfig.adaptiveSize(size, this);

  // Device Information
  bool get isLandscape => SizeConfig.isLandscape(this);
  EdgeInsets get safePadding => SizeConfig.safePadding(this);
  double get bottomInset => SizeConfig.bottomInset(this);
  double get devicePixelRatio => SizeConfig.devicePixelRatio(this);
  double get textScaleFactor => SizeConfig.textScaleFactor(this);

  // Brightness
  bool get isDarkMode => SizeConfig.isDarkMode(this);

  // Responsive Value Helper
  double responsiveValue({
    required double small,
    required double medium,
    required double large,
  }) =>
      SizeConfig.getResponsiveValue(
        context: this,
        small: small,
        medium: medium,
        large: large,
      );
}
