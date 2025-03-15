import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Localization/app_localizations.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Providers/app_settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    final appSettings =
        Provider.of<AppSettingsProvider>(context, listen: false);
    _selectedLanguageCode = appSettings.appLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, appSettings, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.language,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getAdaptiveSize(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: context.getHeight(20)),
                          _buildLanguageOptions(context, appSettings),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSaveButton(context, appSettings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOptions(
    BuildContext context,
    AppSettingsProvider appSettings,
  ) {
    return Column(
      children: AppLocalization.supportedLanguages.map((language) {
        final isSelected = _selectedLanguageCode == language.code;

        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedLanguageCode = language.code;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getAdaptiveSize(16),
                  vertical: context.getAdaptiveSize(12),
                ),
                decoration: BoxDecoration(
                  color: AppColors.dimGray,
                  borderRadius:
                      BorderRadius.circular(context.getAdaptiveSize(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language.name,
                      style: AppTextStyles.subTitle(context),
                    ),
                    Container(
                      width: context.getAdaptiveSize(20),
                      height: context.getAdaptiveSize(20),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primaryColor : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.dimGray,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: context.getAdaptiveSize(18),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.getHeight(12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppSettingsProvider appSettings,
  ) {
    final hasChanges =
        _selectedLanguageCode != appSettings.appLocale.languageCode;
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(20)),
      child: PrimaryButton(
        text: AppLocalizations.of(context)!.save,
        onPressed: hasChanges
            ? () async {
                if (_selectedLanguageCode != null) {
                  await appSettings.setLanguage(Locale(_selectedLanguageCode!));
                }
              }
            : () {},
      ),
    );
  }
}
