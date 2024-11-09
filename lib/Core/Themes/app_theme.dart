import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';

ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.backgroundColor,

  //AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundColor,
  ),
);
