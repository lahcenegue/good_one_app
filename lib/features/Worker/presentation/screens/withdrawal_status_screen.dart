import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/withdrawal_model.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

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
        // Sort withdrawal requests by date (most recent first)
        final requests = workerManager.withdrawStatus ?? [];
        final sortedRequests = List<WithdrawStatus>.from(requests);

        // Sort by createdAt date in descending order (most recent first)
        sortedRequests.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1; // null dates go to end
          if (b.createdAt == null) return -1;

          try {
            final dateA = DateTime.parse(a.createdAt!);
            final dateB = DateTime.parse(b.createdAt!);
            return dateB.compareTo(dateA); // Descending order (newest first)
          } catch (e) {
            // If date parsing fails, maintain original order
            return 0;
          }
        });

        if (workerManager.isLoading) {
          return Scaffold(
            body: LoadingIndicator(),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: _buildBodyContent(context, workerManager, sortedRequests),
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
    return Column(
      children: [
        // Add this new balance summary card at the top
        if (workerManager.balance != null ||
            workerManager.earningsSummary != null)
          Container(
            margin: EdgeInsets.all(context.getAdaptiveSize(16)),
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
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
                Text(
                  AppLocalizations.of(context)!.balanceSummary,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getHeight(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.availableBalance,
                      style: AppTextStyles.text(context),
                    ),
                    Text(
                      '\$${workerManager.balance?.balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.title2(context).copyWith(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (workerManager.earningsSummary != null) ...[
                  SizedBox(height: context.getHeight(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalEarnings,
                        style: AppTextStyles.text(context),
                      ),
                      Text(
                        '\$${workerManager.earningsSummary!.totalEarnings.toStringAsFixed(2)}',
                        style: AppTextStyles.text(context).copyWith(
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
                        AppLocalizations.of(context)!.totalWithdrawn,
                        style: AppTextStyles.text(context),
                      ),
                      Text(
                        '\$${workerManager.earningsSummary!.totalWithdrawn.toStringAsFixed(2)}',
                        style: AppTextStyles.text(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

        // Existing content
        Expanded(
          child: requests.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
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
                ),
        ),
      ],
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
              Icons.receipt_long_outlined,
              size: context.getAdaptiveSize(60),
              color: AppColors.hintColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: context.getHeight(20)),
            Text(
              AppLocalizations.of(context)!.noRecentWithdrawals,
              style: AppTextStyles.title2(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              AppLocalizations.of(context)!.checkBackLaterUpdates,
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
        color: AppColors.backgroundCard,
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
                    AppLocalizations.of(context)!.amount,
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
              _buildStatusChip(context, request.status ?? -1),
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
        return AppColors.successColor;
      case 1:
        return AppColors.warningColor;
      case 0:
        return AppColors.infoColor;
      default:
        return AppColors.blackText;
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
