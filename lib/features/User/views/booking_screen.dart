import 'package:flutter/material.dart';
import 'package:good_one_app/Providers/user_manager_provider.dart';
import 'package:provider/provider.dart';

import '../../../Core/Navigation/app_routes.dart';
import '../../../Core/Navigation/navigation_service.dart';
import '../../../Core/presentation/Theme/app_text_styles.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../Core/presentation/Widgets/Buttons/primary_button.dart';
import '../../../Core/presentation/resources/app_colors.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.booking,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: userManager.token == null
              ? _buildAuthRequiredState(context, userManager)
              : Center(
                  child: Text('Coming Soon'),
                ),
        );
      },
    );
  }

  Widget _buildAuthRequiredState(
    BuildContext context,
    UserManagerProvider userManager,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.loginRequired,
              style: AppTextStyles.title(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.loginRequired,
              style: AppTextStyles.text(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: AppLocalizations.of(context)!.signIn,
              onPressed: () {
                NavigationService.navigateTo(AppRoutes.accountSelection);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                NavigationService.navigateTo(AppRoutes.accountSelection);
              },
              child: Text(
                AppLocalizations.of(context)!.createAccount,
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
