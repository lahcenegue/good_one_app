import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class WorkerAccountDetailsScreen extends StatelessWidget {
  WorkerAccountDetailsScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.accountDetails,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: _buildBody(context, workerManager),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WorkerManagerProvider workerManager) {
    final worker = workerManager.workerInfo;

    if (workerManager.isLoading && worker == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading account details..."),
          ],
        ),
      );
    }

    // Show loading if still initializing
    if (workerManager.isLoading || workerManager.isProfileLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loadingUserData,
              style: AppTextStyles.text(context),
            ),
          ],
        ),
      );
    }

    // If no worker data, provide retry mechanism
    if (worker == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Account information not available",
                style: AppTextStyles.title2(context),
              ),
              SizedBox(height: 16),
              PrimaryButton(
                text: AppLocalizations.of(context)!.retry,
                onPressed: () => workerManager.initialize(),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.back),
              ),
            ],
          ),
        ),
      );
    }
    // Show the normal content when data is available
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(20),
        vertical: context.getHeight(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.getHeight(20)),
          _buildImagePicker(context, workerManager),
          if (workerManager.imageError != null)
            Padding(
              padding: EdgeInsets.only(top: context.getHeight(8)),
              child: Text(
                workerManager.imageError!,
                style: AppTextStyles.text(context).copyWith(color: Colors.red),
              ),
            ),
          SizedBox(height: context.getHeight(20)),
          _buildAccountDetailsForm(
              context, workerManager, workerManager.workerInfo!),
          if (workerManager.profileError != null)
            AppErrorWidget(message: workerManager.profileError!),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    WorkerManagerProvider workerManager,
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
            onTap: () => _showImagePickerModal(context, workerManager),
            child: workerManager.selectedImage == null
                ? UserAvatar(
                    picture: workerManager.workerInfo?.picture,
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
                      image: workerManager.selectedImage != null
                          ? DecorationImage(
                              image: FileImage(workerManager.selectedImage!),
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
    BuildContext context,
    WorkerManagerProvider workerManager,
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
                  workerManager.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  workerManager.pickImage(context, ImageSource.gallery);
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
    WorkerManagerProvider workerManager,
    UserInfo user,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.fullNameController,
            label: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterFullName,
            validator: (value) => null,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.emailController,
            label: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.enterEmail,
            validator: (value) {
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                return AppLocalizations.of(context)!.invalidEmail;
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
            validator: (value) {
              if (int.tryParse(value!) == null) {
                return AppLocalizations.of(context)!.invalidPhone;
              }
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.cityController,
            label: AppLocalizations.of(context)!.city,
            hintText: AppLocalizations.of(context)!.enterCity,
            validator: (value) => null, // Make city optional
          ),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.countryController,
            label: AppLocalizations.of(context)!.country,
            hintText: AppLocalizations.of(context)!.enterCountry,
            validator: (value) => null, // Make country optional
          ),
          SizedBox(height: context.getHeight(24)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.update,
            isLoading: workerManager.isProfileLoading,
            onPressed: () async {
              // Clear previous profile errors before attempting
              workerManager.clearError('profile');

              final success = await workerManager.editAccount(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!
                            .profileUpdatedSuccessfully),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
