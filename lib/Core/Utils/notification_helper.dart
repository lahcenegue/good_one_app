import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

/// Enhanced notification helper with better badge management
/// and optimized performance for WorkerManagerProvider
class NotificationHelper {
  /// Builds a notification icon with a smart badge that shows the count
  /// Enhanced with better styling and performance optimization
  static Widget buildNotificationIconWithBadge({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onTap,
    Color? badgeColor,
    Color? textColor,
    double? badgeSize,
    bool showZeroBadge = false,
  }) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, child) {
        final count = workerManager.newNotificationCount;
        final hasNotifications = count > 0;

        return GestureDetector(
          onTap: () async {
            // Call the onTap callback first
            onTap();

            // Mark notifications as seen when tapping the notification icon
            if (hasNotifications) {
              // Small delay to ensure navigation completes first
              Future.delayed(const Duration(milliseconds: 100), () {
                workerManager.markAllNotificationsAsSeenNew();
              });
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              icon,
              if (hasNotifications || showZeroBadge)
                Positioned(
                  top: -6,
                  right: -6,
                  child: _buildBadge(
                    context: context,
                    count: count,
                    badgeColor: badgeColor,
                    textColor: textColor,
                    badgeSize: badgeSize,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a customizable notification badge
  static Widget _buildBadge({
    required BuildContext context,
    required int count,
    Color? badgeColor,
    Color? textColor,
    double? badgeSize,
  }) {
    final effectiveBadgeColor = badgeColor ?? AppColors.primaryColor;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveBadgeSize = badgeSize ?? context.getAdaptiveSize(20);

    // For counts > 99, show "99+"
    final displayText = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: effectiveBadgeSize,
        minHeight: effectiveBadgeSize,
      ),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: effectiveBadgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveBadgeColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: effectiveTextColor,
            fontSize: count > 9 ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Creates a notification badge for use in bottom navigation
  static Widget buildBottomNavBadge({
    required BuildContext context,
    required Widget child,
    bool showBadge = true,
  }) {
    if (!showBadge) return child;

    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        final count = workerManager.newNotificationCount;

        if (count == 0) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a notification count in app bar
  static Widget buildAppBarNotificationCount({
    required BuildContext context,
    TextStyle? textStyle,
  }) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, child) {
        final count = workerManager.newNotificationCount;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      },
    );
  }

  /// Triggers a notification count refresh
  /// Useful for pull-to-refresh or when app comes to foreground
  static Future<void> refreshNotificationCounts(BuildContext context) async {
    final workerManager = Provider.of<WorkerManagerProvider>(
      context,
      listen: false,
    );

    await workerManager.fetchNotificationCounts();
  }

  /// Sets up automatic notification count polling
  /// Call this in your main app or home screen
  static void startNotificationPolling(
    BuildContext context, {
    Duration interval = const Duration(minutes: 1),
  }) {
    final workerManager = Provider.of<WorkerManagerProvider>(
      context,
      listen: false,
    );

    // Only poll if user is authenticated
    if (workerManager.token != null) {
      Timer.periodic(interval, (timer) async {
        // Check if still authenticated and widget is still mounted
        if (workerManager.token != null && context.mounted) {
          await workerManager.fetchNotificationCounts();
        } else {
          timer.cancel(); // Stop polling if not authenticated
        }
      });
    }
  }

  /// Handles app lifecycle changes for notification management
  static void handleAppLifecycleChange(
    BuildContext context,
    AppLifecycleState state,
  ) {
    final workerManager = Provider.of<WorkerManagerProvider>(
      context,
      listen: false,
    );

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - refresh notifications
        if (workerManager.token != null) {
          workerManager.fetchNotificationCounts();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App went to background - no action needed
        break;
    }
  }

  /// Utility method to check if notifications are available
  static bool hasNotifications(BuildContext context) {
    final workerManager = Provider.of<WorkerManagerProvider>(
      context,
      listen: false,
    );

    return workerManager.newNotificationCount > 0;
  }

  /// Utility method to get notification count without listening
  static int getNotificationCount(BuildContext context) {
    final workerManager = Provider.of<WorkerManagerProvider>(
      context,
      listen: false,
    );

    return workerManager.newNotificationCount;
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:good_one_app/Core/Presentation/Widgets/notification_badge.dart';
// import 'package:good_one_app/Core/Utils/user_helper.dart';
// import 'package:good_one_app/Providers/User/user_manager_provider.dart';
// import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

// /// A helper class for managing notifications across the app in a DRY way
// class NotificationHelper {
//   /// Gets the unread notification count from the appropriate provider
//   static int getUnreadCount(BuildContext context) {
//     try {
//       // Check if current user is a worker
//       if (UserHelper.isWorker(context)) {
//         final workerManager = context.read<WorkerManagerProvider>();
//         return workerManager.unreadNotificationCount;
//       }

//       // Default to user manager
//       final userManager = context.read<UserManagerProvider>();
//       return userManager.unreadNotificationCount;
//     } catch (e) {
//       debugPrint('NotificationHelper: Error getting unread count: $e');
//       return 0;
//     }
//   }

//   /// Marks all notifications as read for the current user type
//   static Future<void> markAllAsRead(BuildContext context) async {
//     try {
//       // Check if current user is a worker
//       if (UserHelper.isWorker(context)) {
//         debugPrint(
//             'NotificationHelper: Marking notifications as read for WORKER');
//         final workerManager = context.read<WorkerManagerProvider>();
//         await workerManager.markAllNotificationsAsRead();
//         return;
//       }

//       // Default to user manager
//       debugPrint('NotificationHelper: Marking notifications as read for USER');
//       final userManager = context.read<UserManagerProvider>();
//       await userManager.markAllNotificationsAsRead();
//     } catch (e) {
//       debugPrint('NotificationHelper: Error marking notifications as read: $e');
//     }
//   }

//   /// Builds a notification icon with badge based on the current user type
//   static Widget buildNotificationIconWithBadge({
//     required BuildContext context,
//     required Widget icon,
//     required VoidCallback onTap,
//   }) {
//     return Consumer2<UserManagerProvider, WorkerManagerProvider>(
//       builder: (context, userManager, workerManager, child) {
//         int unreadCount = 0;

//         // Determine which provider to use based on current user type
//         if (UserHelper.isWorker(context)) {
//           unreadCount = workerManager.unreadNotificationCount;
//         } else {
//           unreadCount = userManager.unreadNotificationCount;
//         }

//         return NotificationBadge(
//           count: unreadCount,
//           child: GestureDetector(
//             onTap: onTap,
//             child: icon,
//           ),
//         );
//       },
//     );
//   }

//   /// Fetches notifications for the current user type
//   static Future<void> fetchNotifications(BuildContext context) async {
//     try {
//       // Check if current user is a worker
//       if (UserHelper.isWorker(context)) {
//         final workerManager = context.read<WorkerManagerProvider>();
//         await workerManager.fetchNotifications();
//         return;
//       }

//       // Default to user manager
//       final userManager = context.read<UserManagerProvider>();
//       await userManager.fetchNotifications();
//     } catch (e) {
//       debugPrint('NotificationHelper: Error fetching notifications: $e');
//     }
//   }
// }
