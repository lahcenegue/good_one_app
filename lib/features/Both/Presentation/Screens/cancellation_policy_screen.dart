import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          title: 'Free Cancellation Window',
          description:
              'Customers can cancel a booking for free if done at least 48 hours before the scheduled service.',
        ),
        _buildPolicyItem(
          context,
          title: 'Late Cancellations',
          description:
              'If a cancellation is made within 24 hours of the scheduled service, a cancellation fee of 20% of the paid amount may be charged.',
        ),
        _buildPolicyItem(
          context,
          title: 'No-Shows',
          description:
              'If the customer fails to be present at the service location without prior cancellation, they may be charged the full service fee.',
        ),
        _buildPolicyItem(
          context,
          title: 'Refund Policy',
          description:
              'Refund eligibility depends on the specific service provider\'s policy. In some cases, partial refunds may be issued after deducting applicable fees.',
        ),
        _buildPolicyItem(
          context,
          title: 'Emergency Cancellations',
          description:
              'If a cancellation is due to an emergency (e.g., medical issues, accidents), the customer must provide proof, and a full refund may be issued at the platform’s discretion.',
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
          title: 'Advance Notice',
          description:
              'Service providers must inform the customer and the platform at least 48 hours before the scheduled service if they need to cancel.',
        ),
        _buildPolicyItem(
          context,
          title: 'Frequent Cancellations',
          description:
              'Repeated last-minute cancellations or no-shows may result in penalties, lower visibility in search results, or account suspension.',
        ),
        _buildPolicyItem(
          context,
          title: 'Customer Compensation',
          description:
              'If a service provider cancels after a customer has already made preparations (e.g., purchasing materials, rearranging schedules), compensation may be required.',
        ),
        _buildPolicyItem(
          context,
          title: 'Unavoidable Cancellations',
          description:
              'If a service provider must cancel due to unforeseen circumstances (e.g., health issues, family emergencies), they should notify support immediately to avoid penalties.',
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
          description:
              'If a service is canceled by either party due to unforeseen circumstances, both the customer and the service provider should report the issue through the App to avoid penalties.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App reserves the right to modify cancellation policies and will notify users of significant changes.',
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
