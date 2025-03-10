import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeString = notification.createdAt != null
        ? DateFormat('h:mm a').format(notification.createdAt!.toLocal())
        : 'Unknown time';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: notification.picture != null
              ? NetworkImage(notification.picture!)
              : const AssetImage('assets/images/default_profile.png')
                  as ImageProvider,
          radius: 20,
        ),
        title: Text(
          notification.userName!,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          notification.action!,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          timeString,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
