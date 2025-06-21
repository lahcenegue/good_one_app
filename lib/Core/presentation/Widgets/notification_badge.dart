import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

/// A reusable notification badge widget that displays the unread count
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0 || showZero)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal:
                    count > 99 ? context.getWidth(6) : context.getWidth(4),
                vertical: context.getHeight(2),
              ),
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius:
                    BorderRadius.circular(context.getAdaptiveSize(10)),
                border: Border.all(
                  color: AppColors.whiteText,
                  width: 1.5,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: context.getWidth(18),
                minHeight: context.getHeight(18),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: AppTextStyles.text(context).copyWith(
                  color: AppColors.whiteText,
                  fontSize: context.getAdaptiveSize(10),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
