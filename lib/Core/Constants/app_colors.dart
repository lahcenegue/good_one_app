import 'package:flutter/material.dart';

abstract class AppColors {
  // Colors
  static const Color primaryColor = Color(0xFFf70303);
  static const Color secondaryColor = Color(0xFFFF5761);
  static const Color backgroundColor = Colors.white;
  static const Color secondaryButtonColor = Color(0xFFF6F6F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondaryColor, primaryColor],
  );
}
