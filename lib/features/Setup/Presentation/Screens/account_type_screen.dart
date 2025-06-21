import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Features/Setup/Models/account_type.dart';
import 'package:good_one_app/Features/Setup/Presentation/Widgets/account_type_card.dart';
import 'package:good_one_app/Providers/Both/app_settings_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountTypeSelectionOverlay extends StatelessWidget {
  const AccountTypeSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, appSettings, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                width: context.getWidth(300),
              ),
              SizedBox(height: context.getHeight(50)),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: context.getAdaptiveSize(24)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(context.getAdaptiveSize(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.getAdaptiveSize(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeToOurApp,
                        style: AppTextStyles.title(context),
                      ),
                      SizedBox(height: context.getHeight(8)),
                      Text(
                        AppLocalizations.of(context)!
                            .accountTypeSelectionPrompt,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.text(context),
                      ),
                      SizedBox(height: context.getHeight(24)),
                      AccountTypeCard(
                        title: 'Client',
                        type: AccountType.customer,
                        isSelected: appSettings
                            .isAccountTypeSelected(AccountType.customer),
                        onSelect: () =>
                            appSettings.setAccountType(AccountType.customer),
                      ),
                      SizedBox(height: context.getHeight(12)),
                      AccountTypeCard(
                        title: 'Provider',
                        type: AccountType.worker,
                        isSelected: appSettings
                            .isAccountTypeSelected(AccountType.worker),
                        onSelect: () =>
                            appSettings.setAccountType(AccountType.worker),
                      ),
                      SizedBox(height: context.getHeight(12)),
                      PrimaryButton(
                        text: AppLocalizations.of(context)!.next,
                        onPressed: appSettings.canProceed
                            ? () {
                                NavigationService.navigateToAndReplace(
                                    AppRoutes.login);
                              }
                            : () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
