import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class WithdrawalStatusDialog extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const WithdrawalStatusDialog({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final requests = workerManager.withdrawalRequests;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.withdrawalStatus,
              style: AppTextStyles.title2(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.getHeight(16)),
            requests.isEmpty
                ? Text('No recent withdrawal requests',
                    style: AppTextStyles.text(context))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: context.getWidth(20),
                      columns: [
                        DataColumn(
                            label: Text('Amount',
                                style: AppTextStyles.subTitle(context))),
                        DataColumn(
                            label: Text('Date',
                                style: AppTextStyles.subTitle(context))),
                        DataColumn(
                            label: Text('Status',
                                style: AppTextStyles.subTitle(context))),
                      ],
                      rows: requests
                          .map((request) => DataRow(cells: [
                                DataCell(Text(
                                    '\$${request.amount.toStringAsFixed(2)}')),
                                DataCell(Text(DateFormat('MMM dd, yyyy')
                                    .format(request.sendDate))),
                                DataCell(Text(request.status,
                                    style: TextStyle(
                                        color:
                                            _getStatusColor(request.status)))),
                              ]))
                          .toList(),
                    ),
                  ),
            SizedBox(height: context.getHeight(20)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close,
                  style: AppTextStyles.text(context)
                      .copyWith(color: AppColors.oxblood)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sent':
        return Colors.green;
      case 'Waiting to Send':
        return Colors.orange;
      case 'Request Received':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
