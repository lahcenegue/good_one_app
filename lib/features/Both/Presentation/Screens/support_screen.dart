import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.support,
          style: AppTextStyles.appBarTitle(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(20),
          vertical: context.getHeight(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.supportHeader,
              style: AppTextStyles.title(context),
            ),
            SizedBox(height: context.getHeight(20)),
            _buildSupportOption(
              context,
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.emailSupport,
              subtitle: AppLocalizations.of(context)!.emailSupportDescription,
              onTap: () => _sendSupportEmail(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons.chat_outlined,
              title: AppLocalizations.of(context)!.chatSupport,
              subtitle: AppLocalizations.of(context)!.chatSupportDescription,
              onTap: () => _startSupportChat(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context)!.whatsappSupport,
              subtitle:
                  AppLocalizations.of(context)!.whatsappSupportDescription,
              onTap: () => _contactViaWhatsApp(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons
                  .description_outlined, // Appropriate icon for Terms and Conditions
              title: AppLocalizations.of(context)!.termsAndConditions,
              subtitle:
                  AppLocalizations.of(context)!.termsAndConditionsDescription,
              onTap: () => _viewTermsAndConditions(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons.policy_outlined,
              title: AppLocalizations.of(context)!.cancellationPolicy,
              subtitle:
                  AppLocalizations.of(context)!.cancellationPolicyDescription,
              onTap: () => _viewCancellationPolicy(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons.privacy_tip_outlined,
              title: AppLocalizations.of(context)!.privacyPolicy,
              subtitle: AppLocalizations.of(context)!.privacyPolicyDescription,
              onTap: () => _viewPrivacyPolicy(context),
            ),
            _buildSupportOption(
              context,
              icon: Icons.delete_forever_outlined,
              title: AppLocalizations.of(context)!.deleteAccount,
              subtitle: AppLocalizations.of(context)!.deleteAccountDescription,
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.getHeight(16)),
        padding: EdgeInsets.all(context.getWidth(16)),
        decoration: BoxDecoration(
          color: AppColors.dimGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.getWidth(30),
              color: AppColors.primaryColor,
            ),
            SizedBox(width: context.getWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subTitle(context),
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Text(
                    subtitle,
                    style: AppTextStyles.text(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: context.getWidth(20),
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // Function to send an email to support
  void _sendSupportEmail(BuildContext context) async {
    const String supportEmail = AppConfig.supportEmail;
    String subject = AppLocalizations.of(context)!.supportRequestfromApp;
    String body = AppLocalizations.of(context)!.iNeedAssistance;

    // Gmail URL scheme
    final Uri gmailUri = Uri.parse(
      'googlegmail://co?to=$supportEmail&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    // mailto fallback
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      // Try Gmail first
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
      } else {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          await FlutterClipboard.copy(supportEmail);
          if (context.mounted) {
            _showErrorSnackBar(
              context,
              '${AppLocalizations.of(context)!.emailCopied}: $supportEmail',
            );
          }
        }
      }
    } catch (e) {
      await FlutterClipboard.copy(supportEmail);
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          '${AppLocalizations.of(context)!.emailCopied}: $supportEmail',
        );
      }
    }
  }

  // Helper function to encode query parameters
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Function to start a support chat (placeholder)
  void _startSupportChat(BuildContext context) {
    _showErrorSnackBar(context, 'Chat support is not yet implemented'); //TODO
  }

  // Function to contact support via WhatsApp
  void _contactViaWhatsApp(BuildContext context) async {
    final String phoneNumber = AppConfig.whatsAppNumber;
    final String message = 'Hello, I need support with my account.';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
              context, AppLocalizations.of(context)!.unableOpenWhatsApp);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
            context, AppLocalizations.of(context)!.errorOpeningWhatsApp);
      }
    }
  }

  // Function to view cancellation policy (placeholder)
  void _viewCancellationPolicy(BuildContext context) async {
    await NavigationService.navigateTo(AppRoutes.cancellationPolicy);
  }

  // Function to view terms and conditions
  void _viewTermsAndConditions(BuildContext context) async {
    await NavigationService.navigateTo(AppRoutes.termsAndConditions);
  }

  // Function to view privacy policy
  void _viewPrivacyPolicy(BuildContext context) async {
    await NavigationService.navigateTo(AppRoutes.privacyPolicy);
  }

  // Function to delete account
  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.deleteAccount,
            style: AppTextStyles.subTitle(context),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteAccountConfirmation,
            style: AppTextStyles.text(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: AppTextStyles.textButton(context)
                    .copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // final userManager =
                //     Provider.of<UserManagerProvider>(context, listen: false);
                // try {
                //   // Implement account deletion logic
                //   await userManager
                //       .clearData(); // Assuming this clears user data
                //   _showSuccessSnackBar(context, 'Account deleted successfully');
                //   // Navigate to login or onboarding screen
                //   // Navigator.pushReplacementNamed(context, AppRoutes.login);
                // } catch (e) {
                //   _showErrorSnackBar(context, 'Error deleting account: $e');
                // }
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: AppTextStyles.textButton(context)
                    .copyWith(color: AppColors.oxblood),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.text(context).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.oxblood,
      ),
    );
  }

  // void _showSuccessSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //         style: AppTextStyles.text(context).copyWith(color: Colors.white),
  //       ),
  //       backgroundColor: AppColors.primaryColor,
  //     ),
  //   );
  // }
}
