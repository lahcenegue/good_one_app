import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    _buildDataCollectionSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildDataUsageSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildDataSharingSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildUserRightsSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildDataProtectionSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildPolicyChangesSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildContactSection(context),
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
        AppLocalizations.of(context)!.privacyPolicy,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildDataCollectionSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.dataWeCollect,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.personalInformation,
          description:
              AppLocalizations.of(context)!.personalInformationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.locationInformation,
          description:
              AppLocalizations.of(context)!.locationInformationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.deviceInformation,
          description:
              AppLocalizations.of(context)!.deviceInformationDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.usageData,
          description: AppLocalizations.of(context)!.usageDataDescription,
        ),
      ],
    );
  }

  Widget _buildDataUsageSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.howWeUseData,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.serviceImprovement,
          description:
              AppLocalizations.of(context)!.serviceImprovementDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.notificationsUsage,
          description:
              AppLocalizations.of(context)!.notificationsUsageDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.communicationUsage,
          description:
              AppLocalizations.of(context)!.communicationUsageDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.legalCompliance,
          description: AppLocalizations.of(context)!.legalComplianceDescription,
        ),
      ],
    );
  }

  Widget _buildDataSharingSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.sharingData,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.serviceProviders,
          description:
              AppLocalizations.of(context)!.serviceProvidersDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.legalComplianceSharing,
          description:
              AppLocalizations.of(context)!.legalComplianceSharingDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.advertisingPartners,
          description:
              AppLocalizations.of(context)!.advertisingPartnersDescription,
        ),
      ],
    );
  }

  Widget _buildUserRightsSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.userRights,
      children: [
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.modifyingData,
          description: AppLocalizations.of(context)!.modifyingDataDescription,
        ),
        _buildPolicyItem(
          context,
          title: AppLocalizations.of(context)!.requestingDeletion,
          description:
              AppLocalizations.of(context)!.requestingDeletionDescription,
        ),
      ],
    );
  }

  Widget _buildDataProtectionSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.dataProtection,
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.dataProtectionDescription,
        ),
      ],
    );
  }

  Widget _buildPolicyChangesSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.changesToPolicy,
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.policyChangesDescription,
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.contactUs,
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.contactUsDescription,
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
