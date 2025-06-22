import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.login,
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
                if (auth.error != null) AppErrorWidget(message: auth.error!),
                _buildSignUpSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    AuthProvider auth,
  ) {
    return Form(
      key: _formKey,
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
          _buildForgotPassword(context, auth),
          SizedBox(height: context.getHeight(20)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.login,
            isLoading: auth.isLoading,
            onPressed: () => auth.login(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(
    BuildContext context,
    AuthProvider auth,
  ) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextButton(
        onPressed: () => _forgotPasswordShow(context, auth),
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

  void _forgotPasswordShow(
    BuildContext context,
    AuthProvider auth,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(25)),
            height: context.getHeight(320),
            width: context.screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.getAdaptiveSize(20)),
                topRight: Radius.circular(context.getAdaptiveSize(20)),
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _forgotPasswordFormKey,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enterEmail,
                      style: AppTextStyles.title2(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.getHeight(5)),
                    Text(
                      AppLocalizations.of(context)!.resetPasswordEnterEmail,
                      style: AppTextStyles.text(context),
                      textAlign: TextAlign.justify,
                    ),
                    SharedAuthWidgets.buildInputField(
                      context,
                      controller: auth.forgotPasswordEmailController,
                      label: '',
                      hintText: AppLocalizations.of(context)!.enterEmail,
                      validator: (value) => auth.validateEmail(value, context),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: context.getHeight(25)),
                    PrimaryButton(
                      text: AppLocalizations.of(context)!.confirm,
                      isLoading: auth.isLoading,
                      onPressed: () async {
                        if (_forgotPasswordFormKey.currentState!.validate()) {
                          // Using local form key
                          Navigator.pop(
                              context); // Close the bottom sheet first
                          await auth.sendOtp(isForPasswordReset: true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
