import 'package:flutter/material.dart';
import '../../../../Core/Constants/app_assets.dart';
import '../../../../Core/Constants/app_colors.dart';
import '../../../../Core/Themes/app_text_styles.dart';
import '../../../../Core/Utils/size_config.dart';

class SharedAuthWidgets {
  static Widget buildLogo(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.getHeight(20)),
        child: Image.asset(
          AppAssets.appNameImage,
          color: AppColors.primaryColor,
          height: context.getHeight(40),
        ),
      ),
    );
  }

  static Widget buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }

  static Widget buildErrorMessage(BuildContext context, String message) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: context.getHeight(16),
      ),
      padding: EdgeInsets.all(context.getWidth(12)),
      decoration: BoxDecoration(
        color: AppColors.oxblood.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.oxblood,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.oxblood,
            size: context.getWidth(24),
          ),
          SizedBox(width: context.getWidth(12)),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.text(context).copyWith(
                color: AppColors.oxblood,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscurePassword,
    required Function() toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        buildTextField(
          context,
          controller: controller,
          hintText: hintText,
          obscureText: obscurePassword,
          validator: validator,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ],
    );
  }

  static Widget buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        buildTextField(
          context,
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
}
