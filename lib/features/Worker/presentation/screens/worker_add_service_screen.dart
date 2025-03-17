import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/add_service_data.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerAddServiceScreen extends StatefulWidget {
  const WorkerAddServiceScreen({super.key});

  @override
  State<WorkerAddServiceScreen> createState() => _WorkerAddServiceScreenState();
}

class _WorkerAddServiceScreenState extends State<WorkerAddServiceScreen> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch categories when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkerManagerProvider>(context, listen: false)
          .fetchCategories();
    });
  }

  void _nextPage() {
    if (_currentPageIndex == 0) {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);
      workerManager.setServicePrice();

      if (workerManager.validateServiceInputs()) {
        setState(() => _currentPageIndex++);
      }
    } else if (_currentPageIndex == 1) {
      setState(() => _currentPageIndex++);
    } else {
      // Submit the service (API call can be added here)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service Posted!')),
      );
      Provider.of<WorkerManagerProvider>(context, listen: false)
          .resetServiceState();
      setState(() => _currentPageIndex = 0);
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() => _currentPageIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.isServiceLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildPageContent(context, workerManager),
                      ),
                      _buildNavigationButtons(workerManager),
                    ],
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.addService,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    switch (_currentPageIndex) {
      case 0:
        return AddServiceData();
      case 1:
        return _buildAddImagesPage(workerManager);
      case 2:
        return _buildSummaryPage(workerManager);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddImagesPage(WorkerManagerProvider workerManager) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add images',
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(8)),
          Text(
            '(please upload unique images to attract customers)',
            style: AppTextStyles.text(context),
          ),
          SizedBox(height: context.getHeight(24)),
          Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.getAdaptiveSize(20)),
              border: Border.all(
                color: AppColors.primaryColor,
              ),
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
                  'Additional photos of the service',
                  style: AppTextStyles.subTitle(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.getHeight(8)),
                Text(
                  'You can choose more than one image for the service',
                  style: AppTextStyles.text(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.getHeight(24)),
                SizedBox(
                  width: context.getWidth(200),
                  height: context.getHeight(45),
                  child: PrimaryButton(
                    text: 'Add photos',
                    onPressed: () =>
                        _showImagePickerModal(context, workerManager),
                  ),
                ),
              ],
            ),
          ),
          workerManager.galleryImages.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.getHeight(24)),
                    Text(
                      'All photos and videos',
                      style: AppTextStyles.title2(context),
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
                          leading: Image.network(
                            '${ApiEndpoints.imageBaseUrl}/${image.image!}',
                            width: context.getAdaptiveSize(52),
                            height: context.getAdaptiveSize(52),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: context.getAdaptiveSize(30),
                                color: AppColors.primaryColor,
                              );
                            },
                          ),
                          title: Text('Image ${index + 1}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.dimGray,
                                ),
                                onPressed: () {
                                  // Implement edit functionality if needed
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () =>
                                    workerManager.removeServiceImage(image.id!),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSummaryPage(WorkerManagerProvider workerManager) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.green[100],
            child: Center(
              child: Text(
                'The service announcement is complete',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Service Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Service',
              workerManager.selectedCategory?.name ?? 'Not selected'),
          _buildSummaryRow('Service price',
              '\$${workerManager.servicePrice?.toStringAsFixed(2) ?? 'Not set'}'),
          _buildSummaryRow(
              'Payment method', 'Cash'), // Assuming cash as per design
          const SizedBox(height: 16),
          Text(
            'Images',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Wrap(
          //   spacing: 8.0,
          //   runSpacing: 8.0,
          //   children: workerManager.galleryImages.map((image) {
          //     return image.image != null
          //         ? Image.network(
          //             image.image!,
          //             width: 80,
          //             height: 80,
          //             fit: BoxFit.cover,
          //             errorBuilder: (context, error, stackTrace) =>
          //                 const Icon(Icons.error),
          //           )
          //         : const Icon(Icons.image, size: 80);
          //   }).toList(),
          // ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(WorkerManagerProvider workerManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPageIndex > 0)
          SmallSecondaryButton(
            text: "Back",
            onPressed: _previousPage,
          )
        else
          const SizedBox(),
        SmallPrimaryButton(
          text: _currentPageIndex == 2 ? 'Posted' : 'Next',
          onPressed: _nextPage,
        )
        // ElevatedButton(
        //   onPressed: _nextPage,
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.red,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        //   child: Text(
        //     _currentPageIndex == 2 ? 'Posted' : 'Next',
        //     style: TextStyle(color: Colors.white),
        //   ),
        // ),
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
                  workerManager.uploadServiceImage(
                      context, ImageSource.camera, "1");
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  workerManager.uploadServiceImage(
                      context, ImageSource.gallery, "1");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
