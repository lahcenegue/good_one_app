import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(context.getAdaptiveSize(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.getHeight(16)),
                    _buildCustomerPolicySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildServiceProviderPolicySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildGeneralRulesSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.cancellationPolicy,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildCustomerPolicySection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.cancellationPolicyForCustomers,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.freeCancellationWindow,
          description:
              AppLocalizations.of(context)!.freeCancellationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.lateCancellations,
          description:
              AppLocalizations.of(context)!.lateCancellationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.noShows,
          description: AppLocalizations.of(context)!.noShowDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.refundPolicy,
          description: AppLocalizations.of(context)!.refundPolicyDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.emergencyCancellations,
          description:
              AppLocalizations.of(context)!.emergencyCancellationDescription,
        ),
      ],
    );
  }

  Widget _buildServiceProviderPolicySection(BuildContext context) {
    return _buildSection(
      context,
      title:
          AppLocalizations.of(context)!.cancellationPolicyForServiceProviders,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.advanceNotice,
          description: AppLocalizations.of(context)!.advanceNoticeDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.frequentCancellations,
          description:
              AppLocalizations.of(context)!.frequentCancellationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.customerCompensation,
          description:
              AppLocalizations.of(context)!.customerCompensationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.unavoidableCancellations,
          description:
              AppLocalizations.of(context)!.unavoidableCancellationDescription,
        ),
      ],
    );
  }

  Widget _buildGeneralRulesSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.generalRules,
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.generalRulesDescription1,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.generalRulesDescription2,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return GeneralBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title2(context).copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.getHeight(16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPolicyItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.getHeight(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: context.getAdaptiveSize(8),
                  color: AppColors.oxblood,
                ),
                SizedBox(width: context.getWidth(8)),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subTitle(context).copyWith(
                      color: AppColors.oxblood,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (title.isNotEmpty) SizedBox(height: context.getHeight(4)),
          Text(
            description,
            style: AppTextStyles.text(context).copyWith(
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
