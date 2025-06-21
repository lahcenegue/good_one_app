import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeString =
        DateFormat('h:mm a').format(notification.createdAt.toLocal());

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.getAdaptiveSize(8)),
      child: ListTile(
        leading: UserAvatar(
          picture: notification.picture,
          size: context.getWidth(50),
          backgroundColor: Colors.white,
        ),
        title: Text(
          notification.userName,
          style: AppTextStyles.title2(context),
        ),
        subtitle: Text(
          notification.action,
          style: AppTextStyles.text(context),
        ),
        trailing: Text(
          timeString,
          style: AppTextStyles.text(context).copyWith(fontSize: 12),
        ),
      ),
    );
  }
}
