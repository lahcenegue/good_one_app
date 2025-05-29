import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class WithdrawalDialog extends StatefulWidget {
  const WithdrawalDialog({
    super.key,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerManagerProvider>().loadSavedAccountInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, provider, _) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(24)),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildTabBar(context, provider),
                Flexible(child: _buildTabContent(context, provider)),
                _buildFooter(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(24)),
      decoration: BoxDecoration(
        color: AppColors.oxblood,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.getAdaptiveSize(24)),
          topRight: Radius.circular(context.getAdaptiveSize(24)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: context.getAdaptiveSize(28),
          ),
          SizedBox(width: context.getWidth(12)),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.withdrawal,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.getAdaptiveSize(20)),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.oxblood,
        indicatorWeight: 3,
        labelColor: AppColors.oxblood,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: AppTextStyles.title2(context),
        unselectedLabelStyle: AppTextStyles.text(context),
        onTap: (index) {
          // Update the bank selection based on tab
          provider.setBankSelected(index == 0);
        },
        tabs: [
          Tab(
            icon: Icon(
              Icons.account_balance,
              size: context.getAdaptiveSize(20),
            ),
            text: AppLocalizations.of(context)!.bankAccount,
          ),
          Tab(
            icon: Icon(
              Icons.email_outlined,
              size: context.getAdaptiveSize(20),
            ),
            text: 'Interac',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildBankForm(context, provider),
          _buildInteracForm(context, provider),
        ],
      ),
    );
  }

  Widget _buildBankForm(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.bankAccountInformation,
            style: AppTextStyles.subTitle(context),
          ),
          SizedBox(height: context.getHeight(24)),
          _buildEnhancedTextField(
            context: context,
            controller: provider.amountController,
            label: AppLocalizations.of(context)!.amount,
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: context.getHeight(16)),
          _buildEnhancedTextField(
            context: context,
            controller: provider.fullNameController,
            label: AppLocalizations.of(context)!.fullName,
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: context.getHeight(16)),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedTextField(
                  context: context,
                  controller: provider.transitController,
                  label: AppLocalizations.of(context)!.transit,
                  icon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: _buildEnhancedTextField(
                  context: context,
                  controller: provider.institutionController,
                  label: AppLocalizations.of(context)!.institution,
                  icon: Icons.business_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(16)),
          _buildEnhancedTextField(
            context: context,
            controller: provider.accountController,
            label: AppLocalizations.of(context)!.account,
            icon: Icons.account_balance_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildInteracForm(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.interacTransferInformation,
          style: AppTextStyles.subTitle(context),
        ),
        SizedBox(height: context.getHeight(24)),
        _buildEnhancedTextField(
          context: context,
          controller: provider.amountController,
          label: AppLocalizations.of(context)!.amount,
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: context.getHeight(16)),
        _buildEnhancedTextField(
          context: context,
          controller: provider.emailController,
          label: AppLocalizations.of(context)!.email,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: context.getHeight(24)),
        Container(
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.5)!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.interacMessage,
                  style: AppTextStyles.text(context).copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: AppTextStyles.text(context),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.oxblood),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
            borderSide: BorderSide(color: AppColors.oxblood, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.getAdaptiveSize(16),
            vertical: context.getAdaptiveSize(16),
          ),
          labelStyle:
              AppTextStyles.text(context).copyWith(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.getAdaptiveSize(24)),
          bottomRight: Radius.circular(context.getAdaptiveSize(24)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: provider.saveAccountInfo,
                onChanged: (value) {
                  provider.setSaveAccountInfo(value ?? true);
                },
                activeColor: AppColors.oxblood,
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.saveAccount,
                  style: AppTextStyles.text(context),
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(16)),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: provider.isWithdrawalLoading
                  ? AppLocalizations.of(context)!.processing
                  : AppLocalizations.of(context)!.submit,
              onPressed: () async {
                if (!provider.isWithdrawalLoading) {
                  await provider.submitWithdrawal(
                      context, _tabController.index == 0);

                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _submitWithdrawal(BuildContext context) async {
  //   if (!_validateForm()) {
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.requiredFields),
  //         backgroundColor: AppColors.primaryColor,
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     // Save account info if requested
  //     await _saveAccountInfos();

  //     final success = await widget.workerManager.requestWithdrawal();

  //     if (success) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   AppLocalizations.of(context)!.withdrawalRequestSubmitted,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           backgroundColor: Colors.green[600],
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.generalError),
  //         backgroundColor: Colors.red[600],
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
}
