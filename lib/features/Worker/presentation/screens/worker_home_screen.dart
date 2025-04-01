import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';
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

// Constants for reusability
const _kSectionPadding = 16.0;
const _kCardBorderRadius = 16.0;
const _kSpacing = 20.0;

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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(_kSpacing),
                vertical: context.getHeight(_kSpacing),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkerHeader(workerManager: workerManager),
                  SizedBox(height: context.getHeight(_kSpacing)),
                  WorkerBalanceCard(workerManager: workerManager),
                  SizedBox(height: context.getHeight(_kSpacing)),
                  DashboardOverviewCard(
                    workerManager: workerManager,
                    ordersManager: ordersManager,
                  ),
                  SizedBox(height: context.getHeight(_kSpacing)),
                  VacationToggleCard(workerManager: workerManager),
                  SizedBox(height: context.getHeight(_kSpacing)),
                  SecurityCheckCard(workerManager: workerManager),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Header Widget
class WorkerHeader extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const WorkerHeader({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
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
                style: AppTextStyles.subTitle(context).copyWith(
                  color: AppColors.hintColor,
                ),
              ),
            ],
          ),
        ),
        _IconButton(
          asset: AppAssets.notification,
          onTap: () =>
              NavigationService.navigateTo(AppRoutes.workerNotificationsScreen),
        ),
        SizedBox(width: context.getWidth(10)),
        _IconButton(
          asset: AppAssets.message,
          onTap: workerManager.workerInfo != null
              ? () => NavigationService.navigateTo(AppRoutes.conversations)
              : null,
        ),
      ],
    );
  }
}

// Reusable Icon Button
class _IconButton extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;

  const _IconButton({required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
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
}

// Balance Card
class WorkerBalanceCard extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const WorkerBalanceCard({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      color: AppColors.oxblood,
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
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
                  '\$${workerManager.balance?.balance!.toStringAsFixed(2) ?? '0.00'}',
                  style: AppTextStyles.title2(context).copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallPrimaryButton(
                  text: AppLocalizations.of(context)!.requestWithdrawal,
                  onPressed: () =>
                      _showWithdrawalDialog(context, workerManager),
                ),
                SmallSecondaryButton(
                  text: AppLocalizations.of(context)!.checkWithdrawalStatus,
                  onPressed: () => _showStatusDialog(context, workerManager),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(
      BuildContext context, WorkerManagerProvider workerManager) {
    showDialog(
      context: context,
      builder: (_) => WithdrawalDialog(workerManager: workerManager),
    );
  }

  void _showStatusDialog(
      BuildContext context, WorkerManagerProvider workerManager) {
    showDialog(
      context: context,
      builder: (_) => WithdrawalStatusDialog(workerManager: workerManager),
    );
  }
}

// Withdrawal Dialog
class WithdrawalDialog extends StatefulWidget {
  final WorkerManagerProvider workerManager;

  const WithdrawalDialog({super.key, required this.workerManager});

  @override
  _WithdrawalDialogState createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  bool _isBankSelected = true;
  final _nameController = TextEditingController();
  final _transitController = TextEditingController();
  final _institutionController = TextEditingController();
  final _accountController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.of(context)!.requestWithdrawal,
        style: AppTextStyles.title2(context),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBankSelected = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isBankSelected
                            ? AppColors.primaryColor
                            : AppColors.dimGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.bankAccount,
                          style: AppTextStyles.text(context).copyWith(
                            color:
                                _isBankSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.getWidth(8)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBankSelected = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isBankSelected
                            ? AppColors.primaryColor
                            : AppColors.dimGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Interac',
                          style: AppTextStyles.text(context).copyWith(
                            color:
                                !_isBankSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isBankSelected
                  ? _buildBankFields(context)
                  : _buildInteracField(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: AppTextStyles.text(context).copyWith(color: Colors.grey),
          ),
        ),
        PrimaryButton(
          text: AppLocalizations.of(context)!.submit,
          onPressed: () => _submitWithdrawal(context),
        ),
      ],
    );
  }

  Widget _buildBankFields(BuildContext context) {
    return Column(
      key: const ValueKey('bank'),
      children: [
        _buildTextField(
            context, _nameController, AppLocalizations.of(context)!.fullName),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, _transitController, 'Transit'),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, _institutionController, 'Institution'),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, _accountController, 'Account'),
      ],
    );
  }

  Widget _buildInteracField(BuildContext context) {
    return Column(
      key: const ValueKey('interac'),
      children: [
        _buildTextField(
            context, _emailController, AppLocalizations.of(context)!.email),
      ],
    );
  }

  Widget _buildTextField(
      BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppTextStyles.text(context).copyWith(color: AppColors.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.dimGray),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  void _submitWithdrawal(BuildContext context) {
    if (_isBankSelected) {
      final name = _nameController.text.trim();
      final transit = _transitController.text.trim();
      final institution = _institutionController.text.trim();
      final account = _accountController.text.trim();
      if (name.isEmpty ||
          transit.isEmpty ||
          institution.isEmpty ||
          account.isEmpty) {
        _showSnackBar(context, AppLocalizations.of(context)!.fillAllFields);
        return;
      }
      // widget.workerManager.requestWithdrawal(
      //   method: 'bank',
      //   details: {
      //     'name': name,
      //     'transit': transit,
      //     'institution': institution,
      //     'account': account,
      //   },
      // );
    } else {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _showSnackBar(context, AppLocalizations.of(context)!.emailRequired);
        return;
      }
      // widget.workerManager
      //     .requestWithdrawal(method: 'interac', details: {'email': email});
    }
    Navigator.pop(context);
    _showSnackBar(context, AppLocalizations.of(context)!.withdrawalRequested);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}

