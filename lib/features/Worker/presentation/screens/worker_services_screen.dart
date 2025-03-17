import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:good_one_app/Core/presentation/Widgets/error/error_widget.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:provider/provider.dart';

class WWorkerServicesScreen extends StatelessWidget {
  const WWorkerServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.error != null
              ? AppErrorWidget(
                  message: workerManager.error!,
                  onRetry:
                      workerManager.fetchUserInfo, // TODO fetch my services
                )
              : _buildServicesList(context, workerManager),
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

  Widget _buildServicesList(
    BuildContext context,
    WorkerManagerProvider workerProvider,
  ) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      child: Column(
        children: [
          SmallPrimaryButton(
            text: 'Add Service', //TODO translate
            onPressed: () {
              NavigationService.navigateTo(AppRoutes.workerAddService);
            },
          ),
        ],
      ),
    );
  }
}
