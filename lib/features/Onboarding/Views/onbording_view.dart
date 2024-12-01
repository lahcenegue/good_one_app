import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Themes/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Core/Constants/app_assets.dart';
import '../../../Core/Widgets/custom_buttons.dart';
import '../Models/onboard_model.dart';
import '../widgets/dot_indicator.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../Providers/app_settings_provider.dart';
import '../widgets/onboard_content.dart';

class OnBordingView extends StatelessWidget {
  const OnBordingView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OnboardModel> onboardingData = [
      OnboardModel(
        image: AppAssets.onBordingImage1,
        title: AppLocalizations.of(context)!.onboardingTitle1,
        description: AppLocalizations.of(context)!.onboardingDesc1,
      ),
      OnboardModel(
        image: AppAssets.onBordingImage2,
        title: AppLocalizations.of(context)!.onboardingTitle2,
        description: AppLocalizations.of(context)!.onboardingDesc2,
      ),
    ];

    return Consumer<AppSettingsProvider>(
      builder: (context, appsettings, _) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(20),
              vertical: context.getHeight(10),
            ),
            child: Column(
              children: [
                _buildTopRow(context, appsettings, onboardingData.length),
                Expanded(
                  child: _buildPageView(context, appsettings, onboardingData),
                ),
                _buildBottomRow(context, appsettings, onboardingData),
                SizedBox(height: context.getWidth(30)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(
    BuildContext context,
    AppSettingsProvider appsettings,
    int length,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: context.getHeight(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
              height: context.getHeight(50),
              child: appsettings.pageIndex != length - 1
                  ? TextButton(
                      onPressed: () => appsettings.completeOnboarding(),
                      child: Text(
                        AppLocalizations.of(context)!.skip,
                        style: AppTextStyles.subTitle(context),
                      ),
                    )
                  : null)
        ],
      ),
    );
  }

  Widget _buildPageView(
    BuildContext context,
    AppSettingsProvider appsettings,
    List<OnboardModel> data,
  ) {
    return PageView.builder(
      controller: appsettings.pageController,
      itemCount: data.length,
      onPageChanged: (index) => appsettings.setPageIndex(index),
      itemBuilder: (context, index) => OnBoardContent(
        image: data[index].image,
        title: data[index].title,
        description: data[index].description,
      ),
    );
  }

  Widget _buildBottomRow(
    BuildContext context,
    AppSettingsProvider appsettings,
    List<OnboardModel> data,
  ) {
    return Column(
      children: [
        _buildDotsIndicator(context, appsettings, data.length),
        SizedBox(height: context.getHeight(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallSecondaryButton(
              text: AppLocalizations.of(context)!.back,
              onPressed: () {
                appsettings.pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
            SmallPrimaryButton(
              text: AppLocalizations.of(context)!.next,
              onPressed: () async {
                if (appsettings.pageIndex == data.length - 1) {
                  await appsettings.completeOnboarding();
                } else {
                  appsettings.pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotsIndicator(
    BuildContext context,
    AppSettingsProvider appsettings,
    int length,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Padding(
          padding: EdgeInsets.only(right: context.getWidth(10)),
          child: DotIndicator(isActive: index == appsettings.pageIndex),
        ),
      ),
    );
  }
}
