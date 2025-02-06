import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import '../../../Core/presentation/Theme/app_text_styles.dart';

class OnBoardContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

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
