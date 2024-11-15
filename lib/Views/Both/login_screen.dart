import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_colors.dart';
import 'package:good_one_app/Core/Widgets/custom_buttons.dart';
import 'package:provider/provider.dart';

import '../../Core/Themes/app_text_styles.dart';
import '../../Core/Utils/size_config.dart';
import '../../Core/Constants/app_assets.dart';
import '../../Providers/auth_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.signIn,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(20),
                  vertical: context.getHeight(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(context),
                    _buildLoginForm(context, authProvider),
                    // _buildSocialLogin(context),
                    _buildSignUpSection(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
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

  Widget _buildLoginForm(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.email,
          style: AppTextStyles.title(context).copyWith(
            fontSize: context.getAdaptiveSize(16),
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        _buildTextField(
          context,
          AppLocalizations.of(context)!.enterEmail,
          false,
          TextInputType.emailAddress,
        ),
        SizedBox(height: context.getHeight(16)),
        Text(
          AppLocalizations.of(context)!.password,
          style: AppTextStyles.title(context).copyWith(
            fontSize: context.getAdaptiveSize(16),
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        _buildTextField(
          context,
          AppLocalizations.of(context)!.enterPassword,
          true,
          TextInputType.text,
        ),
        _buildForgotPassword(context),
        SizedBox(height: context.getHeight(20)),
        PrimaryButton(
          text: AppLocalizations.of(context)!.login,
          isLoading: authProvider.isLoading,
          onPressed: () async {
            // Handle login
          },
        ),
        SizedBox(height: context.getHeight(20)),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String hint,
    bool isPassword,
    TextInputType keyboardType,
  ) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon:
            isPassword ? const Icon(Icons.remove_red_eye_outlined) : null,
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        child: Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: AppTextStyles.text(context).copyWith(
            color: AppColors.oxblood,
            fontSize: context.getAdaptiveSize(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.getHeight(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.noAccount,
            style: AppTextStyles.text(context),
          ),
          TextButton(
            onPressed: () {
              // Navigate to sign up
            },
            child: Text(
              AppLocalizations.of(context)!.signUp,
              style: AppTextStyles.text(context).copyWith(
                color: AppColors.oxblood,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
