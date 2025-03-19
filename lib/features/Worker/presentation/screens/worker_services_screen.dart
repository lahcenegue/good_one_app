import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:good_one_app/Core/presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/edit_service.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:provider/provider.dart';

class WWorkerServicesScreen extends StatefulWidget {
  const WWorkerServicesScreen({super.key});

  @override
  State<WWorkerServicesScreen> createState() => _WWorkerServicesScreenState();
}

class _WWorkerServicesScreenState extends State<WWorkerServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkerManagerProvider>(context, listen: false)
          .fetchMyServices();
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAddServiceButton(context, workerManager),
                      _buildMyServicesList(context, workerManager),
                      SizedBox(height: context.getHeight(16)),
                      if (workerManager.serviceError != null)
                        AppErrorWidget(
                          message: workerManager.error!,
                          onRetry: workerManager.fetchMyServices,
                        )
                    ],
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        AppLocalizations.of(context)!.services,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildAddServiceButton(
    BuildContext context,
    WorkerManagerProvider workerProvider,
  ) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SmallPrimaryButton(
            text: AppLocalizations.of(context)!.addService,
            onPressed: () {
              NavigationService.navigateTo(AppRoutes.workerAddService);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyServicesList(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    if (workerManager.myServices.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(20)),
        child: Text(
          AppLocalizations.of(context)!.noServicesAvailable,
          style: AppTextStyles.subTitle(context),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      itemCount: workerManager.myServices.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.getHeight(10)),
      itemBuilder: (BuildContext context, int index) {
        final service = workerManager.myServices[index];
        final hasImage = service.gallary.isNotEmpty;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
          ),
          margin: EdgeInsets.only(bottom: context.getHeight(16)),
          child: Padding(
            padding: EdgeInsets.all(context.getWidth(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(context.getAdaptiveSize(16)),
                  child: hasImage
                      ? Image.network(
                          '${ApiEndpoints.imageBaseUrl}/${service.gallary.first}',
                          width: context.getWidth(100),
                          height: context.getWidth(120),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: context.getWidth(80),
                            height: context.getWidth(80),
                            color: AppColors.dimGray,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.hintColor,
                              size: context.getAdaptiveSize(40),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: context.getWidth(80),
                              height: context.getWidth(80),
                              color: AppColors.dimGray,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: context.getWidth(100),
                          height: context.getWidth(120),
                          color: AppColors.dimGray,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.hintColor,
                            size: context.getAdaptiveSize(40),
                          ),
                        ),
                ),
                SizedBox(width: context.getWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.service,
                        style: AppTextStyles.title(context).copyWith(
                          fontSize: context.getAdaptiveSize(18),
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: context.getHeight(4)),
                      Text(service.subcategory.name,
                          style: AppTextStyles.subTitle(context)),
                      SizedBox(height: context.getHeight(8)),
                      Row(
                        children: [
                          Text(
                            '\$${service.costPerHour}/hr',
                            style: AppTextStyles.text(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: context.getWidth(16)),
                          Text(
                            '${service.yearsOfExperience} years exp',
                            style: AppTextStyles.text(context),
                          ),
                        ],
                      ),
                      SizedBox(height: context.getHeight(8)),
                      Text(
                        service.about,
                        style: AppTextStyles.text(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.getHeight(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: context.getWidth(100),
                            child: SmallPrimaryButton(
                              text: 'Edit',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditService(service: service),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
