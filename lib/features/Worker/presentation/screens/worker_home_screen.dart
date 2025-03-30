import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
        if (workerManager.isLoading && ordersManager.isOrdersLoading) {
          return LoadingIndicator();
        }

        if (workerManager.error != null) {
          return AppErrorWidget(
            message: workerManager.error!,
            onRetry: workerManager.initialize,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await workerManager.initialize();
            await ordersManager.initialize();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(20),
              vertical: context.getHeight(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, workerManager),
                SizedBox(height: context.getHeight(30)),
                _buildDashboardOverview(context, workerManager, ordersManager),
                SizedBox(height: context.getHeight(5)),
                _buildVacationToggle(context, workerManager),
                SizedBox(height: context.getHeight(5)),
                _buildSecurityCheckStatus(context, workerManager),
                SizedBox(height: context.getHeight(20)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header Section
  Widget _buildHeader(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    final worker = workerManager.workerInfo;

    return Row(
      children: [
        UserAvatar(
          picture: worker?.picture,
          size: context.getWidth(40),
        ),
        SizedBox(width: context.getWidth(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.hello}, ${worker?.fullName ?? ''}',
                style: AppTextStyles.title2(context),
              ),
              SizedBox(height: context.getHeight(4)),
              Text(
                '${worker?.city ?? ''}, ${worker?.country ?? ''}',
                style: AppTextStyles.subTitle(context),
              ),
            ],
          ),
        ),
        _buildIconButton(
          context,
          AppAssets.notification,
          () {
            NavigationService.navigateTo(AppRoutes.workerNotificationsScreen);
          },
        ),
        SizedBox(width: context.getWidth(10)),
        _buildIconButton(
          context,
          AppAssets.message,
          () {
            if (workerManager.workerInfo != null) {
              NavigationService.navigateTo(AppRoutes.conversations);
            }
          },
        ),
      ],
    );
  }

  // Icon Button Helper with Badge Support
  Widget _buildIconButton(
    BuildContext context,
    String asset,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(10)),
        decoration: BoxDecoration(
          color: AppColors.dimGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dimGray),
        ),
        child: Image.asset(
          asset,
          width: context.getAdaptiveSize(24),
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // Dashboard Overview with Syncfusion Charts
  Widget _buildDashboardOverview(
    BuildContext context,
    WorkerManagerProvider workerManager,
    OrdersManagerProvider ordersManager,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.hintColor,
          ),
          borderRadius: BorderRadius.circular(context.getAdaptiveSize(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.serviceSummary,
            style: AppTextStyles.title(context),
          ),
          SizedBox(height: context.getHeight(20)),
          _buildRequestStatusChart(context, ordersManager),
          SizedBox(height: context.getHeight(20)),
          _buildServicesProvidedChart(context, workerManager),
        ],
      ),
    );
  }

  // Request Status Pie Chart (Syncfusion)
  Widget _buildRequestStatusChart(
      BuildContext context, OrdersManagerProvider ordersManager) {
    final totalOrders = ordersManager.totalOrders;
    final pendingOrders = ordersManager.pendingOrders;
    final completedOrders = totalOrders - pendingOrders;
    final rejectedOrders = 1;

    final data = [
      ChartData('Pending', pendingOrders, Colors.orange),
      ChartData('Completed', completedOrders, Colors.green),
      ChartData('Rejected', rejectedOrders, Colors.red),
    ].where((item) => item.value > 0).toList(); // Filter out zero values

    return SizedBox(
      height: context.getHeight(200),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions_sharp,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: context.getWidth(8)),
              Text(
                'Request Status',
                style: AppTextStyles.subTitle(context),
              ),
            ],
          ),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: AppTextStyles.text(context),
              ),
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelMapper: (ChartData data, _) => '${data.value}',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  enableTooltip: true,
                  radius: '100%',
                  innerRadius: '50%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Services Provided Column Chart (Syncfusion)
  Widget _buildServicesProvidedChart(
      BuildContext context, WorkerManagerProvider workerManager) {
    // Calculate total and visible services
    final totalServices = workerManager.myServices.length;
    final visibleServices =
        workerManager.myServices.where((service) => service.active == 1).length;
    final hiddenServices = totalServices - visibleServices;

    // Data for the stacked column chart
    final data = [
      ServiceChartData('Services', visibleServices, hiddenServices),
    ];

    return SizedBox(
      height: context.getHeight(180),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.build,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: context.getWidth(8)),
              Text(
                'Services Provided',
                style: AppTextStyles.subTitle(context),
              ),
            ],
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                isVisible: false,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: (totalServices + 2).toDouble(),
                isVisible: false, // Hide Y-axis for cleaner look
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: AppTextStyles.text(context),
              ),
              series: <CartesianSeries>[
                // Visible Services
                StackedColumnSeries<ServiceChartData, String>(
                  dataSource: data,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.visible,
                  name: 'Visible',
                  color: AppColors.primaryColor,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  enableTooltip: true,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                // Hidden Services
                StackedColumnSeries<ServiceChartData, String>(
                  dataSource: data,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.hidden,
                  name: 'InActive',
                  color: AppColors.hintColor,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  enableTooltip: true,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vacation Mode Toggle
  Widget _buildVacationToggle(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                !workerManager.workerInfo!.active
                    ? Icons.beach_access
                    : Icons.work,
                color: !workerManager.workerInfo!.active
                    ? AppColors.primaryColor
                    : Colors.green,
                size: context.getAdaptiveSize(24),
              ),
              SizedBox(width: context.getWidth(10)),
              Text(
                !workerManager.workerInfo!.active
                    ? AppLocalizations.of(context)!.onVacation
                    : AppLocalizations.of(context)!.available,
                style: AppTextStyles.subTitle(context).copyWith(
                  color: !workerManager.workerInfo!.active
                      ? AppColors.primaryColor
                      : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          PrimaryButton(
            text: !workerManager.workerInfo!.active
                ? AppLocalizations.of(context)!.returnToWork
                : AppLocalizations.of(context)!.goOnVacation,
            onPressed: () async {
              print(workerManager.workerInfo!.active);
              await workerManager
                  .changeAccountState(workerManager.workerInfo!.active ? 0 : 1);
            },
          ),
        ],
      ),
    );
  }

  // Security Check Status
  Widget _buildSecurityCheckStatus(
      BuildContext context, WorkerManagerProvider workerManager) {
    final securityCheckCompleted =
        workerManager.workerInfo?.securityCheck ?? false;

    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primaryColor,
                size: 24,
              ),
              SizedBox(width: context.getWidth(10)),
              Text(
                AppLocalizations.of(context)!.securityCheck,
                style: AppTextStyles.title(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          Row(
            children: [
              Icon(
                securityCheckCompleted ? Icons.check_circle : Icons.warning,
                color: securityCheckCompleted
                    ? Colors.green
                    : AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(height: context.getHeight(8)),
              Text(
                securityCheckCompleted
                    ? AppLocalizations.of(context)!.securityCheckCompleted
                    : AppLocalizations.of(context)!.securityCheckPending,
                style: AppTextStyles.text(context).copyWith(
                  fontSize: 14,
                  color: securityCheckCompleted
                      ? Colors.green
                      : AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          if (!securityCheckCompleted)
            PrimaryButton(
              text: AppLocalizations.of(context)!.completeSecurityCheck,
              onPressed: () async {
                const url =
                    'https://securitycheck.example.com'; // Replace with actual URL
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch security check URL'),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

// Helper class for chart data
class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

class ServiceChartData {
  final String category;
  final int visible;
  final int hidden;

  ServiceChartData(this.category, this.visible, this.hidden);
}
