import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
                    _buildIntroductionSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildDefinitionsSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildUserEligibilitySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildAccountRegistrationSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildCommunicationPrivacySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildPaymentsTransactionsSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildServiceProviderRequirementsSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildAdvertisingPolicySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildProhibitedActivitiesSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildDisputeResolutionSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildCancellationPolicySection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildTerminationSuspensionSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildLiabilityDisclaimersSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildChangesToTermsSection(context),
                    SizedBox(height: context.getHeight(24)),
                    _buildContactInformationSection(context),
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
        AppLocalizations.of(context)!.termsAndConditions,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildIntroductionSection(BuildContext context) {
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.introduction,
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Last Updated: 15 April 2025\n\nWelcome to Good One. These Terms and Conditions govern your use of our mobile application and services. By using our app, you agree to comply with these terms. If you do not agree, please do not use the app.',
        ),
      ],
    );
  }

  Widget _buildDefinitionsSection(BuildContext context) {
    return _buildSection(
      context,
      title: '1. ${AppLocalizations.of(context)!.definitions}',
      children: [
        _buildPolicyItem(
          context,
          title: '"App"',
          description:
              'Refers to Good One app, the mobile application that connects customers with service providers.',
        ),
        _buildPolicyItem(
          context,
          title: '"User"',
          description:
              'Refers to anyone who accesses and uses the App, including both customers and service providers.',
        ),
        _buildPolicyItem(
          context,
          title: '"Customer"',
          description:
              'Refers to individuals seeking services through the App.',
        ),
        _buildPolicyItem(
          context,
          title: '"Service Provider"',
          description:
              'Refers to individuals offering their services through the App.',
        ),
        _buildPolicyItem(
          context,
          title: '"Platform"',
          description: 'Refers to the App and its associated services.',
        ),
      ],
    );
  }

  Widget _buildUserEligibilitySection(BuildContext context) {
    return _buildSection(
      context,
      title: '2. ${AppLocalizations.of(context)!.userEligibility}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: 'To use the App, you must:',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Provide accurate and truthful information during registration.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: 'Comply with all applicable laws and regulations.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Be at least 18 years old to register as a service provider. Minors under 18 are required to provide parents’ consent to confirm that the service will be under the parent’s responsibility and supervision.',
        ),
        _buildSubSection(
          context,
          title: 'Minimum Working Age by Province/Territory',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Most provinces set 14 as the minimum age for general work with restrictions.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Some provinces allow 12-year-olds to work in specific, non-hazardous jobs with parental consent.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Restrictions on Work for Minors',
          children: [
            _buildPolicyItem(
              context,
              title: 'No hazardous work',
              description:
                  'Minors cannot perform dangerous jobs (e.g., construction, heavy machinery, electrical work).',
            ),
            _buildPolicyItem(
              context,
              title: 'Parental consent',
              description:
                  'Many provinces require parental permission for those under 16.',
            ),
            _buildPolicyItem(
              context,
              title: 'Limited work hours',
              description:
                  'Kids under 18 usually can\'t work late hours or during school time.',
            ),
            _buildPolicyItem(
              context,
              title: 'Business licensing issues',
              description:
                  'Some provinces may restrict minors from operating as independent contractors.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Specific Cases for Gig Work (Your App\'s Context)',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'The App provides services often involve physical labor, handyman work, and home services.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'These types of jobs typically require workers to be 18+ because they involve safety risks, contracts, and potential liability issues.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Conclusion: Should Minors Be Allowed on the App?',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'It’s best to require service providers to be at least 18.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'If younger users (e.g., babysitting, tutoring) are allowed in the future, parental consent and provincial legal approval may be required. (Contact customer support to send you the consent to be signed.)',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountRegistrationSection(BuildContext context) {
    return _buildSection(
      context,
      title: '3. ${AppLocalizations.of(context)!.accountRegistrationAndUse}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: 'Users must create an account to access the services.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'You are responsible for maintaining the confidentiality of your login credentials.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'You must not share, transfer, or sell your account to another person.',
        ),
      ],
    );
  }

  Widget _buildCommunicationPrivacySection(BuildContext context) {
    return _buildSection(
      context,
      title: '4. ${AppLocalizations.of(context)!.communicationAndPrivacy}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The in-app chat is the only permitted method of communication between customers and service providers.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Users are strictly prohibited from sharing personal contact information (e.g., phone numbers, emails) through the chat.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Violation of this rule may result in account suspension or termination.',
        ),
      ],
    );
  }

  Widget _buildPaymentsTransactionsSection(BuildContext context) {
    return _buildSection(
      context,
      title: '5. ${AppLocalizations.of(context)!.paymentsAndTransactions}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: 'All payments must be processed through the App.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'No payments outside the App are allowed. Any attempt to process payments outside the platform may result in permanent account suspension.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App may charge service fees or transaction fees, which will be disclosed before payment.',
        ),
      ],
    );
  }

  Widget _buildServiceProviderRequirementsSection(BuildContext context) {
    return _buildSection(
      context,
      title: '6. ${AppLocalizations.of(context)!.serviceProviderRequirements}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Service providers can upload certifications to enhance their profile credibility, but this is optional.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Service providers may also complete a security check through the App, which will further increase trust.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App does not guarantee job assignments or earnings for service providers.',
        ),
      ],
    );
  }

  Widget _buildAdvertisingPolicySection(BuildContext context) {
    return _buildSection(
      context,
      title: '7. ${AppLocalizations.of(context)!.advertisingPolicy}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App allows advertisements from companies and individuals, including service providers who wish to promote their services. By submitting an advertisement, you agree to the following terms:',
        ),
        _buildSubSection(
          context,
          title: 'Eligibility to Advertise',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Advertisers must comply with all applicable laws and regulations.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Service providers may advertise their services, but advertisements must not mislead users or contain false claims.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Companies must ensure that their ads are relevant to the platform’s audience.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Ad Content Guidelines',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Ads must be truthful, accurate, and not misleading.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Ads must not promote illegal activities, violence, discrimination, or explicit content.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Ads must not include personal contact details (e.g., phone numbers, email addresses) to ensure transactions remain within the App.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'The App reserves the right to review and reject any advertisement that does not align with these guidelines.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Ad Placement and Fees',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Advertisers may choose from different ad placement options within the App.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Advertising fees vary based on placement, duration, and visibility.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Payment for advertisements must be processed through the App.',
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: 'Ad Removal and Violations',
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'The App reserves the right to remove ads that violate these policies without notice or refund.',
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  'Repeated violations may result in a ban from advertising on the platform.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProhibitedActivitiesSection(BuildContext context) {
    return _buildSection(
      context,
      title: '8. ${AppLocalizations.of(context)!.prohibitedActivities}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description: 'Users must not:',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: 'Misrepresent themselves or their services.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: 'Engage in fraudulent activities.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: 'Violate any local, state, or national laws.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: 'Use the App for any illegal or unethical purposes.',
        ),
      ],
    );
  }

  Widget _buildDisputeResolutionSection(BuildContext context) {
    return _buildSection(
      context,
      title: '9. ${AppLocalizations.of(context)!.disputeResolution}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Any disputes between users must be handled through the App’s customer support team.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App is not responsible for any disagreements between customers and service providers but will assist in resolving disputes where possible.',
        ),
      ],
    );
  }

  Widget _buildCancellationPolicySection(BuildContext context) {
    return _buildSection(
      context,
      title: '10. ${AppLocalizations.of(context)!.cancellationPolicy}',
      children: [
        _buildSubSection(
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
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!
              .cancellationPolicyForServiceProviders,
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
        ),
        _buildSubSection(
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
        ),
      ],
    );
  }

  Widget _buildTerminationSuspensionSection(BuildContext context) {
    return _buildSection(
      context,
      title: '11. ${AppLocalizations.of(context)!.terminationAndSuspension}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App reserves the right to suspend or terminate any account that violates these terms.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Users may deactivate their accounts at any time through the App settings.',
        ),
      ],
    );
  }

  Widget _buildLiabilityDisclaimersSection(BuildContext context) {
    return _buildSection(
      context,
      title: '12. ${AppLocalizations.of(context)!.liabilityAndDisclaimers}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App acts as a platform to connect customers with service providers but does not guarantee service quality or outcomes.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App is not liable for any damages, losses, or disputes arising from user interactions.',
        ),
      ],
    );
  }

  Widget _buildChangesToTermsSection(BuildContext context) {
    return _buildSection(
      context,
      title: '13. ${AppLocalizations.of(context)!.changesToTerms}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'The App reserves the right to update these Terms and Conditions at any time. Users will be notified of significant changes.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'Continued use of the App after changes are posted constitutes acceptance of the new terms.',
        ),
      ],
    );
  }

  Widget _buildContactInformationSection(BuildContext context) {
    return _buildSection(
      context,
      title: '14. ${AppLocalizations.of(context)!.contactInformation}',
      children: [
        _buildPolicyItem(
          context,
          title: '',
          description:
              'For questions or concerns regarding these Terms and Conditions, please contact our support team within the App.',
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              'By using Good One, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.',
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

  Widget _buildSubSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.only(
          left: context.getWidth(16), top: context.getHeight(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subTitle(context).copyWith(
              color: AppColors.oxblood,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.getHeight(8)),
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
