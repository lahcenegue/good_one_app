import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_assets.dart';
import '../../../Core/Themes/app_text_styles.dart';
import '../../../Core/Widgets/custom_buttons.dart';
import '../../../Providers/app_settings_provider.dart';
import '../widgets/language_option_tile.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, appSettings, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.languageSelectionTitle,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.getAdaptiveSize(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.getHeight(20)),
                    Center(
                      child: Image.asset(
                        AppAssets.languageIllustration,
                        height: 150,
                      ),
                    ),
                    SizedBox(height: context.getHeight(24)),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcomeMessage,
                          style: AppTextStyles.title(context),
                        ),
                        Image.asset(
                          AppAssets.appNameImage,
                          height: context.getHeight(32),
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: context.getHeight(4)),
                    Text(
                      AppLocalizations.of(context)!.chooseLanguagePrompt,
                      style: AppTextStyles.subTitle(context),
                    ),
                    SizedBox(height: context.getHeight(32)),
                    ...appSettings.supportedLanguages.map(
                      (language) => LanguageOptionTile(
                        option: language,
                        isSelected:
                            appSettings.appLocale.languageCode == language.code,
                        onTap: () =>
                            appSettings.setLanguage(Locale(language.code)),
                      ),
                    ),
                    SizedBox(height: context.getHeight(32)),
                    PrimaryButton(
                      text: AppLocalizations.of(context)!.nextButton,
                      onPressed: () async {
                        await appSettings.setLanguage(appSettings.appLocale);
                      },
                    ),
                    SizedBox(height: context.getHeight(50)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
