import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/core/presentation/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

import '../../../Core/presentation/Widgets/Buttons/primary_button.dart';
import '../../../Core/presentation/resources/app_colors.dart';
import '../../../Providers/user_manager_provider.dart';
import '../Widgets/notification_list_item.dart';
import '../models/notification_model.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification',
          style: AppTextStyles.appBarTitle(context),
        ), //TODO
      ),
      body: Consumer<UserManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isNotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (provider.notificationError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.notificationError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text(context).copyWith(
                      color: AppColors.oxblood,
                    ),
                  ),
                  SizedBox(height: context.getHeight(16)),
                  SmallPrimaryButton(
                    text: AppLocalizations.of(context)!.retry,
                    onPressed: () => provider.fetchNotifications(),
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
    List<NotificationModel> notifications,
    BuildContext context,
  ) {
    if (notifications.isEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: context.getAdaptiveSize(64),
                  color: AppColors.dimGray,
                ),
                SizedBox(height: context.getHeight(16)),
                Text(
                  'No notifications available', //TODO
                  style: AppTextStyles.title(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Pull down to refresh', //TODO
                  style: AppTextStyles.title(context),
                  textAlign: TextAlign.center,
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
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          Text(
            'Today', //TODO
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(16)),
          ...todayNotifications
              .map((n) => NotificationListItem(notification: n)),
        ],
        if (earlierNotifications.isNotEmpty) ...[
          SizedBox(height: context.getHeight(16)),
          Text(
            'Earlier', //TODO
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(8)),
          ...earlierNotifications
              .map((n) => NotificationListItem(notification: n)),
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
