import 'package:flutter/material.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:provider/provider.dart';

import '../../../Core/Navigation/app_routes.dart';
import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Core/Navigation/navigation_service.dart';
import '../../../Core/Utils/size_config.dart';
import '../../../Providers/auth_provider.dart';
import '../Widgets/shared_auth_widgets.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.signIn,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(20),
              vertical: context.getHeight(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SharedAuthWidgets.buildLogo(context),
                _buildLoginForm(
                  context,
                  auth,
                ),
                if (auth.error != null)
                  SharedAuthWidgets.buildErrorMessage(context, auth.error!),
                _buildSignUpSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: auth.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.emailController,
            label: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.enterEmail,
            validator: (value) => auth.validateEmail(value, context),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildPasswordField(
            context,
            controller: auth.passwordController,
            label: AppLocalizations.of(context)!.password,
            hintText: AppLocalizations.of(context)!.enterPassword,
            obscurePassword: auth.obscurePassword,
            toggleVisibility: auth.togglePasswordVisibility,
            validator: (value) => auth.validatePassword(value, context),
          ),
          _buildForgotPassword(context),
          SizedBox(height: context.getHeight(20)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.loginButton,
            isLoading: auth.isLoading,
            onPressed: () => auth.login(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextButton(
        onPressed: () {
          //TODO

          // NavigationService.navigateTo(AppRoutes.forgotPassword);
        },
        child: Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: AppTextStyles.textButton(context),
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
              NavigationService.navigateTo(AppRoutes.register);
            },
            child: Text(
              AppLocalizations.of(context)!.signUp,
              style: AppTextStyles.textButton(context),
            ),
          ),
        ],
      ),
    );
  }
}
