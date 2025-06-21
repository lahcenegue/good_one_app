import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerManagerProvider>().loadSavedAccountInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.withdrawal,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Show withdrawal-specific error if it exists
                if (provider.withdrawalError != null)
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.errorDark),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.errorDark,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.withdrawalError!,
                            style: TextStyle(
                              color: AppColors.errorDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18),
                          onPressed: () {
                            provider.clearError('withdrawal');
                          },
                          color: AppColors.errorDark,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _buildBankForm(context, provider),
                ),
                _buildFooter(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankForm(
    BuildContext context,
    WorkerManagerProvider provider,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.getAdaptiveSize(20),
          vertical: context.getAdaptiveSize(16),
        ),
        padding: EdgeInsets.all(context.getAdaptiveSize(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.bankAccountInformation,
              style: AppTextStyles.subTitle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
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
      ),
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
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
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
          prefixIcon: Icon(
            icon,
            color: AppColors.oxblood,
            size: context.getAdaptiveSize(20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
            borderSide: BorderSide(color: AppColors.oxblood, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.getAdaptiveSize(16),
            vertical: context.getAdaptiveSize(16),
          ),
          labelStyle: AppTextStyles.text(context).copyWith(
            color: Colors.grey[600],
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.getAdaptiveSize(24)),
          topRight: Radius.circular(context.getAdaptiveSize(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
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
                onPressed: provider.isWithdrawalLoading
                    ? () {}
                    : () async {
                        // Clear previous withdrawal errors before attempting
                        provider.clearError('withdrawal');

                        final success =
                            await provider.submitWithdrawal(context);

                        if (success) {
                          NavigationService.goBack();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
