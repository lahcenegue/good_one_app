import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          title: 'Personal Information',
          description:
              'We collect information such as your name, email address, and phone number when you use our app.',
        ),
        _buildPolicyItem(
          context,
          title: 'Location Information',
          description:
              'If location services are enabled, we collect geographic data to enhance your user experience.',
        ),
        _buildPolicyItem(
          context,
          title: 'Device Information',
          description:
              'We collect details like device type, operating system, and IP address.',
        ),
        _buildPolicyItem(
          context,
          title: 'Usage Data',
          description:
              'We gather data on how you interact with the app to improve our services.',
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
          title: 'Service Improvement',
          description:
              'We use your data to enhance and personalize app services.',
        ),
        _buildPolicyItem(
          context,
          title: 'Notifications',
          description:
              'We send notifications and service-related alerts to keep you informed.',
        ),
        _buildPolicyItem(
          context,
          title: 'Communication',
          description:
              'We use your data to process requests and communicate with you.',
        ),
        _buildPolicyItem(
          context,
          title: 'Legal Compliance',
          description:
              'We ensure compliance with legal and regulatory requirements.',
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
          title: 'Service Providers',
          description:
              'We may share your data with payment processors, analytics providers, and technical support companies.',
        ),
        _buildPolicyItem(
          context,
          title: 'Legal Compliance',
          description:
              'We may share data if required by law or to protect our rights.',
        ),
        _buildPolicyItem(
          context,
          title: 'Advertising Partners',
          description:
              'With your consent, we may share some data for marketing purposes.',
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
          title: 'Modifying Data',
          description:
              'You may update or correct your personal data through the app.',
        ),
        _buildPolicyItem(
          context,
          title: 'Requesting Deletion',
          description:
              'You may request the deletion of your data, unless we are legally required to retain it.',
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
          description:
              'We implement security measures to protect your data from unauthorized access, alteration, or loss. However, absolute security over the internet cannot be guaranteed.',
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
          description:
              'We may update this policy from time to time. You will be notified of significant changes through in-app notifications or via email.',
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
          description:
              'If you have any questions about this Privacy Policy, you can contact us via email or phone. By using the app, you agree to the terms of this Privacy Policy.',
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
