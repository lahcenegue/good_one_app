import 'package:flutter/material.dart';

class SizeConfig {
  const SizeConfig._(); // Private constructor

  // Design size constants
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Screen dimensions
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // Proportionate scaling
  static double getProportionateScreenWidth(
      double inputWidth, BuildContext context) {
    double scaleFactor = _getWidthScaleFactor(context);
    double responsiveWidth = inputWidth * scaleFactor;
    return responsiveWidth.clamp(inputWidth * 0.8, inputWidth * 1.4);
  }

  static double getProportionateScreenHeight(
      double inputHeight, BuildContext context) {
    double scaleFactor = _getHeightScaleFactor(context);
    double responsiveHeight = inputHeight * scaleFactor;
    return responsiveHeight.clamp(inputHeight * 0.8, inputHeight * 1.4);
  }

  static double adaptiveSize(double size, BuildContext context) {
    double scaleFactor = _getWidthScaleFactor(context);
    double responsiveSize = size * scaleFactor;
    return responsiveSize.clamp(size * 0.8, size * 1.4);
  }

  // Device type detection
  static bool isMobile(BuildContext context) =>
      width(context) < mobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      width(context) >= mobileBreakpoint && width(context) < tabletBreakpoint;
  static bool isDesktop(BuildContext context) =>
      width(context) >= tabletBreakpoint;

  // Responsive values
  static double getResponsiveValue({
    required BuildContext context,
    required double small,
    required double medium,
    required double large,
  }) {
    if (isMobile(context)) return small;
    if (isTablet(context)) return medium;
    return large;
  }

  // Device information
  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.orientationOf(context);
  static bool isLandscape(BuildContext context) =>
      getOrientation(context) == Orientation.landscape;
  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.paddingOf(context);
  static double bottomInset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;
  static double devicePixelRatio(BuildContext context) =>
      MediaQuery.devicePixelRatioOf(context);
  static double textScaleFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0);

  // Brightness
  static Brightness brightness(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context);
  static bool isDarkMode(BuildContext context) =>
      brightness(context) == Brightness.dark;

  // Scale factors
  static double _getWidthScaleFactor(BuildContext context) =>
      width(context) / designWidth;
  static double _getHeightScaleFactor(BuildContext context) =>
      height(context) / designHeight;

  // Default sizes
  static double defaultSize(BuildContext context) =>
      isLandscape(context) ? height(context) * 0.024 : width(context) * 0.024;
}

// Extension for more convenient usage
extension SizeConfigExtension on BuildContext {
  // Screen dimensions
  double get screenWidth => SizeConfig.width(this);
  double get screenHeight => SizeConfig.height(this);

  // Proportionate sizing
  double getWidth(double width) =>
      SizeConfig.getProportionateScreenWidth(width, this);
  double getHeight(double height) =>
      SizeConfig.getProportionateScreenHeight(height, this);
  double getAdaptiveSize(double size) => SizeConfig.adaptiveSize(size, this);

  // Device information
  bool get isLandscape => SizeConfig.isLandscape(this);
  EdgeInsets get safePadding => SizeConfig.safePadding(this);
  double get bottomInset => SizeConfig.bottomInset(this);
  double get devicePixelRatio => SizeConfig.devicePixelRatio(this);
  double get textScaleFactor => SizeConfig.textScaleFactor(this);

  // Device type
  bool get isMobile => SizeConfig.isMobile(this);
  bool get isTablet => SizeConfig.isTablet(this);
  bool get isDesktop => SizeConfig.isDesktop(this);

  // Brightness
  bool get isDarkMode => SizeConfig.isDarkMode(this);

  // Responsive value helper
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
