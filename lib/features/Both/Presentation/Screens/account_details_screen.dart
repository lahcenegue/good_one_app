import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/infrastructure/storage/storage_manager.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/resources/app_strings.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:good_one_app/Features/auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Providers/user_manager_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountDetailsScreen extends StatelessWidget {
  AccountDetailsScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        final user = userManager.userInfo;
        if (user == null) {
          return const Center(
            child: Text('User data not available'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.accountDetails,
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
                SizedBox(height: context.getHeight(20)),
                _buildImagePicker(context, userManager),
                if (userManager.imageError != null)
                  Padding(
                    padding: EdgeInsets.only(top: context.getHeight(8)),
                    child: Text(
                      userManager.imageError!,
                      style: AppTextStyles.text(context)
                          .copyWith(color: Colors.red),
                    ),
                  ),
                SizedBox(height: context.getHeight(20)),
                _buildAccountDetailsForm(context, userManager, user),
                if (userManager.error != null)
                  SharedAuthWidgets.buildErrorMessage(
                      context, userManager.error!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    UserManagerProvider userManager,
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
            onTap: () => _showImagePickerModal(context, userManager),
            child: userManager.selectedImage == null
                ? UserAvatar(
                    picture: userManager.userInfo?.picture,
                    size: context.getWidth(120),
                    backgroundColor: AppColors.dimGray,
                    iconColor: AppColors.primaryColor,
                  )
                : Container(
                    width: context.getWidth(120),
                    height: context.getWidth(120),
                    decoration: BoxDecoration(
                      color: AppColors.dimGray,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                      image: userManager.selectedImage != null
                          ? DecorationImage(
                              image: FileImage(userManager.selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerModal(
      BuildContext context, UserManagerProvider userManager) {
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
                  userManager.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  userManager.pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountDetailsForm(
    BuildContext context,
    UserManagerProvider userManager,
    UserInfo user,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedAuthWidgets.buildInputField(
            context,
            controller: userManager.fullNameController,
            label: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterFullName,
            validator: (value) => null,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: userManager.emailController,
            label: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.enterEmail,
            validator: (value) {
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: userManager.phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            validator: (value) {
              if (int.tryParse(value!) == null)
                return 'Please enter a valid phone number';
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: context.getHeight(16)),
          FutureBuilder(
            future: StorageManager.getString(StorageKeys.accountTypeKey),
            builder: (context, snapshot) {
              final accountType = snapshot.data;
              if (accountType == AppStrings.service) {
                return Column(
                  children: [
                    SharedAuthWidgets.buildInputField(
                      context,
                      controller: userManager.cityController,
                      label: AppLocalizations.of(context)!.city,
                      hintText: AppLocalizations.of(context)!.enterCity,
                      validator: (value) => null, // Make city optional
                    ),
                    SizedBox(height: context.getHeight(16)),
                    SharedAuthWidgets.buildInputField(
                      context,
                      controller: userManager.countryController,
                      label: AppLocalizations.of(context)!.country,
                      hintText: AppLocalizations.of(context)!.enterCountry,
                      validator: (value) => null, // Make country optional
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
          SizedBox(height: context.getHeight(24)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.update,
            isLoading: userManager.isLoading,
            onPressed: () async {
              await userManager.editAccount(context);
            },
          ),
        ],
      ),
    );
  }
}
