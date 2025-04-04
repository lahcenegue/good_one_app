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

  // Other Colors
  static const Color rating = Color(0xFFfbdc00);
}
