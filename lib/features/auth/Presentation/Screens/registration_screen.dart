import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
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
                if (auth.error != null) AppErrorWidget(message: auth.error!),
                _buildLoginSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    AuthProvider auth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.profilePicture,
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
              style: AppTextStyles.textButton(context),
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
                  auth.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  auth.pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(
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
            controller: auth.fullNameController,
            label: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterFullName,
            validator: (value) => auth.validateFullName(value, context),
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.emailController,
            label: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.enterEmail,
            validator: (value) => auth.validateEmail(value, context),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.getHeight(16)),
          FutureBuilder<String?>(
              future: StorageManager.getString(StorageKeys.accountTypeKey),
              builder: (context, snapshot) {
                final accountType = snapshot.data;
                if (accountType == AppConfig.service) {
                  return Column(
                    children: [
                      SizedBox(height: context.getHeight(16)),
                      _buildLocationFields(context, auth),
                      SizedBox(height: context.getHeight(16)),
                    ],
                  );
                }
                return SizedBox.shrink();
              }),
          SharedAuthWidgets.buildInputField(
            context,
            controller: auth.phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            validator: (value) => auth.validatePhone(value, context),
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
            validator: (value) => auth.validatePassword(value, context),
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
              context,
              value,
              auth.passwordController.text,
            ),
          ),
          SizedBox(height: context.getHeight(20)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.signUp,
            isLoading: auth.isLoading,
            onPressed: () async {
              await auth.register(context);
            },
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
            AppLocalizations.of(context)!.hasAccount,
            style: AppTextStyles.text(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.login,
              style: AppTextStyles.textButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFields(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.country,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.getHeight(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.dimGray,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: auth.selectedCountry,
              hint: Text(
                AppLocalizations.of(context)!.selectCountry,
                style: AppTextStyles.text(context),
              ),
              items: AppConfig.countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(
                    country,
                    style: AppTextStyles.subTitle(context),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                auth.setCountry(newValue);
              },
            ),
          ),
        ),
        SizedBox(height: context.getHeight(16)),
        Text(
          AppLocalizations.of(context)!.city,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.getHeight(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.dimGray,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: auth.selectedCity,
              hint: Text(
                AppLocalizations.of(context)!.selectCity,
                style: AppTextStyles.text(context),
              ),
              items: auth.availableCities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: AppTextStyles.subTitle(context),
                  ),
                );
              }).toList(),
              onChanged: auth.selectedCountry != null
                  ? (String? newValue) {
                      auth.setCity(newValue);
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
