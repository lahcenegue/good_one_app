import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddImagesScreen extends StatelessWidget {
  final int serviceId;
  const AddImagesScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.isServiceLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.getHeight(8)),
                      Text(
                        'Please upload unique images to attract customers',
                        style: AppTextStyles.subTitle(context),
                      ),
                      SizedBox(height: context.getHeight(20)),
                      Container(
                        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              context.getAdaptiveSize(20)),
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
                            SizedBox(height: context.getHeight(20)),
                            SizedBox(
                              width: context.getWidth(200),
                              height: context.getHeight(45),
                              child: PrimaryButton(
                                text: 'Add photo',
                                onPressed: () => _showImagePickerModal(
                                  context,
                                  workerManager,
                                  serviceId,
                                ),
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
                                  'All photos',
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
                                    final image =
                                        workerManager.galleryImages[index];
                                    return ListTile(
                                      leading: Image.network(
                                        '${ApiEndpoints.imageBaseUrl}/${image.image!}',
                                        width: context.getAdaptiveSize(52),
                                        height: context.getAdaptiveSize(52),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: context.getAdaptiveSize(30),
                                            color: AppColors.primaryColor,
                                          );
                                        },
                                      ),
                                      title: Text('Image ${index + 1}'),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.primaryColor,
                                        ),
                                        onPressed: () => workerManager
                                            .removeServiceImage(image.image!),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: context.getHeight(32)),
                      PrimaryButton(
                        text: 'Next',
                        onPressed: () {
                          NavigationService.navigateToAndReplace(
                              AppRoutes.workerMain);
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'add images',
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  void _showImagePickerModal(
    BuildContext context,
    WorkerManagerProvider workerManager,
    int id,
  ) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt,
                      color: AppColors.primaryColor),
                  title: Text(AppLocalizations.of(context)!.takePhoto),
                  onTap: () {
                    Navigator.pop(context);
                    workerManager.uploadServiceImage(
                      context,
                      ImageSource.camera,
                      id,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library,
                      color: AppColors.primaryColor),
                  title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(context);
                    workerManager.uploadServiceImage(
                      context,
                      ImageSource.gallery,
                      id,
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
