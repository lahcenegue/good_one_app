import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        if (workerManager.error != null) {
          return AppErrorWidget(
            message: workerManager.error!,
            onRetry: workerManager.initialize,
          );
        }
        if (workerManager.isLoading || workerManager.isOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: workerManager.initialize,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(20),
              vertical: context.getHeight(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.getHeight(20)),
                _buildHeader(context, workerManager),
                SizedBox(height: context.getHeight(40)),
                _buildSummarySection(context, workerManager),
                SizedBox(height: context.getHeight(24)),
                _buildActionButtons(context, workerManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, WorkerManagerProvider workerManager) {
    final worker = workerManager.workerInfo;

    return Row(
      children: [
        UserAvatar(
          picture: worker?.picture,
          size: context.getWidth(40),
        ),
        SizedBox(width: context.getWidth(10)),
        Expanded(
          child: _buildUserInfo(
            context,
            worker!.fullName,
            '${worker.city}, ${worker.country}',
          ),
        ),
        _buildNotificationIcon(context),
        SizedBox(width: context.getWidth(10)),
        _buildMessageIcon(context, workerManager),
      ],
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    String? name,
    String? location,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null
              ? '${AppLocalizations.of(context)!.hello}, $name'
              : AppLocalizations.of(context)!.hello,
          style: AppTextStyles.title2(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (location != null)
          Text(
            location,
            style: AppTextStyles.text(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dimGray,
      ),
      child: IconButton(
        icon: Image.asset(
          AppAssets.notification,
          width: context.getAdaptiveSize(20),
        ),
        onPressed: () {
          NavigationService.navigateTo(AppRoutes.workerNotificationsScreen);
        },
      ),
    );
  }

  Widget _buildMessageIcon(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dimGray,
      ),
      child: IconButton(
        icon: Image.asset(
          AppAssets.message,
          width: context.getAdaptiveSize(25),
        ),
        onPressed: () {
          if (workerManager.workerInfo != null) {
            NavigationService.navigateTo(AppRoutes.conversations);
          }
        },
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.serviceSummary,
              style: AppTextStyles.title(context).copyWith(fontSize: 18),
            ),
            SizedBox(height: context.getHeight(16)),
            _buildSummaryItem(
              context,
              label: AppLocalizations.of(context)!.servicesOffered,
              value: workerManager.myServices.length.toString(),
            ),
            SizedBox(height: context.getHeight(12)),
            _buildSummaryItem(
              context,
              label: AppLocalizations.of(context)!.totalOrders,
              value: workerManager.totalOrders.toString(),
            ),
            SizedBox(height: context.getHeight(12)),
            _buildSummaryItem(
              context,
              label: AppLocalizations.of(context)!.pendingOrders,
              value: workerManager.pendingOrders.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context,
      {required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.subTitle(context),
        ),
        Text(
          value,
          style:
              AppTextStyles.text(context).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Column(
      children: [
        PrimaryButton(
          text: workerManager.isOnVacation
              ? AppLocalizations.of(context)!.endVacation
              : AppLocalizations.of(context)!.goOnVacation,
          onPressed: workerManager.isVacationLoading
              ? () {}
              : () async {
                  await workerManager.toggleVacationMode();
                  if (workerManager.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          workerManager.isOnVacation
                              ? AppLocalizations.of(context)!.vacationStarted
                              : AppLocalizations.of(context)!.vacationEnded,
                        ),
                      ),
                    );
                  }
                },
          width: double.infinity,
          height: context.getHeight(50),
          isLoading: workerManager.isVacationLoading,
        ),
        SizedBox(height: context.getHeight(16)),
        PrimaryButton(
          text: AppLocalizations.of(context)!.requestProfits,
          onPressed: () {
            workerManager.requestProfits();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.profitsRequested),
              ),
            );
          },
          width: double.infinity,
          height: context.getHeight(50),
        ),
      ],
    );
  }
}
