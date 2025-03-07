import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Providers/user_state_provider.dart';

class PaymentMethodSelectionScreen extends StatelessWidget {
  const PaymentMethodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStateProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context, userManager),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.selectPaymentMethod,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserStateProvider userManager,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.paymentMethods,
              style: AppTextStyles.title2(context),
            ),
            SizedBox(height: context.getHeight(16)),
            _buildPaymentOption(
              context,
              AppLocalizations.of(context)!.creditCard,
              Icons.credit_card,
              () {},
            ),
            SizedBox(height: context.getHeight(12)),
            _buildPaymentOption(
              context,
              'Appel Pay',
              Icons.apple_outlined,
              () {},
            ),
            SizedBox(height: context.getHeight(32)),
            PrimaryButton(
              text: AppLocalizations.of(context)!.proceedToPayment,
              onPressed: () {
                _showPaymentMethodRequiredDialog(context);
              },
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.getWidth(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: context.getAdaptiveSize(24),
            ),
            SizedBox(width: context.getWidth(12)),
            Text(
              title,
              style: AppTextStyles.text(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectPaymentMethod),
        content: Text(AppLocalizations.of(context)!.pleaseSelectPaymentMethod),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.paymentSuccessful,
            style: AppTextStyles.title2(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: context.getAdaptiveSize(60),
            ),
            SizedBox(height: context.getHeight(16)),
            Text(
              AppLocalizations.of(context)!.bookingConfirmed,
              style: AppTextStyles.text(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.paymentFailed,
          style: AppTextStyles.title2(context),
        ),
        content: Text(
          message,
          style: AppTextStyles.text(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}
