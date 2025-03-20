import 'package:flutter/material.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/add_images_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/category_dropdown_widget.dart';
import 'package:good_one_app/Features/auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerAddServiceScreen extends StatefulWidget {
  const WorkerAddServiceScreen({super.key});

  @override
  State<WorkerAddServiceScreen> createState() => _WorkerAddServiceScreenState();
}

class _WorkerAddServiceScreenState extends State<WorkerAddServiceScreen> {
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
                          PrimaryButton(
                            text: 'Next',
                            onPressed: () async {
                              final serviceId =
                                  await workerManager.createAndEditService();
                              if (serviceId > 0) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddImagesScreen(
                                          serviceId: serviceId)),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                          ),
                          if (workerManager.addServiceError != null)
                            SharedAuthWidgets.buildErrorMessage(
                              context,
                              workerManager.addServiceError!,
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
        AppLocalizations.of(context)!.addService,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildServiceDetailsStep(WorkerManagerProvider workerManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.getHeight(16)),
        Text(
          'Define Your Service Expertise',
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(16)),
        CategoryDropdownWidget<CategoryModel>(
          label: 'Select Service Category',
          hint: 'Choose a service category',
          value: workerManager.selectedCategory,
          items: workerManager.categories,
          onChanged: (category) {
            workerManager.setCategory(category);
          },
        ),
        SizedBox(height: context.getHeight(16)),
        CategoryDropdownWidget<SubcategoryModel>(
          label: 'Select Subcategory',
          hint: 'Choose a subcategory',
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
          label: 'Service Description',
          hintText: 'Provide a detailed description',
          validator: (value) =>
              value!.isEmpty ? 'Description is required' : null,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: context.getHeight(16)),
        SharedAuthWidgets.buildInputField(
          context,
          controller: workerManager.servicePriceController,
          label: 'Service Price (per hour)',
          hintText: 'Enter price',
          validator: (value) => value!.isEmpty ? 'Price is required' : null,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: context.getHeight(16)),
        SharedAuthWidgets.buildInputField(
          context,
          controller: workerManager.experienceController,
          label: 'Years of Experience',
          hintText: 'Enter your experience years',
          validator: (value) =>
              value!.isEmpty ? 'Experience is required' : null,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: context.getHeight(16)),
        CheckboxListTile(
          title: Text("Do you possess a certificate for this service?"),
          value: workerManager.hasCertificate,
          onChanged: (value) {
            workerManager.setHasCertificate(value!);
          },
        ),
        if (workerManager.hasCertificate)
          _buildLicenseCertificate(context, workerManager),
      ],
    );
  }

  Widget _buildLicenseCertificate(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      children: [
        Text(
          'Upload Your Certificate',
          style: AppTextStyles.title2(context),
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
}
