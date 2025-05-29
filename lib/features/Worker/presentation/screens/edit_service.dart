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
  bool _tempActiveStatus = false;
  @override
  void initState() {
    super.initState();

    _tempActiveStatus = widget.service.active == 1;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);

      await workerManager.fetchCategories();

      workerManager.initializeServiceControlles(widget.service);
      _setCorrectCategoryAndSubcategory(workerManager);
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
                            _buildServiceVisibilityCard(workerManager),
                            SizedBox(height: context.getHeight(24)),
                            _buildServiceDetailsCard(workerManager),
                            SizedBox(height: context.getHeight(24)),
                            _buildImageGalleryCard(context, workerManager),
                            SizedBox(height: context.getHeight(24)),
                            _buildSaveButton(context, workerManager),
                            if (workerManager.addServiceError != null)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: context.getHeight(16)),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      context.getAdaptiveSize(12)),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.red[700]),
                                      SizedBox(width: context.getWidth(8)),
                                      Expanded(
                                        child: Text(
                                          workerManager.addServiceError!,
                                          style:
                                              TextStyle(color: Colors.red[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

  // NEW: Service Visibility Card
  Widget _buildServiceVisibilityCard(WorkerManagerProvider workerManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(12)),
            decoration: BoxDecoration(
              color: _tempActiveStatus ? Colors.green[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _tempActiveStatus ? Icons.visibility : Icons.visibility_off,
              color: _tempActiveStatus ? Colors.green[600] : Colors.grey[600],
              size: context.getAdaptiveSize(24),
            ),
          ),
          SizedBox(width: context.getWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Visibility',
                  style: AppTextStyles.title2(context),
                ),
                Text(
                  _tempActiveStatus
                      ? 'Service will be visible to customers'
                      : 'Service will be hidden from customers',
                  style: AppTextStyles.text(context).copyWith(
                    color: _tempActiveStatus
                        ? Colors.green[600]
                        : Colors.grey[600],
                  ),
                ),
                if (_tempActiveStatus != (widget.service.active == 1))
                  Padding(
                    padding: EdgeInsets.only(top: context.getHeight(4)),
                    child: Text(
                      '• Unsaved changes',
                      style: AppTextStyles.text(context).copyWith(
                        color: Colors.orange[600],
                        fontSize: context.getAdaptiveSize(12),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: _tempActiveStatus,
            onChanged: (value) async {
              setState(() {
                _tempActiveStatus = value;
              });
            },
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(WorkerManagerProvider workerManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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

          // NEW: Modern Pricing Section
          _buildModernPricingSection(context, workerManager),

          SizedBox(height: context.getHeight(16)),
          _buildTextField(
            controller: workerManager.experienceController,
            label: AppLocalizations.of(context)!.yearsOfExperience,
            hintText: AppLocalizations.of(context)!.enterExperienceYears,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: context.getHeight(16)),
          if (workerManager.selectedCategory?.hasLiscence == false)
            Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    AppLocalizations.of(context)!.doYouHaveCertificate,
                    style: AppTextStyles.subTitle(context),
                  ),
                  value: workerManager.hasCertificate,
                  onChanged: (value) {
                    workerManager.setHasCertificate(value!);
                  },
                ),
                if (workerManager.hasCertificate)
                  _buildCertificateSection(context, workerManager),
              ],
            ),
        ],
      ),
    );
  }

  // NEW: Modern Pricing Section for Edit
  Widget _buildModernPricingSection(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Options',
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildPricingOption(
                context,
                workerManager,
                'hourly',
                'Hourly Rate',
                'Set price per hour',
                Icons.access_time,
                workerManager.hourlyPriceController,
                '\$/hour',
              ),
              Divider(
                  height: 1, color: AppColors.primaryColor.withOpacity(0.2)),
              _buildPricingOption(
                context,
                workerManager,
                'daily',
                'Daily Rate',
                'Set price per day',
                Icons.calendar_today,
                workerManager.dailyPriceController,
                '\$/day',
              ),
              Divider(
                  height: 1, color: AppColors.primaryColor.withOpacity(0.2)),
              _buildPricingOption(
                context,
                workerManager,
                'fixed',
                'Fixed Price',
                'One-time service price',
                Icons.monetization_on,
                workerManager.fixedPriceController,
                '\$ Total',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOption(
    BuildContext context,
    WorkerManagerProvider workerManager,
    String pricingType,
    String title,
    String subtitle,
    IconData icon,
    TextEditingController controller,
    String priceHint,
  ) {
    bool isSelected = workerManager.selectedPricingType == pricingType;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
      ),
      child: InkWell(
        onTap: () {
          workerManager.setPricingType(pricingType);
        },
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
        child: Padding(
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          child: Row(
            children: [
              // Radio button with modern design
              Container(
                width: context.getAdaptiveSize(24),
                height: context.getAdaptiveSize(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey,
                    width: 2,
                  ),
                  color:
                      isSelected ? AppColors.primaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: context.getAdaptiveSize(16),
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: context.getWidth(16)),

              // Icon
              Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(context.getAdaptiveSize(8)),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: context.getAdaptiveSize(20),
                ),
              ),
              SizedBox(width: context.getWidth(12)),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subTitle(context).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryColor : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.text(context),
                    ),
                  ],
                ),
              ),

              // Price input (only show for selected option)
              if (isSelected) ...[
                SizedBox(width: context.getWidth(12)),
                Container(
                  width: context.getWidth(120),
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.subTitle(context),
                    decoration: InputDecoration(
                      hintText: priceHint,
                      hintStyle: AppTextStyles.text(context),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(8)),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(8)),
                        borderSide: BorderSide(
                            color: AppColors.primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(8)),
                        borderSide:
                            BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(12),
                        vertical: context.getHeight(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                color: Colors.grey[50],
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
    // Check if there are any changes
    bool hasVisibilityChanges =
        _tempActiveStatus != (widget.service.active == 1);
    bool hasOtherChanges = workerManager.descriptionController.text.trim() !=
            widget.service.about ||
        workerManager.experienceController.text.trim() !=
            widget.service.yearsOfExperience.toString();

    return Column(
      children: [
        // Show changes summary if there are unsaved changes

        PrimaryButton(
          text: workerManager.isServiceLoading
              ? 'Updating...'
              : AppLocalizations.of(context)!.update,
          onPressed: workerManager.isServiceLoading
              ? () {}
              : () async {
                  // Set the active status before saving
                  workerManager.setServiceId(widget.service.id);
                  workerManager.setActive(_tempActiveStatus);

                  final success =
                      await workerManager.createAndEditService(isEditing: true);
                  if (success > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Service updated successfully!'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
        ),
      ],
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

  void _setCorrectCategoryAndSubcategory(WorkerManagerProvider workerManager) {
    // Find the category that matches the service's subcategory
    for (CategoryModel category in workerManager.categories) {
      for (SubcategoryModel subcategory in category.subcategories) {
        if (subcategory.id == widget.service.subcategory.subCategoryid) {
          // Set the correct category and subcategory
          workerManager.setCategory(category);
          workerManager.setSubcategory(subcategory);
          return;
        }
      }
    }
  }
}
