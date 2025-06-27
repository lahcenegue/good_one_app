import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/message_helper.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/orders_status_chart.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/services_status_chart.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
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
import 'package:good_one_app/Core/Utils/notification_helper.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<WorkerManagerProvider, OrdersManagerProvider,
        ChatProvider>(
      builder: (context, workerManager, ordersManager, chatProvider, _) {
        // Only show loading indicator for critical loading states
        if (workerManager.isLoading || ordersManager.isOrdersLoading) {
          return const LoadingIndicator();
        }

        // Only show error widget for critical errors (auth errors)
        if (workerManager.hasCriticalError) {
          return AppErrorWidget(
            message: workerManager.criticalError!,
            onRetry: workerManager.initialize,
          );
        }

        if (workerManager.workerInfo == null && !workerManager.isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingUserInformation,
                    style: AppTextStyles.title2(context),
                  ),
                  SizedBox(height: 12),
                  PrimaryButton(
                    text: AppLocalizations.of(context)!.refresh,
                    onPressed: () => workerManager.initialize(),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final currentUserId = workerManager.workerInfo?.id?.toString();
            await Future.wait([
              workerManager.initialize(),
              workerManager.refreshEarningsData(),
              ordersManager.initialize(),
              if (currentUserId != null) chatProvider.initialize(currentUserId),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.getAdaptiveSize(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _workerHeader(context, workerManager, chatProvider),
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
    ChatProvider chatProvider,
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
                '${AppLocalizations.of(context)!.hello}, ${worker?.fullName ?? AppLocalizations.of(context)!.worker}',
                style: AppTextStyles.title2(context),
              ),
              Text(
                '${worker?.city ?? AppLocalizations.of(context)!.unknown}, ${worker?.country ?? AppLocalizations.of(context)!.unknown}',
                style: AppTextStyles.text(context),
              ),
            ],
          ),
        ),
        NotificationHelper.buildNotificationIconWithBadge(
          context: context,
          icon: Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(8)),
            decoration: BoxDecoration(
              color: AppColors.dimGray,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppAssets.notification,
              width: context.getAdaptiveSize(24),
              color: AppColors.primaryColor,
            ),
          ),
          onTap: () =>
              NavigationService.navigateTo(AppRoutes.workerNotificationsScreen),
        ),
        SizedBox(width: context.getWidth(10)),
        MessageHelper.buildMessageIconWithBadge(
          context: context,
          icon: Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(8)),
            decoration: BoxDecoration(
              color: AppColors.dimGray,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppAssets.message,
              width: context.getAdaptiveSize(24),
              color: AppColors.primaryColor,
            ),
          ),
          onTap: workerManager.workerInfo != null
              ? () {
                  final currentUserId =
                      workerManager.workerInfo?.id?.toString();
                  if (currentUserId != null) {
                    chatProvider.initialize(currentUserId);
                  }
                  NavigationService.navigateTo(AppRoutes.conversations);
                }
              : null,
        ),
      ],
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
          // Show balance error if it exists
          if (workerManager.balanceError != null)
            Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      workerManager.balanceError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: Colors.red),
                    onPressed: () => workerManager.clearError('balance'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Show earnings error if it exists
          if (workerManager.earningsError != null)
            Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      workerManager.earningsError!,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: Colors.orange),
                    onPressed: () => workerManager.clearError('earnings'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

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
              // Show loading indicator for balance or display balance
              workerManager.isBalanceLoading || workerManager.isEarningsLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '\$${workerManager.balance?.balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.title2(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),

          // Add earnings summary display if available
          if (workerManager.earningsSummary != null) ...[
            SizedBox(height: context.getHeight(12)),
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(12)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.getAdaptiveSize(8)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalEarnings,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white70,
                          fontSize: context.getAdaptiveSize(12),
                        ),
                      ),
                      Text(
                        '\$${workerManager.earningsSummary!.totalEarnings.toStringAsFixed(2)}',
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white,
                          fontSize: context.getAdaptiveSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.thisMonth,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white70,
                          fontSize: context.getAdaptiveSize(12),
                        ),
                      ),
                      Text(
                        '\$${workerManager.earningsSummary!.monthlyEarnings.toStringAsFixed(2)}',
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white,
                          fontSize: context.getAdaptiveSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: context.getHeight(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PrimaryButton(
                  text: AppLocalizations.of(context)!.withdrawal,
                  onPressed: () =>
                      _showWithdrawalScreen(context, workerManager),
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

  void _showWithdrawalScreen(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    NavigationService.navigateTo(AppRoutes.withdrawalScreen);
  }

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

          // Orders Chart with enhanced error handling
          Column(
            children: [
              if (ordersManager.error != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorDark),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.errorDark, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Orders: ${ordersManager.error}',
                          style: TextStyle(
                              color: AppColors.errorDark, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh,
                            size: 16, color: AppColors.errorDark),
                        onPressed: () => ordersManager.fetchOrders(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Wrap OrdersStatusChart in error handling
              _SafeOrdersChart(ordersManager: ordersManager),
            ],
          ),

          SizedBox(height: context.getHeight(20)),

          // Services Chart with error handling
          Column(
            children: [
              if (workerManager.servicesError != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorDark),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.errorDark, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Services: ${workerManager.servicesError}',
                          style: TextStyle(
                              color: AppColors.errorDark, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 16, color: AppColors.errorDark),
                        onPressed: () => workerManager.clearError('services'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ServicesStatusChart(workerManager: workerManager),
            ],
          ),
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
          // Show account state error if it exists
          if (workerManager.accountStateError != null)
            Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorDark),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.errorDark, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      workerManager.accountStateError!,
                      style:
                          TextStyle(color: AppColors.errorDark, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.close, size: 16, color: AppColors.errorDark),
                    onPressed: () => workerManager.clearError('accountState'),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
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
            text: workerManager.isAccountStateLoading
                ? AppLocalizations.of(context)!.processing
                : isActive
                    ? AppLocalizations.of(context)!.goOnVacation
                    : AppLocalizations.of(context)!.returnToWork,
            onPressed: workerManager.isAccountStateLoading
                ? () {}
                : () async {
                    // Clear previous errors before attempting the action
                    workerManager.clearError('accountState');
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
              text: AppLocalizations.of(context)!.complete,
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.generalError),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
    }
  }
}

// Safe wrapper for OrdersStatusChart that handles potential errors
class _SafeOrdersChart extends StatelessWidget {
  final OrdersManagerProvider ordersManager;

  const _SafeOrdersChart({required this.ordersManager});

  @override
  Widget build(BuildContext context) {
    // If there's an error, show a simple fallback
    if (ordersManager.error != null) {
      return Container(
        height: 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12),
            Text(
              'Orders chart unavailable',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pull to refresh or try again',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Try to render the chart, with error boundary
    try {
      return OrdersStatusChart(ordersManager: ordersManager);
    } catch (e) {
      print('Error rendering OrdersStatusChart: $e');
      return Container(
        height: 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.orange.shade400,
            ),
            SizedBox(height: 12),
            Text(
              'Chart rendering failed',
              style: TextStyle(
                color: Colors.orange.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }
}
