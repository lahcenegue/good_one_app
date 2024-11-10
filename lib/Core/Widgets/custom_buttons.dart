import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import '../Constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.getWidth(50),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.adaptiveSize(8, context),
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: context.getAdaptiveSize(20),
                width: context.getAdaptiveSize(20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.getAdaptiveSize(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class SmallPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const SmallPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.getWidth(150),
      height: context.getWidth(45),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.adaptiveSize(8, context),
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: context.getAdaptiveSize(20),
                width: context.getAdaptiveSize(20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.getAdaptiveSize(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class SmallSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const SmallSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.getWidth(150),
      height: context.getWidth(45),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.adaptiveSize(8, context),
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: context.getAdaptiveSize(20),
                width: context.getAdaptiveSize(20),
                child: const CircularProgressIndicator(
                  color: Color(0xFF555555),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: context.getAdaptiveSize(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
