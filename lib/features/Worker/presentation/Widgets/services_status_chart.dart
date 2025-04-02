import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServicesStatusChart extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const ServicesStatusChart({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final chartData = workerManager.getServicesChartData();
    final totalVisible = chartData.fold<int>(
      0,
      (sum, data) => sum + data.visible,
    );
    final totalHidden = chartData.fold<int>(
      0,
      (sum, data) => sum + data.hidden,
    );

    return SizedBox(
      height: context.getHeight(250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: AppColors.primaryColor),
              SizedBox(width: context.getWidth(8)),
              Text(
                AppLocalizations.of(context)!.servicesProvided,
                style: AppTextStyles.subTitle(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(6)),
          Text(
            'Total Services: ${workerManager.myServices.length} (Visible: $totalVisible, Inactive: $totalHidden)',
            style: AppTextStyles.text(context),
          ),
          SizedBox(height: context.getHeight(8)),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                isVisible: true, // Show X-axis for clarity
                labelStyle: AppTextStyles.text(context),
              ),
              primaryYAxis: NumericAxis(
                isVisible: true, // Show Y-axis for better readability
                numberFormat: NumberFormat('###'),
                minimum: 0,
                interval: 1,
                labelStyle: AppTextStyles.text(context),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: AppTextStyles.text(context),
              ),
              series: <CartesianSeries>[
                ColumnSeries<ServiceChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.visible,
                  name: AppLocalizations.of(context)!.visible,
                  color: AppColors.primaryColor,
                  width: 0.3, // Adjust column width
                  spacing: 0.2, // Space between columns in the same category
                ),
                ColumnSeries<ServiceChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.hidden,
                  name: AppLocalizations.of(context)!.inactive,
                  color: AppColors.hintColor,
                  width: 0.3, // Adjust column width
                  spacing: 0.2, // Space between columns in the same category
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
