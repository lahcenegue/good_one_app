import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Themes/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../Core/Constants/app_assets.dart';
import '../../Core/Constants/storage_keys.dart';
import '../../Core/Utils/navigation_service.dart';
import '../../Core/Widgets/custom_buttons.dart';
import '../../Core/Widgets/dot_indicator.dart';
import '../../Logic/Providers/app_settings_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnBordingView extends StatelessWidget {
  const OnBordingView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Onboard> demoData = [
      Onboard(
        image: AppAssets.onBordingImage1,
        title: 'home services with a\nprofessional touch!',
        description:
            'Discover quick and easy solutions for all your home needs, from plumbing and electrical to cleaning and renovation. Let us make your home more comfortable.',
      ),
      Onboard(
        image: AppAssets.onBordingImage2,
        title: "We're here to make your life\neasier!",
        description:
            'We offer a comprehensive range of high-quality, reliable home services, so you can enjoy your time at home without any worries.',
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
                _buildTopRow(context, appsettings, demoData.length),
                Expanded(
                  child: _buildPageView(context, appsettings, demoData),
                ),
                _buildBottomRow(context, appsettings, demoData),
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
                      onPressed: () {
                        appsettings.prefs!
                            .setString(StorageKeys.onbordingKey, 'watched');
                        NavigationService.navigateTo(AppRoutes.userHome);
                      },
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
    List<Onboard> data,
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

  Widget _buildDotsIndicator(
      BuildContext context, AppSettingsProvider appsettings, int length) {
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

  Widget _buildBottomRow(BuildContext context, AppSettingsProvider appsettings,
      List<Onboard> data) {
    return Column(
      children: [
        _buildDotsIndicator(context, appsettings, data.length),
        SizedBox(height: context.getHeight(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallSecondaryButton(
              text: 'Back',
              onPressed: () {
                appsettings.pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
            SmallPrimaryButton(
              text: 'Next',
              onPressed: () {
                if (appsettings.pageIndex == data.length - 1) {
                  appsettings.prefs!
                      .setString(StorageKeys.onbordingKey, 'watched');
                  NavigationService.navigateTo(AppRoutes.userHome);
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
}

class Onboard {
  final String image, title, description;
  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnBoardContent extends StatelessWidget {
  final String image, title, description;

  const OnBoardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          image,
          width: context.screenWidth,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.title(context),
        ),
        SizedBox(height: context.getHeight(16)),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTextStyles.text(context),
        ),
        const Spacer(),
      ],
    );
  }
}
