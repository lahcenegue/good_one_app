import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Widgets/custom_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_colors.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Core/Utils/size_config.dart';
import '../../../Providers/auth_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Widgets/shared_auth_widgets.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Set context for translations
        auth.setContext(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.signUp,
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
                Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: AppTextStyles.title(context),
                ),
                SizedBox(height: context.getHeight(20)),
                _buildImagePicker(context, auth),
                SizedBox(height: context.getHeight(20)),
                _buildRegistrationForm(context, auth),
                if (auth.error != null)
                  SharedAuthWidgets.buildErrorMessage(context, auth.error!),
                _buildLoginSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectImage,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        Center(
          child: GestureDetector(
            onTap: () => _showImagePickerModal(context, auth),
            child: Container(
              width: context.getWidth(120),
              height: context.getWidth(120),
              decoration: BoxDecoration(
                color: AppColors.dimGray,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
                image: auth.selectedImage != null
                    ? DecorationImage(
                        image: FileImage(auth.selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: auth.selectedImage == null
                  ? Icon(
                      Icons.camera_alt,
                      size: context.getWidth(40),
                      color: AppColors.primaryColor,
                    )
                  : null,
            ),
          ),
        ),
        if (auth.imageError != null)
          Padding(
            padding: EdgeInsets.only(top: context.getHeight(8)),
            child: Text(
              auth.imageError!,
              style: AppTextStyles.text(context).copyWith(
                color: AppColors.oxblood,
              ),
            ),
          ),
      ],
    );
  }

  void _showImagePickerModal(
    BuildContext context,
    AuthProvider auth,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  auth.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  auth.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: auth.registrationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.fullNameController,
            label: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterFullName,
            validator: auth.validateFullName,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.emailController,
            label: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.enterEmail,
            validator: auth.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            validator: auth.validatePhone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildPasswordField(
            context,
            controller: auth.passwordController,
            label: AppLocalizations.of(context)!.password,
            hintText: AppLocalizations.of(context)!.enterPassword,
            obscurePassword: auth.obscurePassword,
            toggleVisibility: auth.togglePasswordVisibility,
            validator: auth.validatePassword,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildPasswordField(
            context,
            controller: auth.confirmPasswordController,
            label: AppLocalizations.of(context)!.retypePassword,
            hintText: AppLocalizations.of(context)!.retypePassword,
            obscurePassword: auth.obscureConfirmPassword,
            toggleVisibility: auth.toggleConfirmPasswordVisibility,
            validator: (value) => auth.validateConfirmPassword(
              value,
              auth.passwordController.text,
            ),
          ),
          SizedBox(height: context.getHeight(20)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.signUp,
            isLoading: auth.isLoading,
            onPressed: auth.register,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.getHeight(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.alreadyHaveAccount,
            style: AppTextStyles.text(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.signIn,
              style: AppTextStyles.subTitle(context).copyWith(
                color: AppColors.oxblood,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
