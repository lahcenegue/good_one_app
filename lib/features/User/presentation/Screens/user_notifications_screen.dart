import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Enhanced user notifications screen with professional architecture
/// Handles notification display, marking as seen/read, and user interactions
class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  bool _hasTriggeredSeenUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Mark notifications as seen when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markNotificationsAsSeen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh notifications when app comes back to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      final userManager =
          Provider.of<UserManagerProvider>(context, listen: false);
      userManager.fetchNotifications();
    }
  }

  /// Enhanced method to mark notifications as seen with better error handling
  Future<void> _markNotificationsAsSeen() async {
    if (_hasTriggeredSeenUpdate) return;

    final userManager =
        Provider.of<UserManagerProvider>(context, listen: false);

    if (userManager.unreadNotificationCount > 0) {
      _hasTriggeredSeenUpdate = true;

      try {
        await userManager.markAllNotificationsAsSeenNew();

        // Start animation after successful update
        if (mounted) {
          _animationController.forward();
        }
      } catch (e) {
        debugPrint('Error marking notifications as seen: $e');
        // Reset flag on error so user can try again
        _hasTriggeredSeenUpdate = false;
      }
    } else {
      // Even if no new notifications, start animation for existing ones
      if (mounted) {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Consumer<UserManagerProvider>(
        builder: (context, provider, child) {
          // Show loading state only when loading AND no cached notifications
          if (provider.isNotificationLoading &&
              provider.notifications.isEmpty) {
            return _buildLoadingState(context);
          }

          // Show error state only when there's a notification error AND no cached notifications
          if (provider.notificationError != null &&
              provider.notifications.isEmpty) {
            return _buildErrorState(context, provider);
          }

          // Show empty state only when explicitly no notifications (not loading)
          if (provider.notifications.isEmpty &&
              !provider.isNotificationLoading) {
            return _buildEmptyState(context, provider);
          }

          // Show notifications list (this should always show cached notifications)
          return _buildNotificationsList(context, provider);
        },
      ),
    );
  }

  /// Enhanced app bar with better action handling
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Text(
        AppLocalizations.of(context)!.notifications,
        style: AppTextStyles.appBarTitle(context).copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer<UserManagerProvider>(
          builder: (context, provider, child) {
            final hasNotifications = provider.notifications.isNotEmpty;
            final hasUnreadNotifications = provider.unreadNotificationCount > 0;

            if (hasNotifications) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: hasUnreadNotifications
                      ? () => _markAllAsRead(context, provider)
                      : null,
                  icon: Icon(
                    Icons.done_all,
                    size: 18,
                    color: hasUnreadNotifications
                        ? AppColors.primaryColor
                        : Colors.grey,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.markAllAsRead,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasUnreadNotifications
                          ? AppColors.primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Enhanced mark all as read with better UX
  Future<void> _markAllAsRead(
      BuildContext context, UserManagerProvider provider) async {
    try {
      await provider.markAllNotificationsAsRead();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.allNotificationsMarkedAsRead,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToMarkAsRead,
            ),
            backgroundColor: AppColors.errorDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Enhanced loading state
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loadingNotifications,
            style: AppTextStyles.text(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced error state with retry functionality
  Widget _buildErrorState(
    BuildContext context,
    UserManagerProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingNotifications,
              style: AppTextStyles.title2(context).copyWith(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.notificationError ??
                  AppLocalizations.of(context)!.unknownErrorOccurred,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                provider.clearNotificationError();
                await provider.fetchNotifications();
              },
              text: AppLocalizations.of(context)!.retry,
              width: context.getWidth(150),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced empty state with better design
  Widget _buildEmptyState(
    BuildContext context,
    UserManagerProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noNotifications,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noNotificationsMessage,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                await provider.fetchNotifications();
              },
              text: AppLocalizations.of(context)!.refresh,
              width: context.getWidth(120),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced notifications list with better performance and animations
  Widget _buildNotificationsList(
      BuildContext context, UserManagerProvider provider) {
    final notifications = provider.notifications;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchNotifications();
      },
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Enhanced animation with better performance
              final maxItems = 10;
              final animationIndex = index.clamp(0, maxItems - 1);
              final startInterval = (animationIndex * 0.1).clamp(0.0, 0.7);
              final endInterval =
                  (startInterval + 0.3).clamp(startInterval, 1.0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    startInterval,
                    endInterval,
                    curve: Curves.easeOutQuart,
                  ),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      startInterval,
                      (startInterval + 0.5).clamp(startInterval, 1.0),
                      curve: Curves.easeOut,
                    ),
                  )),
                  child:
                      _buildNotificationCard(context, notification, provider),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Enhanced notification card with better interaction and visual feedback
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    UserManagerProvider provider,
  ) {
    // Enhanced time formatting using the model's utility method
    final timeString = notification.formattedCreatedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: notification.isNew ? 4 : 1,
        shadowColor: notification.isNew
            ? AppColors.primaryColor.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notification.isNew
              ? BorderSide(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: notification.isNew
                ? LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.primaryColor.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: notification.isNew ? null : Colors.white,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                UserAvatar(
                  picture: notification.picture,
                  size: 50,
                  backgroundColor: Colors.grey[100]!,
                ),
                if (notification.isNew)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification.userName,
                    style: AppTextStyles.title2(context).copyWith(
                      fontWeight: notification.isNew
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (notification.isNew)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.newLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.action,
                  style: AppTextStyles.text(context).copyWith(
                    fontSize: 14,
                    color:
                        notification.isNew ? Colors.black87 : Colors.grey[700],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () =>
                _handleNotificationTap(context, notification, provider),
          ),
        ),
      ),
    );
  }

  /// Enhanced notification tap handler
  Future<void> _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    UserManagerProvider provider,
  ) async {
    try {
      // Mark this specific notification as read if it's not already
      if (!notification.isRead) {
        await provider.markNotificationsAsRead([notification.id]);
      }

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.notificationOpened} ${notification.userName}',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorOpeningNotification,
            ),
            backgroundColor: AppColors.errorDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
