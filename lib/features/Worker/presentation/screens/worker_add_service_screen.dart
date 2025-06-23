import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/category_dropdown_widget.dart';
import 'package:good_one_app/Features/Auth/Presentation/Widgets/shared_auth_widgets.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/add_images_screen.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class WorkerAddServiceScreen extends StatefulWidget {
  const WorkerAddServiceScreen({super.key});

  @override
  State<WorkerAddServiceScreen> createState() => _WorkerAddServiceScreenState();
}

class _WorkerAddServiceScreenState extends State<WorkerAddServiceScreen> {
  WorkerManagerProvider? _workerManager;
  bool _tempActiveStatus = true; // Default to active for new services

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get the provider reference
    _workerManager ??=
        Provider.of<WorkerManagerProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);
      // Reset any previous selections first
      workerManager.resetCategorySelection();
      // Then fetch categories
      workerManager.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.isServiceLoading
              ? LoadingIndicator()
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
                            SizedBox(height: context.getHeight(32)),
                            PrimaryButton(
                              text: workerManager.isServiceLoading
                                  ? AppLocalizations.of(context)!.creating
                                  : AppLocalizations.of(context)!.next,
                              onPressed: workerManager.isServiceLoading
                                  ? () {}
                                  : () async {
                                      // Clear previous errors
                                      workerManager.clearError('services');

                                      // Set the active status before creating
                                      workerManager
                                          .setActive(_tempActiveStatus);

                                      // Show progress indicator
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                    'Creating your service...'),
                                              ),
                                            ],
                                          ),
                                          duration: Duration(
                                              minutes: 2), // Long duration
                                          backgroundColor:
                                              AppColors.primaryColor,
                                        ),
                                      );

                                      try {
                                        // Use your existing method for now (we'll enhance it step by step)
                                        final serviceId = await workerManager
                                            .createAndEditService();

                                        // Hide loading indicator
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();

                                        if (serviceId > 0) {
                                          // Success feedback
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      'Service created successfully!'),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 3),
                                            ),
                                          );

                                          // Navigate to next screen
                                          if (context.mounted) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddImagesScreen(
                                                        serviceId: serviceId),
                                              ),
                                              (Route<dynamic> route) => false,
                                            );
                                          }
                                        } else {
                                          // Error handling - error message is already set in provider
                                          final errorMessage = workerManager
                                                  .addServiceError ??
                                              'Failed to create service. Please try again.';

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.error,
                                                          color: Colors.white),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          'Service Creation Failed',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    errorMessage,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 6),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              action: SnackBarAction(
                                                label: 'Retry',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  // Close current snackbar and retry
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  // You can trigger the same action again by calling the function recursively
                                                  // or implement a separate retry method
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        // Hide loading indicator
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();

                                        // Unexpected error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.error,
                                                        color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Unexpected Error',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'An unexpected error occurred. Please try again or contact support if the problem persists.',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red[700],
                                            duration: Duration(seconds: 8),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
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
      title: Text(
        AppLocalizations.of(context)!.addService,
        style: AppTextStyles.appBarTitle(context),
      ),
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
                  AppLocalizations.of(context)!.serviceVisibility,
                  style: AppTextStyles.title2(context),
                ),
                Text(
                  _tempActiveStatus
                      ? AppLocalizations.of(context)!.serviceVisibleToCustomers
                      : AppLocalizations.of(context)!
                          .serviceHiddenFromCustomers,
                  style: AppTextStyles.text(context).copyWith(
                    color: _tempActiveStatus
                        ? Colors.green[600]
                        : Colors.grey[600],
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.canChangeAnytimeAfterCreating,
                  style: AppTextStyles.text(context).copyWith(
                    color: Colors.grey[500],
                    fontSize: context.getAdaptiveSize(12),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _tempActiveStatus,
            onChanged: (value) {
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
            AppLocalizations.of(context)!.defineYourServiceExpertise,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(16)),
          CategoryDropdownWidget<CategoryModel>(
            label: AppLocalizations.of(context)!.selectServiceCategory,
            hint: AppLocalizations.of(context)!.chooseServiceCategory,
            value: workerManager.categories
                    .contains(workerManager.selectedCategory)
                ? workerManager.selectedCategory
                : null, // Safety check
            items: workerManager.categories,
            onChanged: (category) {
              workerManager.setCategory(category);
            },
          ),
          SizedBox(height: context.getHeight(16)),
          CategoryDropdownWidget<SubcategoryModel>(
            label: AppLocalizations.of(context)!.selectSubcategory,
            hint: AppLocalizations.of(context)!.chooseSubcategory,
            value: (workerManager.selectedCategory?.subcategories ?? [])
                    .contains(workerManager.selectedSubcategory)
                ? workerManager.selectedSubcategory
                : null, // Safety check
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
            validator: (value) => value!.isEmpty
                ? AppLocalizations.of(context)!.descriptionRequired
                : null,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildModernPricingSection(context, workerManager),
          SizedBox(height: context.getHeight(16)),
          SharedAuthWidgets.buildInputField(
            context,
            controller: workerManager.experienceController,
            label: AppLocalizations.of(context)!.yearsOfExperience,
            hintText: AppLocalizations.of(context)!.enterExperienceYears,
            validator: (value) => value!.isEmpty
                ? AppLocalizations.of(context)!.experienceRequired
                : null,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: context.getHeight(16)),
          if (workerManager.selectedCategory?.hasLiscence == false)
            Column(
              children: [
                CheckboxListTile(
                  title:
                      Text(AppLocalizations.of(context)!.doYouHaveCertificate),
                  value: workerManager.hasCertificate,
                  onChanged: (value) {
                    workerManager.setHasCertificate(value!);
                  },
                ),
                if (workerManager.hasCertificate)
                  _buildLicenseCertificate(context, workerManager),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLicenseCertificate(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
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

  void _showCertificatePicker(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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

  Widget _buildModernPricingSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.pricingOptions,
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),

        // Modern Pricing Type Selector
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
                AppLocalizations.of(context)!.hourlyRate,
                AppLocalizations.of(context)!.setPricePerHour,
                Icons.access_time,
                workerManager.hourlyPriceController,
                '\$/${AppLocalizations.of(context)!.hour}',
              ),
              Divider(
                  height: 1, color: AppColors.primaryColor.withOpacity(0.2)),
              _buildPricingOption(
                context,
                workerManager,
                'daily',
                AppLocalizations.of(context)!.dailyRate,
                AppLocalizations.of(context)!.setPricePerDay,
                Icons.calendar_today,
                workerManager.dailyPriceController,
                '\$/${AppLocalizations.of(context)!.day}',
              ),
              Divider(
                  height: 1, color: AppColors.primaryColor.withOpacity(0.2)),
              _buildPricingOption(
                context,
                workerManager,
                'fixed',
                AppLocalizations.of(context)!.fixedPrice,
                AppLocalizations.of(context)!.oneTimeServicePrice,
                Icons.monetization_on,
                workerManager.fixedPriceController,
                '\$ ${AppLocalizations.of(context)!.total}',
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
                SizedBox(
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
}
