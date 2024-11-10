import 'package:flutter/material.dart';

import '../../Core/Constants/app_assets.dart';
import '../../Core/Constants/app_colors.dart';
import '../../Core/Utils/size_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              _buildDecorationCircle(
                context: context,
                top: -100,
                left: -100,
                size: 280,
                opacity: 0.15,
              ),
              _buildDecorationCircle(
                context: context,
                bottom: -100,
                right: -180,
                size: 320,
                opacity: 0.20,
              ),
              // Center(
              //   child: Image.asset(
              //     AppAssets.logo,
              //     width: context.getWidth(300),
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationCircle({
    required BuildContext context,
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: context.getWidth(size),
        height: context.getWidth(size),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 24,
            color: const Color(0xFF4e0103).withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}
