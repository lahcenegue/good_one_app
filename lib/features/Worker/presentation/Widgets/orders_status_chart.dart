import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrdersStatusChart extends StatelessWidget {
  final OrdersManagerProvider ordersManager;

  const OrdersStatusChart({super.key, required this.ordersManager});

  @override
  Widget build(BuildContext context) {
    final chartData = ordersManager.getRequestStatusChartData();
    return SizedBox(
      height: context.getHeight(200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: AppColors.primaryColor),
              SizedBox(width: context.getWidth(8)),
              Text(
                AppLocalizations.of(context)!.requestStatus,
                style: AppTextStyles.subTitle(context),
              ),
            ],
          ),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: AppTextStyles.text(context),
              ),
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  radius: '80%',
                  innerRadius: '50%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
