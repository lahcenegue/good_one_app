import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import '../../../../Core/presentation/resources/app_colors.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: context.getWidth(9),
      width: context.getWidth(9),
      //width: isActive ? context.getWidth(24) : context.getWidth(8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColor : const Color(0xFFced3d8),
        borderRadius: BorderRadius.circular(context.getWidth(4)),
      ),
    );
  }
}
