import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Features/Notifications/Models/notification_model.dart';

import 'package:intl/intl.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeString = notification.createdAt != null
        ? DateFormat('h:mm a').format(notification.createdAt!.toLocal())
        : 'Unknown time'; //TODO

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
          notification.userName!,
          style: AppTextStyles.title2(context),
        ),
        subtitle: Text(
          notification.action!,
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
