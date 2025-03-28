import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Localization/app_localizations.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Setup/Presentation/Widgets/language_option_tile.dart';
import 'package:good_one_app/Providers/Both/app_settings_provider.dart';

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
                    _buildHeader(context),
                    _buildLanguageOptions(context, appSettings),
                    _buildNavigationButton(context, appSettings),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
      ],
    );
  }

  Widget _buildLanguageOptions(
    BuildContext context,
    AppSettingsProvider appSettings,
  ) {
    return Column(
      children: [
        ...AppLocalization.supportedLanguages.map(
          (language) => LanguageOptionTile(
            option: language,
            isSelected: appSettings.appLocale.languageCode == language.code,
            onTap: () async {
              await appSettings.setLanguage(Locale(language.code));
            },
          ),
        ),
        SizedBox(height: context.getHeight(32)),
      ],
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    AppSettingsProvider appSettings,
  ) {
    return Column(
      children: [
        PrimaryButton(
          text: AppLocalizations.of(context)!.next,
          onPressed: () async {
            if (context.mounted) {
              await appSettings.handleLanguageSelectionNavigation();
            }
          },
        ),
        SizedBox(height: context.getHeight(50)),
      ],
    );
  }
}
