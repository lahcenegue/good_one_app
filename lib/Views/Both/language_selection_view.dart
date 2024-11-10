import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Constants/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../Core/Constants/app_assets.dart';
import '../../Core/Utils/navigation_service.dart';
import '../../Core/Themes/app_text_styles.dart';
import '../../Core/Widgets/custom_buttons.dart';
import '../../Logic/Providers/app_settings_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, provider, _) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    _buildLanguageOption(
                      context,
                      'Francais',
                      'Franche',
                      provider.appLocale.languageCode == 'fr',
                      () => _selectLanguage(context, provider, 'fr'),
                    ),
                    _buildLanguageOption(
                      context,
                      'العربية',
                      'Arabic',
                      provider.appLocale.languageCode == 'ar',
                      () => _selectLanguage(context, provider, 'ar'),
                    ),
                    _buildLanguageOption(
                      context,
                      'English',
                      'Englais',
                      provider.appLocale.languageCode == 'en',
                      () => _selectLanguage(context, provider, 'en'),
                    ),
                    _buildLanguageOption(
                      context,
                      'Afrikaans',
                      'Afikaans',
                      provider.appLocale.languageCode == 'af',
                      () => _selectLanguage(context, provider, 'af'),
                    ),
                    _buildLanguageOption(
                      context,
                      'Shqip',
                      'Albanais',
                      provider.appLocale.languageCode == 'sq',
                      () => _selectLanguage(context, provider, 'sq'),
                    ),
                    SizedBox(height: context.getHeight(32)),
                    PrimaryButton(
                      text: AppLocalizations.of(context)!.nextButton,
                      onPressed: () {
                        NavigationService.navigateTo(AppRoutes.onBording);
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

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveValue(
          small: 8,
          medium: 16,
          large: 24,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    AppSettingsProvider provider,
    String locale,
  ) async {
    await provider.changeLanguage(Locale(locale));
  }
}
