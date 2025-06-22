import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
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

import 'package:good_one_app/l10n/app_localizations.dart';

class EditService extends StatefulWidget {
  final MyServicesModel service;
  const EditService({super.key, required this.service});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService>
    with TickerProviderStateMixin {
  bool _tempActiveStatus = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _tempActiveStatus = widget.service.active == 1;

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);

      await workerManager.fetchCategories();
      workerManager.initializeServiceControlles(widget.service);
      _setCorrectCategoryAndSubcategory(workerManager);

      // Start animations
      _fadeController.forward();
      Future.delayed(Duration(milliseconds: 200), () {
        _slideController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildModernAppBar(context),
          body: workerManager.isServiceLoading
              ? LoadingIndicator()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildServiceHeader(),
                              SizedBox(height: context.getHeight(24)),
                              _buildServiceVisibilityCard(workerManager),
                              SizedBox(height: context.getHeight(24)),
                              _buildServiceDetailsCard(workerManager),
                              SizedBox(height: context.getHeight(24)),
                              _buildImageGalleryCard(context, workerManager),
                              SizedBox(height: context.getHeight(24)),
                              _buildSaveButton(context, workerManager),
                              if (workerManager.addServiceError != null) ...[
                                SizedBox(height: context.getHeight(16)),
                                _buildErrorCard(workerManager.addServiceError!),
                              ],
                              SizedBox(height: context.getHeight(24)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        '${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.service}',
        style: AppTextStyles.appBarTitle(context).copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(12)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: context.getAdaptiveSize(28),
            ),
          ),
          SizedBox(width: context.getWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.service,
                  style: AppTextStyles.title(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.getHeight(4)),
                Text(
                  AppLocalizations.of(context)!.editUpdateServiceDetails,
                  style: AppTextStyles.text(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceVisibilityCard(WorkerManagerProvider workerManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.visibility_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: context.getWidth(12)),
              Text(
                AppLocalizations.of(context)!.serviceVisibility,
                style: AppTextStyles.title2(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(16)),
          Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            decoration: BoxDecoration(
              color: _tempActiveStatus
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _tempActiveStatus
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _tempActiveStatus ? Icons.visibility : Icons.visibility_off,
                  color: _tempActiveStatus
                      ? Colors.green.shade600
                      : Colors.grey.shade600,
                  size: context.getAdaptiveSize(24),
                ),
                SizedBox(width: context.getWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tempActiveStatus
                            ? AppLocalizations.of(context)!.serviceIsActive
                            : AppLocalizations.of(context)!.serviceIsInactive,
                        style: AppTextStyles.subTitle(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: _tempActiveStatus
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: context.getHeight(4)),
                      Text(
                        _tempActiveStatus
                            ? AppLocalizations.of(context)!
                                .customersCanSeeAndBook
                            : AppLocalizations.of(context)!
                                .serviceHiddenFromCustomers,
                        style: AppTextStyles.text(context).copyWith(
                          color: _tempActiveStatus
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (_tempActiveStatus !=
                          (widget.service.active == 1)) ...[
                        SizedBox(height: context.getHeight(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.getWidth(8),
                            vertical: context.getHeight(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.unsavedChanges,
                            style: AppTextStyles.text(context).copyWith(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(WorkerManagerProvider workerManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: context.getWidth(12)),
              Text(
                AppLocalizations.of(context)!.serviceDetails,
                style: AppTextStyles.title2(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(20)),
          _buildModernDropdown<CategoryModel>(
            label: AppLocalizations.of(context)!.selectServiceCategory,
            hint: widget.service.service,
            value: workerManager.selectedCategory,
            items: workerManager.categories,
            onChanged: workerManager.setCategory,
            icon: Icons.category_rounded,
          ),
          SizedBox(height: context.getHeight(20)),
          _buildModernDropdown<SubcategoryModel>(
            label: AppLocalizations.of(context)!.selectSubcategory,
            hint: widget.service.subcategory.name,
            value: workerManager.selectedSubcategory,
            items: workerManager.selectedCategory?.subcategories ?? [],
            onChanged: workerManager.setSubcategory,
            icon: Icons.subdirectory_arrow_right_rounded,
          ),
          SizedBox(height: context.getHeight(20)),
          _buildModernTextField(
            controller: workerManager.descriptionController,
            label: AppLocalizations.of(context)!.serviceDescription,
            hintText: AppLocalizations.of(context)!.provideDetailedDescription,
            icon: Icons.description_rounded,
            minLines: 3,
          ),
          SizedBox(height: context.getHeight(24)),
          _buildModernPricingSection(context, workerManager),
          SizedBox(height: context.getHeight(20)),
          _buildModernTextField(
            controller: workerManager.experienceController,
            label: AppLocalizations.of(context)!.yearsOfExperience,
            hintText: AppLocalizations.of(context)!.enterExperienceYears,
            icon: Icons.work_history_rounded,
            keyboardType: TextInputType.number,
          ),
          if (workerManager.selectedCategory?.hasLiscence == false) ...[
            SizedBox(height: context.getHeight(20)),
            _buildCertificateSection(context, workerManager),
          ],
        ],
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryColor,
            ),
            SizedBox(width: context.getWidth(8)),
            Text(
              label,
              style: AppTextStyles.subTitle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        CategoryDropdownWidget<T>(
          label: '',
          hint: hint,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int? minLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryColor),
            SizedBox(width: context.getWidth(8)),
            Text(
              label,
              style: AppTextStyles.subTitle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SharedAuthWidgets.buildInputField(
          context,
          controller: controller,
          label: '',
          hintText: hintText,
          keyboardType: keyboardType,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          minLines: minLines ?? 1,
        ),
      ],
    );
  }

  Widget _buildCertificateSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded,
                  color: Colors.blue.shade600, size: 20),
              SizedBox(width: context.getWidth(8)),
              Text(
                AppLocalizations.of(context)!.certificate,
                style: AppTextStyles.subTitle(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          CheckboxListTile(
            title: Text(
              AppLocalizations.of(context)!.doYouHaveCertificate,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.blue.shade700,
              ),
            ),
            value: workerManager.hasCertificate,
            onChanged: (value) => workerManager.setHasCertificate(value!),
            activeColor: Colors.blue.shade600,
            contentPadding: EdgeInsets.zero,
          ),
          if (workerManager.hasCertificate) ...[
            SizedBox(height: context.getHeight(16)),
            Center(
              child: GestureDetector(
                onTap: () => _showCertificatePicker(context, workerManager),
                child: Container(
                  width: context.getWidth(200),
                  height: context.getWidth(200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: workerManager.selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file_rounded,
                              size: context.getAdaptiveSize(40),
                              color: Colors.blue.shade600,
                            ),
                            SizedBox(height: context.getHeight(8)),
                            Text(
                              AppLocalizations.of(context)!.uploadCertificate,
                              style: AppTextStyles.text(context).copyWith(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            workerManager.selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernPricingSection(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payments_rounded,
                size: 16, color: AppColors.primaryColor),
            SizedBox(width: context.getWidth(8)),
            Text(
              AppLocalizations.of(context)!.pricingOptions,
              style: AppTextStyles.subTitle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildModernPricingOption(
                context,
                workerManager,
                'hourly',
                AppLocalizations.of(context)!.hourlyRate,
                AppLocalizations.of(context)!.setPricePerHour,
                Icons.access_time_rounded,
                workerManager.hourlyPriceController,
                '\$/${AppLocalizations.of(context)!.hour}',
                Colors.blue,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildModernPricingOption(
                context,
                workerManager,
                'daily',
                AppLocalizations.of(context)!.dailyRate,
                AppLocalizations.of(context)!.setPricePerDay,
                Icons.calendar_today_rounded,
                workerManager.dailyPriceController,
                '\$/${AppLocalizations.of(context)!.day}',
                Colors.green,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildModernPricingOption(
                context,
                workerManager,
                'fixed',
                AppLocalizations.of(context)!.fixedPrice,
                AppLocalizations.of(context)!.oneTimeServicePrice,
                Icons.monetization_on_rounded,
                workerManager.fixedPriceController,
                '\$ ${AppLocalizations.of(context)!.total}',
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernPricingOption(
    BuildContext context,
    WorkerManagerProvider workerManager,
    String pricingType,
    String title,
    String subtitle,
    IconData icon,
    TextEditingController controller,
    String priceHint,
    Color color,
  ) {
    bool isSelected = workerManager.selectedPricingType == pricingType;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => workerManager.setPricingType(pricingType),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(context.getAdaptiveSize(10)),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: context.getAdaptiveSize(18),
                height: context.getAdaptiveSize(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: context.getAdaptiveSize(12),
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: context.getWidth(12)),
              Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(8)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.getAdaptiveSize(20),
                ),
              ),
              SizedBox(width: context.getWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title2(context).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? color : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.text(context),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: context.getWidth(12)),
                Container(
                  width: context.getWidth(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    style:
                        AppTextStyles.subTitle(context).copyWith(color: color),
                    decoration: InputDecoration(
                      hintText: priceHint,
                      hintStyle: AppTextStyles.text(context).copyWith(
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
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

  Widget _buildImageGalleryCard(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.getAdaptiveSize(8)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: context.getWidth(12)),
                  Text(
                    AppLocalizations.of(context)!.serviceGallery,
                    style: AppTextStyles.title2(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.add_a_photo_rounded, color: Colors.white),
                  onPressed: () =>
                      _showImagePickerModal(context, workerManager),
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(20)),
          if (workerManager.galleryImages.isEmpty)
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(32)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: context.getAdaptiveSize(48),
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: context.getHeight(12)),
                  Text(
                    AppLocalizations.of(context)!.noImagesYet,
                    style: AppTextStyles.subTitle(context).copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Text(
                    AppLocalizations.of(context)!.addPhotosToShowcase,
                    style: AppTextStyles.text(context).copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          '${ApiEndpoints.imageBaseUrl}/${image.image!}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.failedToLoad,
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.captionMedium(context),
                                    AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            await workerManager
                                .removeServiceImage(image.image!);
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: PrimaryButton(
        text: workerManager.isServiceLoading
            ? AppLocalizations.of(context)!.updating
            : AppLocalizations.of(context)!.update,
        onPressed: workerManager.isServiceLoading
            ? () {}
            : () async {
                workerManager.setServiceId(widget.service.id);
                workerManager.setActive(_tempActiveStatus);

                final success =
                    await workerManager.createAndEditService(isEditing: true);
                if (success > 0) {
                  _showSuccessSnackbar(context);
                  Navigator.pop(context);
                }
              },
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.error_rounded, color: Colors.red.shade600, size: 20),
          ),
          SizedBox(width: context.getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.updateFailed,
                  style: AppTextStyles.subTitle(context).copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error,
                  style: AppTextStyles.text(context).copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.serviceUpdatedSuccessfully,
                  style: AppTextStyles.withColor(
                    AppTextStyles.buttonTextMedium(context),
                    AppColors.whiteText,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        elevation: 8,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showCertificatePicker(
      BuildContext context, WorkerManagerProvider workerManager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildModernPickerModal(context, workerManager, isCertificate: true),
    );
  }

  void _showImagePickerModal(
      BuildContext context, WorkerManagerProvider workerManager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildModernPickerModal(context, workerManager, isCertificate: false),
    );
  }

  Widget _buildModernPickerModal(
      BuildContext context, WorkerManagerProvider workerManager,
      {required bool isCertificate}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  isCertificate
                      ? Icons.verified_rounded
                      : Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  isCertificate
                      ? AppLocalizations.of(context)!.addCertificate
                      : AppLocalizations.of(context)!.addPhoto,
                  style: AppTextStyles.title2(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildModernPickerOption(
            context,
            icon: Icons.camera_alt_rounded,
            title: AppLocalizations.of(context)!.takePhoto,
            subtitle: AppLocalizations.of(context)!.useYourCamera,
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
          _buildModernPickerOption(
            context,
            icon: Icons.photo_library_rounded,
            title: AppLocalizations.of(context)!.chooseFromGallery,
            subtitle: AppLocalizations.of(context)!.selectFromGallery,
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
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModernPickerOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.subTitle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.text(context).copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _setCorrectCategoryAndSubcategory(WorkerManagerProvider workerManager) {
    for (CategoryModel category in workerManager.categories) {
      for (SubcategoryModel subcategory in category.subcategories) {
        if (subcategory.id == widget.service.subcategory.subCategoryid) {
          workerManager.setCategory(category);
          workerManager.setSubcategory(subcategory);
          return;
        }
      }
    }
  }
}
