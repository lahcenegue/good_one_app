import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/presentation/resources/app_assets.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:provider/provider.dart';

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
        return RefreshIndicator(
          onRefresh: workerManager.initialize,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(20),
                vertical: context.getHeight(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.getHeight(40)),
                  if (workerManager.token != null)
                    _buildHeader(context, workerManager),
                  SizedBox(height: context.getHeight(20)),
                  Center(
                    child: Text('comming soon'),
                  ),
                ],
              ),
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
}
