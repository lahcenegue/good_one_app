import 'package:flutter/material.dart';
import '../Resources/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        // Colors
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          error: AppColors.oxblood,
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dimGray,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
          border: _defaultBorder(),
          enabledBorder: _defaultBorder(),
          focusedBorder: _defaultBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          isDense: true,
          alignLabelWithHint: true,
          suffixIconColor: AppColors.hintColor,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  static OutlineInputBorder _defaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    );
  }

  static OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: AppColors.oxblood,
        width: 1,
      ),
    );
  }
}
