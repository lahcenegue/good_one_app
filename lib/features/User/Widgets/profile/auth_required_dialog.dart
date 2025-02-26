import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../Core/Navigation/app_routes.dart';
import '../../../../Core/Navigation/navigation_service.dart';
import '../../../../Core/Utils/storage_keys.dart';
import '../../../../Core/infrastructure/storage/storage_manager.dart';
import '../../../../Providers/user_state_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthRequiredDialog extends StatelessWidget {
  const AuthRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Consumer<UserStateProvider>(builder: (context, userManager, _) {
        return Container(
          width: context.screenWidth * 0.85,
          constraints: BoxConstraints(
            maxWidth: context.getWidth(400),
            minWidth: context.getWidth(280),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              context.getWidth(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: context.getAdaptiveSize(60),
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: context.getWidth(20)),
                Text(
                  AppLocalizations.of(context)!.loginRequired,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getWidth(10)),
                Text(
                  AppLocalizations.of(context)!.loginToContinue,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text(context),
                ),
                SizedBox(height: context.getWidth(20)),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: context.getWidth(100),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.back,
                            style: AppTextStyles.textButton(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: context.getWidth(120),
                        child: PrimaryButton(
                          text: AppLocalizations.of(context)!.login,
                          onPressed: () {
                            if (StorageManager.getString(
                                    StorageKeys.accountTypeKey) ==
                                null) {
                              NavigationService.navigateToAndReplace(
                                  AppRoutes.accountSelection);
                            } else {
                              NavigationService.navigateToAndReplace(
                                  AppRoutes.login);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