// Withdrawal Status Dialog
class WithdrawalStatusDialog extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const WithdrawalStatusDialog({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final status =
        workerManager.withdrawalStatus ?? 'No recent withdrawal requests';
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.of(context)!.withdrawalStatus,
        style: AppTextStyles.title2(context),
      ),
      content: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dimGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: AppTextStyles.text(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.close,
            style: AppTextStyles.text(context)
                .copyWith(color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }
}

// Dashboard Overview Card
class DashboardOverviewCard extends StatelessWidget {
  final WorkerManagerProvider workerManager;
  final OrdersManagerProvider ordersManager;

  const DashboardOverviewCard({
    super.key,
    required this.workerManager,
    required this.ordersManager,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(_kSectionPadding)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.serviceSummary,
              style: AppTextStyles.title(context),
            ),
            SizedBox(height: context.getHeight(_kSpacing)),
            RequestStatusChart(ordersManager: ordersManager),
            SizedBox(height: context.getHeight(_kSpacing)),
            ServicesProvidedChart(workerManager: workerManager),
          ],
        ),
      ),
    );
  }
}

// Request Status Chart
class RequestStatusChart extends StatelessWidget {
  final OrdersManagerProvider ordersManager;

  const RequestStatusChart({super.key, required this.ordersManager});

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

// Services Provided Chart
class ServicesProvidedChart extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const ServicesProvidedChart({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final chartData = workerManager.getServicesChartData();
    return SizedBox(
      height: context.getHeight(180),
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
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(isVisible: false),
              primaryYAxis: const NumericAxis(isVisible: false),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: AppTextStyles.text(context),
              ),
              series: <CartesianSeries>[
                StackedColumnSeries<ServiceChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.visible,
                  name: AppLocalizations.of(context)!.visible,
                  color: AppColors.primaryColor,
                ),
                StackedColumnSeries<ServiceChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ServiceChartData data, _) => data.category,
                  yValueMapper: (ServiceChartData data, _) => data.hidden,
                  name: AppLocalizations.of(context)!.inactive,
                  color: AppColors.hintColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Vacation Toggle Card
class VacationToggleCard extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const VacationToggleCard({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final isActive = workerManager.workerInfo?.active ?? true;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(_kSectionPadding)),
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
      ),
    );
  }
}

// Security Check Card
class SecurityCheckCard extends StatelessWidget {
  final WorkerManagerProvider workerManager;

  const SecurityCheckCard({super.key, required this.workerManager});

  @override
  Widget build(BuildContext context) {
    final isSecurityCheckCompleted =
        workerManager.workerInfo?.securityCheck ?? false;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getAdaptiveSize(_kSectionPadding)),
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
            SizedBox(height: context.getHeight(12)),
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
            if (!isSecurityCheckCompleted) ...[
              SizedBox(height: context.getHeight(12)),
              PrimaryButton(
                text: AppLocalizations.of(context)!.completeSecurityCheck,
                onPressed: () => _launchSecurityCheck(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchSecurityCheck(BuildContext context) async {
    const url = 'https://securitycheck.example.com'; // Replace with actual URL
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
