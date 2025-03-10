import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/user_manager_provider.dart';
import '../Widgets/notification_list_item.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isNotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.notificationError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.notificationError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: _buildNotificationList(provider.notifications, context),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
      List<NotificationModel> notifications, BuildContext context) {
    if (notifications.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final todayNotifications =
        notifications.where((n) => isToday(n.createdAt)).toList();
    final earlierNotifications =
        notifications.where((n) => !isToday(n.createdAt)).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          const Text('Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...todayNotifications
              .map((n) => NotificationListItem(notification: n))
              .toList(),
        ],
        if (earlierNotifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Earlier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...earlierNotifications
              .map((n) => NotificationListItem(notification: n))
              .toList(),
        ],
      ],
    );
  }

  bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
