import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WithdrawalDialog extends StatefulWidget {
  final WorkerManagerProvider workerManager;

  const WithdrawalDialog({
    super.key,
    required this.workerManager,
  });

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
              AppLocalizations.of(context)!.withdrawal,
              style: AppTextStyles.title2(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.getHeight(16)),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.oxblood,
              labelColor: AppColors.oxblood,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.bankAccount),
                Tab(text: 'Interac'),
              ],
            ),
            SizedBox(height: context.getHeight(16)),
            SizedBox(
              height: context.getHeight(200),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _bankForm(),
                  _interacForm(),
                ],
              ),
            ),
            SizedBox(height: context.getHeight(20)),
            PrimaryButton(
              text: AppLocalizations.of(context)!.submit,
              onPressed: () => _submitWithdrawal(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankForm() {
    return ListView(
      children: [
        _buildTextField(context, 'Full Name'),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, 'Transit'),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, 'Institution'),
        SizedBox(height: context.getHeight(12)),
        _buildTextField(context, 'Account'),
      ],
    );
  }

  Widget _interacForm() {
    return _buildTextField(
      context,
      AppLocalizations.of(context)!.email,
    );
  }

  Widget _buildTextField(BuildContext context, String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.dimGray,
      ),
    );
  }

  void _submitWithdrawal(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Withdrawal request submitted')),
    );
  }
}
