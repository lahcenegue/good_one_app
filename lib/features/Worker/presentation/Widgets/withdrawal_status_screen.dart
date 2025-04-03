import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/withdrawal_model.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WithdrawalStatusScreen extends StatefulWidget {
  const WithdrawalStatusScreen({
    super.key,
  });

  @override
  State<WithdrawalStatusScreen> createState() => _WithdrawalStatusScreenState();
}

class _WithdrawalStatusScreenState extends State<WithdrawalStatusScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WorkerManagerProvider>().fetchWithdrawalStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        final requests = workerManager.withdrawStatus ?? [];

        if (workerManager.isLoading) {
          return Scaffold(
            body: LoadingIndicator(),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: _buildBodyContent(context, workerManager, requests),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.withdrawalStatus,
      ),
      titleTextStyle: AppTextStyles.appBarTitle(context),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    WorkerManagerProvider workerManager,
    List<WithdrawStatus> requests,
  ) {
    if (requests.isEmpty) {
      return _buildEmptyState(context);
    }

    // Use ListView.separated for automatic dividers or spacing
    return RefreshIndicator(
      onRefresh: () => workerManager.fetchWithdrawalStatus(),
      child: ListView.separated(
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildWithdrawalCard(context, request);
        },
        separatorBuilder: (context, index) =>
            SizedBox(height: context.getHeight(12)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined, // More relevant icon
              size: context.getAdaptiveSize(60),
              color: AppColors.hintColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: context.getHeight(20)),
            Text(
              'no Recent Withdrawals', // Use localization
              style: AppTextStyles.title2(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              'check BackLater For Updates', // Use localization
              style: AppTextStyles.subTitle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(
    BuildContext context,
    WithdrawStatus request,
  ) {
    final formattedDate = request.createdAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a')
            .format(DateTime.parse(request.createdAt!).toLocal())
        : 'N/A';

    final amountString = request.amount != null
        ? '\$${request.amount!.toStringAsFixed(2)}'
        : 'N/A';

    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.hintColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount', // Use localization
                    style: AppTextStyles.title2(context),
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Text(
                    amountString,
                    style: AppTextStyles.title2(context),
                  ),
                ],
              ),
              // Status Chip
              _buildStatusChip(
                  context, request.status ?? -1), // Handle null status
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Divider(color: AppColors.primaryColor.withValues(alpha: 0.5)),
          SizedBox(height: context.getHeight(8)),
          // Date Section with Icon
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: context.getAdaptiveSize(16),
              ),
              SizedBox(width: context.getWidth(8)),
              Expanded(
                child: Text(
                  formattedDate,
                  style: AppTextStyles.text(context),
                ),
              ),
            ],
          ),
          // Optional: Display other details if available and relevant
          if (request.email != null) ...[
            SizedBox(height: context.getHeight(8)),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: context.getAdaptiveSize(16),
                ),
                SizedBox(width: context.getWidth(8)),
                Expanded(
                  child: Text(
                    request.email!,
                    style: AppTextStyles.text(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Bank details
          if (request.account != null) ...[
            SizedBox(height: context.getHeight(8)),
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  size: context.getAdaptiveSize(16),
                ),
                SizedBox(width: context.getWidth(8)),
                Expanded(
                  child: Text(
                    request.account.toString(),
                    style: AppTextStyles.text(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, int status) {
    final statusText = _getStatusString(context, status);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(12),
        vertical: context.getHeight(6),
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.title2(context).copyWith(
          color: statusColor,
          fontSize: context.getAdaptiveSize(14),
        ),
      ),
    );
  }

  // Helper methods for status (can be moved to a utility class)
  Color _getStatusColor(int status) {
    switch (status) {
      case 2:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 0:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  String _getStatusString(BuildContext context, int status) {
    // Use AppLocalizations for status strings
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 2:
        return l10n.statusSent;
      case 1:
        return l10n.statusWaitingToSend;
      case 0:
        return l10n.statusRequestReceived;
      default:
        return l10n.unknown;
    }
  }
}

// class WithdrawalStatusScreen extends StatefulWidget {
//   const WithdrawalStatusScreen({
//     super.key,
//   });

//   @override
//   State<WithdrawalStatusScreen> createState() => _WithdrawalStatusScreenState();
// }

// class _WithdrawalStatusScreenState extends State<WithdrawalStatusScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final workerManager =
//           Provider.of<WorkerManagerProvider>(context, listen: false);
//       await workerManager.fetchWithdrawalStatus();
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WorkerManagerProvider>(
//       builder: (context, workerManager, _) {
//         final requests = workerManager.withdrawStatus ?? [];

//         if (workerManager.isLoading) {
//           return Scaffold(
//             body: LoadingIndicator(),
//           );
//         }
//         return Scaffold(
//           appBar: _buildAppBar(context, workerManager),
//           body: SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildContent(context, requests),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(
//     BuildContext context,
//     WorkerManagerProvider workerManager,
//   ) {
//     return AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.withdrawalStatus,
//           style: AppTextStyles.appBarTitle(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () async {
//               await workerManager.fetchWithdrawalStatus();
//             },
//           ),
//         ]);
//   }

//   Widget _buildContent(BuildContext context, List<WithdrawStatus> requests) {
//     return requests.isEmpty
//         ? _buildEmptyState(context)
//         : _buildWithdrawalList(context, requests);
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.history_toggle_off,
//             size: context.getAdaptiveSize(64),
//             color: Colors.white70,
//           ),
//           SizedBox(height: context.getHeight(16)),
//           Text(
//             'No recent withdrawal requests',
//             style: AppTextStyles.subTitle(context).copyWith(
//               color: Colors.white70,
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWithdrawalList(
//     BuildContext context,
//     List<WithdrawStatus> requests,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Withdrawal History',
//           style: AppTextStyles.title(context).copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: context.getHeight(16)),
//         Expanded(
//           child: ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               return _buildWithdrawalCard(context, request, index);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWithdrawalCard(
//       BuildContext context, WithdrawStatus request, int index) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.only(bottom: context.getHeight(16)),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white,
//               Colors.grey.shade100,
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(context.getAdaptiveSize(16)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.monetization_on,
//                         color: AppColors.oxblood,
//                         size: context.getAdaptiveSize(24),
//                       ),
//                       SizedBox(width: context.getWidth(8)),
//                       Text(
//                         '\$${request.amount!.toStringAsFixed(2)}',
//                         style: AppTextStyles.subTitle(context).copyWith(
//                           color: AppColors.oxblood,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: context.getHeight(8)),
//                   Text(
//                     DateFormat('MMM dd, yyyy').format(
//                       DateTime.parse(request.createdAt!).toLocal(),
//                     ),
//                     style: AppTextStyles.text(context).copyWith(
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   if (request.email != null) ...[
//                     SizedBox(height: context.getHeight(4)),
//                     Text(
//                       'To: ${request.email}',
//                       style: AppTextStyles.text(context).copyWith(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               _buildStatusChip(context, request.status!),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(BuildContext context, int status) {
//     final statusString = _getStatusString(status);
//     final statusColor = _getStatusColor(status);

//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: context.getWidth(12),
//         vertical: context.getHeight(6),
//       ),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: statusColor.withOpacity(0.5)),
//       ),
//       child: Text(
//         statusString,
//         style: AppTextStyles.text(context).copyWith(
//           color: statusColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(int status) {
//     switch (status) {
//       case 2:
//         return Colors.green;
//       case 1:
//         return Colors.orange;
//       case 0:
//         return Colors.blue;
//       default:
//         return Colors.black;
//     }
//   }

//   String _getStatusString(int status) {
//     switch (status) {
//       case 2:
//         return 'Sent';
//       case 1:
//         return 'Waiting to Send';
//       case 0:
//         return 'Request Received';
//       default:
//         return 'Sent';
//     }
//   }
// }
