import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/my_services_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/category_dropdown_widget.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditService extends StatefulWidget {
  final MyServicesModel service;
  const EditService({super.key, required this.service});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkerManagerProvider>(context, listen: false)
          .fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.isServiceLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.screenWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildServiceDetailsStep(workerManager),
                          SizedBox(height: context.getHeight(32)),
                          _buildGalleryImagesSection(context, workerManager),
                          SizedBox(height: context.getHeight(32)),
                          PrimaryButton(
                            text: AppLocalizations.of(context)!.save,
                            onPressed: () async {
                              await workerManager.createAndEditService(
                                  isEditing: true);
                            },
                            width: context.getWidth(150),
                          ),
                          if (workerManager.addServiceError != null)
                            AppErrorWidget(
                              message: workerManager.addServiceError!,
                              onRetry: () {},
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.edit, //TODO edit service
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildServiceDetailsStep(WorkerManagerProvider workerManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.editServiceDetails,
          style: AppTextStyles.title(context).copyWith(fontSize: 24),
        ),
        SizedBox(height: context.getHeight(16)),
        CategoryDropdownWidget<CategoryModel>(
          label: AppLocalizations.of(context)!.selectServiceCategory,
          hint: AppLocalizations.of(context)!.chooseServiceCategory,
          value: workerManager.selectedCategory,
          items: workerManager.categories,
          onChanged: (category) {
            workerManager.setCategory(category);
          },
        ),
        SizedBox(height: context.getHeight(16)),
        CategoryDropdownWidget<SubcategoryModel>(
          label: AppLocalizations.of(context)!.selectSubcategory,
          hint: AppLocalizations.of(context)!.chooseSubcategory,
          value: workerManager.selectedSubcategory,
          items: workerManager.selectedCategory?.subcategories ?? [],
          onChanged: (subcategory) {
            workerManager.setSubcategory(subcategory);
          },
        ),
        SizedBox(height: context.getHeight(16)),
        SharedAuthWidgets.buildInputField(
          context,
          controller: workerManager.descriptionController,
          label: AppLocalizations.of(context)!.serviceDescription,
          hintText: AppLocalizations.of(context)!.provideDetailedDescription,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: context.getHeight(16)),
        SharedAuthWidgets.buildInputField(
          context,
          controller: workerManager.servicePriceController,
          label: AppLocalizations.of(context)!.servicePricePerHour,
          hintText: AppLocalizations.of(context)!.enterPrice,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: context.getHeight(16)),
        SharedAuthWidgets.buildInputField(
          context,
          controller: workerManager.experienceController,
          label: AppLocalizations.of(context)!.yearsOfExperience,
          hintText: AppLocalizations.of(context)!.enterExperienceYears,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: context.getHeight(16)),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context)!.doYouHaveCertificate),
          value: workerManager.hasCertificate,
          onChanged: (value) {
            workerManager.setHasCertificate(value!);
          },
          activeColor: AppColors.primaryColor,
        ),
        if (workerManager.hasCertificate)
          _buildCertificateSection(context, workerManager),
      ],
    );
  }

  Widget _buildCertificateSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.uploadYourCertificate,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(8)),
        Center(
          child: GestureDetector(
            onTap: () => _showCertificatePicker(context, workerManager),
            child: Container(
              width: context.getWidth(200),
              height: context.getWidth(200),
              decoration: BoxDecoration(
                color: AppColors.dimGray,
                borderRadius:
                    BorderRadius.circular(context.getAdaptiveSize(16)),
                border: Border.all(color: AppColors.primaryColor),
              ),
              child: workerManager.selectedImage == null
                  ? Center(
                      child: Icon(
                        Icons.upload_file,
                        size: context.getAdaptiveSize(40),
                        color: AppColors.primaryColor,
                      ),
                    )
                  : ClipRRect(
                      borderRadius:
                          BorderRadius.circular(context.getAdaptiveSize(16)),
                      child: Image.file(
                        workerManager.selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryImagesSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.manageServiceImages,
          style: AppTextStyles.title(context).copyWith(fontSize: 24),
        ),
        SizedBox(height: context.getHeight(16)),
        Container(
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(20)),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: AppColors.primaryColor,
              ),
              SizedBox(height: context.getHeight(8)),
              Text(
                AppLocalizations.of(context)!.additionalPhotos,
                style: AppTextStyles.subTitle(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.getHeight(20)),
              SizedBox(
                width: context.getWidth(200),
                height: context.getHeight(45),
                child: PrimaryButton(
                  text: AppLocalizations.of(context)!.addPhoto,
                  onPressed: () =>
                      _showImagePickerModal(context, workerManager),
                ),
              ),
            ],
          ),
        ),
        if (workerManager.galleryImages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.getHeight(24)),
              Text(
                AppLocalizations.of(context)!.allPhotos,
                style: AppTextStyles.subTitle(context),
              ),
              SizedBox(height: context.getHeight(16)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workerManager.galleryImages.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: context.getHeight(10)),
                itemBuilder: (context, index) {
                  final image = workerManager.galleryImages[index];
                  return ListTile(
                    leading: image.id == 0
                        ? Image.network(
                            'http://162.254.35.98/storage/${image.image}',
                            width: context.getAdaptiveSize(52),
                            height: context.getAdaptiveSize(52),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: context.getAdaptiveSize(30),
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Image.network(
                            'http://162.254.35.98/storage/${image.image}',
                            width: context.getAdaptiveSize(52),
                            height: context.getAdaptiveSize(52),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: context.getAdaptiveSize(30),
                              color: AppColors.primaryColor,
                            ),
                          ),
                    title: Text(
                        '${AppLocalizations.of(context)!.image} ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        if (image.id == 0) {
                          workerManager.galleryImages.removeAt(index);
                          workerManager.notifyListeners();
                        } else {
                          workerManager.removeServiceImage(image.id!);
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  void _showCertificatePicker(
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
                leading:
                    const Icon(Icons.camera_alt, color: AppColors.primaryColor),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  workerManager.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryColor),
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
                leading:
                    const Icon(Icons.camera_alt, color: AppColors.primaryColor),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  // workerManager.uploadServiceImage(
                  //   context,
                  //   ImageSource.camera,
                  //   widget.service.id,
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryColor),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  // Navigator.pop(context);
                  // workerManager.uploadServiceImage(
                  //   context,
                  //   ImageSource.gallery,
                  //   widget.service.id,
                  // );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
