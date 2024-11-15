import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';

ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  // Background color
  scaffoldBackgroundColor: AppColors.backgroundColor,

  // AppBar theme
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: AppColors.backgroundColor,
    elevation: 0,
  ),

  // Form field theme
  inputDecorationTheme: InputDecorationTheme(
    // Fill properties
    filled: true,
    fillColor: AppColors.dimGray,

    // Padding and spacing
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),

    // Text styles
    hintStyle: const TextStyle(
      color: AppColors.hintColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    errorStyle: const TextStyle(
      color: AppColors.oxblood,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),

    // Borders
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: AppColors.oxblood,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: AppColors.oxblood,
        width: 1,
      ),
    ),

    // Other properties
    isDense: true,
    alignLabelWithHint: true,

    // Suffix icon theme
    suffixIconColor: AppColors.hintColor,

    // Focused state styling
    focusColor: Colors.transparent,
    hoverColor: Colors.transparent,
  ),
);
