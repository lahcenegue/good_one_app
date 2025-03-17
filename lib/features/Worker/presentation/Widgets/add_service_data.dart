import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/category_dropdown_widget.dart';
import 'package:good_one_app/Features/auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddServiceData extends StatelessWidget {
  const AddServiceData({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLicenseCertificate(context, workerManager),
              SizedBox(height: context.getHeight(16)),
              CategoryDropdownWidget<CategoryModel>(
                label: 'Select Service Type',
                hint: 'Select Service Type',
                value: workerManager.selectedCategory,
                items: workerManager.categories,
                onChanged: workerManager.setCategory,
              ),
              SizedBox(height: context.getHeight(8)),
              CategoryDropdownWidget<SubcategoryModel>(
                label: 'Select SupService Type',
                hint: 'Select SupService Type',
                value: workerManager.selectedSubcategory,
                items: workerManager.selectedCategory?.subcategories ?? [],
                onChanged: workerManager.setSubcategory,
              ),
              SizedBox(height: context.getHeight(8)),
              SharedAuthWidgets.buildInputField(
                context,
                controller: workerManager.servicePriceController,
                label: 'Years of expiriance',
                hintText: 'Enter your expiriance',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: context.getHeight(8)),
              SharedAuthWidgets.buildInputField(
                context,
                controller: workerManager.servicePriceController,
                label: 'Service price par hour',
                hintText: 'Enter price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: context.getHeight(8)),
              SharedAuthWidgets.buildInputField(
                context,
                controller: workerManager.servicePriceController,
                label: 'Descreption',
                hintText: 'Enter a discreption',
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLicenseCertificate(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License cetificate if you have ',
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        Center(
          child: GestureDetector(
            onTap: () => _showImagePickerModal(context, workerManager),
            child: workerManager.selectedImage == null
                ? Container(
                    width: context.getWidth(120),
                    height: context.getWidth(120),
                    decoration: BoxDecoration(
                      color: AppColors.dimGray,
                      border: Border.all(
                        color: AppColors.primaryColor,
                      ),
                      borderRadius:
                          BorderRadius.circular(context.getAdaptiveSize(20)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.photo_camera,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                : Container(
                    width: context.getWidth(180),
                    height: context.getWidth(240),
                    decoration: BoxDecoration(
                      color: AppColors.dimGray,
                      borderRadius:
                          BorderRadius.circular(context.getAdaptiveSize(20)),
                      border: Border.all(
                        color: AppColors.primaryColor,
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
                  workerManager.pickImage(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  workerManager.pickImage(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
