import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class AuthRequiredDialog extends StatelessWidget {
  const AuthRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
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
                AppLocalizations.of(context)!.loginToContinue,
                style: AppTextStyles.title2(context),
                textAlign: TextAlign.center,
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
                      width: context.getWidth(140),
                      child: PrimaryButton(
                        text: AppLocalizations.of(context)!.login,
                        onPressed: () async {
                          Navigator.pop(context);
                          NavigationService.navigateTo(AppRoutes.login);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
