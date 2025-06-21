import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors._(); // Private constructor to prevent instantiation

  // Brand Colors
  static const Color primaryColor = Color(0xFFf70303);
  static const Color oxblood = Color(0xFF4E0103);

  // UI Colors
  static const Color backgroundColor = Colors.white;
  static const Color dimGray = Color(0xFFF6F6F6);
  static const Color lightGray = Color(0xFFF5F5F5); // Colors.grey.shade50
  static const Color mediumGray = Color(0xFFEEEEEE); // Colors.grey[100]

  // Text Colors
  static const Color hintColor = Color(0xFF6D6D6D);
  static const Color textGray = Color(0xFF838383);
  static const Color textDark = Color(0xFF424242); // Colors.grey.shade700
  static const Color textMedium = Color(0xFF757575); // Colors.grey.shade500
  static const Color textLight = Color(0xFF9E9E9E); // Colors.grey[400]
  static const Color textSecondary = Color(0xFF666666); // Colors.grey[600]
  static const Color blackText = Color(0xFF000000); // Colors.black
  static const Color whiteText = Color(0xFFFFFFFF); // Colors.white
  static const Color blackAlpha87 = Color(0xDD000000); // Colors.black87

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Colors.green
  static const Color successLight = Color(0xFFC8E6C9); // Colors.green[50]
  static const Color successDark = Color(0xFF2E7D32); // Colors.green[600]
  static const Color errorColor = Color(0xFFF44336); // Colors.red
  static const Color errorLight =
      Color(0xFFFFEBEE); // Colors.red.withValues(alpha: 0.1)
  static const Color errorDark = Color(0xFFEF5350); // Colors.red.shade400
  static const Color warningColor = Color(0xFFFF9800); // Colors.orange
  static const Color warningLight = Color(0xFFFFF3E0); // Colors.orange[50]
  static const Color warningDark = Color(0xFFF57C00); // Colors.orange[600]
  static const Color infoColor = Color(0xFF2196F3); // Colors.blue
  static const Color infoDark = Color(0xFF1976D2); // Colors.blue[600]

  // Chart Colors
  static const Color chartPending = Color(0xFFFF9800); // Colors.orange
  static const Color chartCompleted = Color(0xFF4CAF50); // Colors.green
  static const Color chartInactive = Color(0xFF9E9E9E); // Colors.grey

  // Pricing Type Colors
  static const Color hourlyColor = Color(0xFF2196F3); // Colors.blue
  static const Color dailyColor = Color(0xFF4CAF50); // Colors.green
  static const Color fixedColor = Color(0xFFFF9800); // Colors.orange
  // Special Colors
  static const Color rating = Color(0xFFfbdc00);
  static const Color amber = Color(0xFFFFC107); // Colors.amber
  static const Color amberDark = Color(0xFFFF8F00); // Colors.amber.shade600
  static const Color amberLight = Color(0xFFFFF8E1); // Colors.amber.shade700
  static const Color transparent = Color(0x00000000); // Colors.transparent

  // Border Colors
  static const Color borderGray = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color borderLight = Color(0xFFF5F5F5); // Colors.grey[50]

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Colors.grey.shade50
  static const Color backgroundCard = Color(0xFFFFFFFF); // Colors.white
  static const Color backgroundOverlay =
      Color(0x1A000000); // Colors.grey.withValues(alpha: 0.1)

  // Connection Status Colors
  static const Color connectedColor = Color(0xFF4CAF50); // Colors.green
  static const Color disconnectedColor = Color(0xFFF44336); // Colors.red
}
