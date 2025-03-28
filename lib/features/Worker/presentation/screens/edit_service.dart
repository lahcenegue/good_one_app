import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/my_services_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/category_dropdown_widget.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditService extends StatefulWidget {
  final MyServicesModel service;
  const EditService({super.key, required this.service});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);
      await workerManager.fetchCategories();
      workerManager.initializeServiceControlles(widget.service);
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
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServiceDetailsCard(workerManager),
                            SizedBox(height: context.getHeight(24)),
                            _buildImageGalleryCard(context, workerManager),
                            SizedBox(height: context.getHeight(24)),
                            _buildSaveButton(context, workerManager),
                            SizedBox(height: context.getHeight(24)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        '${AppLocalizations.of(context)!.edit} ${widget.service.service}',
        style: AppTextStyles.appBarTitle(context).copyWith(
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildServiceDetailsCard(WorkerManagerProvider workerManager) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.editServiceDetails,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(16)),
          _buildDropdown<CategoryModel>(
            label: AppLocalizations.of(context)!.selectServiceCategory,
            hint: widget.service.service,
            value: workerManager.selectedCategory,
            items: workerManager.categories,
            onChanged: workerManager.setCategory,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildDropdown<SubcategoryModel>(
            label: AppLocalizations.of(context)!.selectSubcategory,
            hint: widget.service.subcategory.name,
            value: workerManager.selectedSubcategory,
            items: workerManager.selectedCategory?.subcategories ?? [],
            onChanged: workerManager.setSubcategory,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildTextField(
            controller: workerManager.descriptionController,
            label: AppLocalizations.of(context)!.serviceDescription,
            hintText: AppLocalizations.of(context)!.provideDetailedDescription,
            minLines: 3,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildTextField(
            controller: workerManager.servicePriceController,
            label: AppLocalizations.of(context)!.servicePricePerHour,
            hintText: AppLocalizations.of(context)!.enterPrice,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildTextField(
            controller: workerManager.experienceController,
            label: AppLocalizations.of(context)!.yearsOfExperience,
            hintText: AppLocalizations.of(context)!.enterExperienceYears,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: context.getHeight(16)),
          CheckboxListTile(
            title: Text(
              AppLocalizations.of(context)!.doYouHaveCertificate,
              style: AppTextStyles.subTitle(context),
            ),
            value: workerManager.hasCertificate,
            onChanged: workerManager.setHasCertificate,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (workerManager.hasCertificate)
            _buildCertificateSection(context, workerManager),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return CategoryDropdownWidget<T>(
      label: label,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    int? minLines,
  }) {
    return SharedAuthWidgets.buildInputField(
      context,
      controller: controller,
      label: label,
      hintText: hintText,
      keyboardType: keyboardType,
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      minLines: minLines ?? 1,
    );
  }

  Widget _buildCertificateSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.getHeight(16)),
        Text(
          AppLocalizations.of(context)!.uploadYourCertificate,
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

  Widget _buildImageGalleryCard(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.manageServiceImages,
                style: AppTextStyles.title2(context),
              ),
              IconButton(
                icon: Icon(Icons.add_a_photo, color: AppColors.primaryColor),
                onPressed: () => _showImagePickerModal(context, workerManager),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(16)),
          if (workerManager.galleryImages.isEmpty)
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(20)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No images yet. Add some!',
                  style: AppTextStyles.subTitle(context),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: workerManager.galleryImages.length,
              itemBuilder: (context, index) {
                final image = workerManager.galleryImages[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${ApiEndpoints.imageBaseUrl}/${image.image!}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.dimGray,
                          child: Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          await workerManager.removeServiceImage(image.image!);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.delete, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return PrimaryButton(
      text: AppLocalizations.of(context)!.update,
      onPressed: () async {
        await workerManager.createAndEditService(isEditing: true);
      },
    );
  }

  void _showCertificatePicker(
      BuildContext context, WorkerManagerProvider workerManager) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _buildPickerModal(context, workerManager, isCertificate: true),
    );
  }

  void _showImagePickerModal(
      BuildContext context, WorkerManagerProvider workerManager) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _buildPickerModal(context, workerManager, isCertificate: false),
    );
  }

  Widget _buildPickerModal(
      BuildContext context, WorkerManagerProvider workerManager,
      {required bool isCertificate}) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
            title: Text(AppLocalizations.of(context)!.takePhoto),
            onTap: () {
              Navigator.pop(context);
              if (isCertificate) {
                workerManager.pickImage(context, ImageSource.camera);
              } else {
                workerManager.uploadServiceImage(
                    context, ImageSource.camera, widget.service.id);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
            title: Text(AppLocalizations.of(context)!.chooseFromGallery),
            onTap: () {
              Navigator.pop(context);
              if (isCertificate) {
                workerManager.pickImage(context, ImageSource.gallery);
              } else {
                workerManager.uploadServiceImage(
                    context, ImageSource.gallery, widget.service.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
