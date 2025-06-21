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
          description: AppLocalizations.of(context)!.termsIntroduction,
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
          description: AppLocalizations.of(context)!.appDefinition,
        ),
        _buildPolicyItem(
          context,
          title: '"User"',
          description: AppLocalizations.of(context)!.userDefinition,
        ),
        _buildPolicyItem(
          context,
          title: '"Customer"',
          description: AppLocalizations.of(context)!.customerDefinition,
        ),
        _buildPolicyItem(
          context,
          title: '"Service Provider"',
          description: AppLocalizations.of(context)!.serviceProviderDefinition,
        ),
        _buildPolicyItem(
          context,
          title: '"Platform"',
          description: AppLocalizations.of(context)!.platformDefinition,
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
          description: AppLocalizations.of(context)!.toUseTheApp,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.provideAccurateInfo,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.complyWithLaws,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.ageRequirement,
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.minimumWorkingAgeByProvince,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.mostProvincesSet14Minimum,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.someProvinces12YearOlds,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.restrictionsWorkMinors,
          children: [
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.noHazardousWork,
              description:
                  AppLocalizations.of(context)!.minorsCannotDangerousJobs,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.parentalConsent,
              description: AppLocalizations.of(context)!
                  .provincesRequireParentalPermission,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.limitedWorkHours,
              description: AppLocalizations.of(context)!.kidsNoLateHours,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.businessLicensingIssues,
              description:
                  AppLocalizations.of(context)!.provincesRestrictMinors,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.specificCasesGigWork,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.servicesInvolvePhysicalLabor,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.jobsRequire18Plus,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.conclusionMinorsAllowed,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.bestRequire18,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.youngerUsersParentalConsent,
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
          description: AppLocalizations.of(context)!.usersMustCreateAccount,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.responsibleForCredentials,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.notShareAccountInfo,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.unauthorizedAccess,
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
          description: AppLocalizations.of(context)!.communicationViaApp,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.noPersonalContactSharing,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.violationAccountSuspension,
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
          description: AppLocalizations.of(context)!.allPaymentsThroughApp,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.noPaymentsOutside,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.serviceFeeDisclosure,
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
          description: AppLocalizations.of(context)!.certificationsOptional,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.securityCheckAvailable,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.noJobGuarantee,
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
          description: AppLocalizations.of(context)!.advertisingPolicyIntro,
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.eligibilityToAdvertise,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.advertisersComplyLaws,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.serviceProviderAdsNotMislead,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.companiesEnsureRelevantAds,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.adContentGuidelines,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.adsTruthfulAccurate,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.adsNotPromoteIllegal,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.adsNoPersonalContact,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.appReviewRejectAds,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.adPlacementFees,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.advertisersChoosePlacement,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.advertisingFeesVary,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.adPaymentThroughApp,
            ),
          ],
        ),
        _buildSubSection(
          context,
          title: AppLocalizations.of(context)!.adRemovalViolations,
          children: [
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.appRemoveViolatingAds,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description: AppLocalizations.of(context)!.repeatedViolationsBan,
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
          description: AppLocalizations.of(context)!.usersMustNot,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.misrepresentServices,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.engageFraudulent,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.violateLocalLaws,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.useAppIllegalPurposes,
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
          description: AppLocalizations.of(context)!.disputesHandledBySupport,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              AppLocalizations.of(context)!.appNotResponsibleDisagreements,
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
              title: AppLocalizations.of(context)!.freeCancellationWindow,
              description:
                  AppLocalizations.of(context)!.customersFreeCancel48Hours,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.lateCancellations,
              description: AppLocalizations.of(context)!.lateCancellationFee,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.noShows,
              description: AppLocalizations.of(context)!.noShowFullCharge,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.refundPolicy,
              description:
                  AppLocalizations.of(context)!.refundEligibilityDepends,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.emergencyCancellations,
              description:
                  AppLocalizations.of(context)!.emergencyCancellationPolicy,
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
              title: AppLocalizations.of(context)!.advanceNotice,
              description: AppLocalizations.of(context)!.inform48HoursBefore,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.frequentCancellations,
              description:
                  AppLocalizations.of(context)!.repeatedCancellationsPenalties,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.customerCompensation,
              description:
                  AppLocalizations.of(context)!.providerCancelCompensation,
            ),
            _buildPolicyItem(
              context,
              title: AppLocalizations.of(context)!.unavoidableCancellations,
              description:
                  AppLocalizations.of(context)!.unforeseeableCircumstances,
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
              description: AppLocalizations.of(context)!
                  .reportUnforeseeableCircumstances,
            ),
            _buildPolicyItem(
              context,
              title: '',
              description:
                  AppLocalizations.of(context)!.appModifyCancellationPolicies,
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
              AppLocalizations.of(context)!.appSuspendTerminateViolations,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.usersDeactivateAccounts,
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
          description: AppLocalizations.of(context)!.appPlatformConnect,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              AppLocalizations.of(context)!.appNotLiableUserInteractions,
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
          description: AppLocalizations.of(context)!.appUpdateTermsAnytime,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description: AppLocalizations.of(context)!.continuedUseAcceptance,
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
          description: AppLocalizations.of(context)!.contactSupportForQuestions,
        ),
        _buildPolicyItem(
          context,
          title: '',
          description:
              AppLocalizations.of(context)!.acknowledgmentReadUnderstood,
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
