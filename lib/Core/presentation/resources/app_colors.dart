import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors._(); // Private constructor to prevent instantiation

  // Brand Colors
  static const Color primaryColor = Color(0xFFf70303);
  static const Color oxblood = Color(0xFF4E0103);

  // UI Colors
  static const Color backgroundColor = Colors.white;
  static const Color dimGray = Color(0xFFF6F6F6);

  // Text Colors
  static const Color hintColor = Color(0xFF6D6D6D);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  static const Color rating = Color(0xFFfbdc00);
}
