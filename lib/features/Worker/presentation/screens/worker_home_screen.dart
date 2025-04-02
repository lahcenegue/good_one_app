import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/orders_status_chart.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/services_status_chart.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/withdrawal_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkerManagerProvider, OrdersManagerProvider>(
      builder: (context, workerManager, ordersManager, _) {
        if (workerManager.isLoading || ordersManager.isOrdersLoading) {
          return const LoadingIndicator();
        }

        if (workerManager.error != null) {
          return AppErrorWidget(
            message: workerManager.error!,
            onRetry: workerManager.initialize,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              workerManager.initialize(),
              ordersManager.initialize(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(
              context.getAdaptiveSize(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _workerHeader(context, workerManager),
                SizedBox(height: context.getHeight(24)),
                _workerBalanceCard(context, workerManager),
                SizedBox(height: context.getHeight(20)),
                _dashboardOverviewCard(context, workerManager, ordersManager),
                SizedBox(height: context.getHeight(20)),
                _vacationToggleCard(context, workerManager),
                SizedBox(height: context.getHeight(20)),
                _securityCheckCard(context, workerManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _workerHeader(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    final worker = workerManager.workerInfo;
    return Row(
      children: [
        UserAvatar(
          picture: worker?.picture,
          size: context.getWidth(48),
        ),
        SizedBox(width: context.getWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.hello}, ${worker?.fullName ?? 'Worker'}',
                style: AppTextStyles.title2(context),
              ),
              Text(
                '${worker?.city ?? 'Unknown'}, ${worker?.country ?? 'Unknown'}',
                style: AppTextStyles.text(context),
              ),
            ],
          ),
        ),
        _iconButton(
          context: context,
          asset: AppAssets.notification,
          onTap: () =>
              NavigationService.navigateTo(AppRoutes.workerNotificationsScreen),
        ),
        SizedBox(width: context.getWidth(10)),
        _iconButton(
          context: context,
          asset: AppAssets.message,
          onTap: workerManager.workerInfo != null
              ? () => NavigationService.navigateTo(AppRoutes.conversations)
              : null,
        ),
      ],
    );
  }

  Widget _iconButton({
    required BuildContext context,
    required String asset,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(8)),
        decoration: BoxDecoration(
          color: AppColors.dimGray,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          asset,
          width: context.getAdaptiveSize(24),
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _workerBalanceCard(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: AppColors.oxblood,
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: context.getAdaptiveSize(24),
                  ),
                  SizedBox(width: context.getWidth(8)),
                  Text(
                    AppLocalizations.of(context)!.wallet,
                    style: AppTextStyles.subTitle(context)
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
              Text(
                '\$${workerManager.balance?.balance?.toStringAsFixed(2) ?? '0.00'}',
                style: AppTextStyles.title2(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PrimaryButton(
                  text: AppLocalizations.of(context)!.withdrawal,
                  onPressed: () =>
                      _showWithdrawalDialog(context, workerManager),
                ),
              ),
              SizedBox(width: context.getWidth(12)),
              Flexible(
                child: SecondaryButton(
                  text: AppLocalizations.of(context)!.status,
                  onPressed: () async {
                    NavigationService.navigateTo(
                      AppRoutes.withdrawalStatusScreen,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    showDialog(
      context: context,
      builder: (_) => WithdrawalDialog(workerManager: workerManager),
    );
  }

  // Dashboard Overview Card
  Widget _dashboardOverviewCard(
    BuildContext context,
    WorkerManagerProvider workerManager,
    OrdersManagerProvider ordersManager,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.serviceSummary,
            style: AppTextStyles.title(context),
          ),
          SizedBox(height: context.getHeight(20)),
          OrdersStatusChart(ordersManager: ordersManager),
          SizedBox(height: context.getHeight(20)),
          ServicesStatusChart(workerManager: workerManager),
        ],
      ),
    );
  }

  Widget _vacationToggleCard(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    final isActive = workerManager.workerInfo?.active ?? true;

    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.work : Icons.beach_access,
                color: isActive ? Colors.green : AppColors.primaryColor,
              ),
              SizedBox(width: context.getWidth(8)),
              Text(
                isActive
                    ? AppLocalizations.of(context)!.available
                    : AppLocalizations.of(context)!.onVacation,
                style: AppTextStyles.subTitle(context).copyWith(
                  color: isActive ? Colors.green : AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          PrimaryButton(
            text: isActive
                ? AppLocalizations.of(context)!.goOnVacation
                : AppLocalizations.of(context)!.returnToWork,
            onPressed: () async {
              await workerManager.changeAccountState(isActive ? 0 : 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _securityCheckCard(
      BuildContext context, WorkerManagerProvider workerManager) {
    final isSecurityCheckCompleted =
        workerManager.workerInfo?.securityCheck ?? false;
    if (isSecurityCheckCompleted) {
      return SizedBox.shrink();
    } else {
      return Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.primaryColor),
                SizedBox(width: context.getWidth(8)),
                Text(
                  AppLocalizations.of(context)!.securityCheck,
                  style: AppTextStyles.title(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(10)),
            Row(
              children: [
                Icon(
                  isSecurityCheckCompleted ? Icons.check_circle : Icons.warning,
                  color:
                      isSecurityCheckCompleted ? Colors.green : Colors.orange,
                ),
                SizedBox(width: context.getWidth(8)),
                Text(
                  isSecurityCheckCompleted
                      ? AppLocalizations.of(context)!.securityCheckCompleted
                      : AppLocalizations.of(context)!.securityCheckPending,
                  style: AppTextStyles.text(context).copyWith(
                    color:
                        isSecurityCheckCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(8)),
            PrimaryButton(
              text: AppLocalizations.of(context)!.completeSecurityCheck,
              onPressed: () => _launchSecurityCheck(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _launchSecurityCheck(BuildContext context) async {
    const url = AppConfig.securLink;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalError),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }
}
