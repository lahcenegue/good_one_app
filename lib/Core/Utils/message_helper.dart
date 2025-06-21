// Update the MessageHelper (Core/Utils/message_helper.dart) to work with both user types
// Replace the existing MessageHelper content with this enhanced version:

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';

/// Enhanced message helper with badge management
/// Works for both Worker and User sections
class MessageHelper {
  /// Builds a message icon with a smart badge that shows unread count
  static Widget buildMessageIconWithBadge({
    required BuildContext context,
    required Widget icon,
    required VoidCallback? onTap,
    Color? badgeColor,
    Color? textColor,
    double? badgeSize,
    bool showZeroBadge = false,
  }) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final unreadCount = _getUnreadMessageCount(chatProvider);
        final hasUnreadMessages = unreadCount > 0;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              icon,
              if (hasUnreadMessages || showZeroBadge)
                Positioned(
                  top: -6,
                  right: -6,
                  child: _buildBadge(
                    context: context,
                    count: unreadCount,
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

  /// Calculates unread message count from conversations
  static int _getUnreadMessageCount(ChatProvider chatProvider) {
    try {
      if (!chatProvider.initialFetchComplete) {
        // Still loading, don't show badge yet
        return 0;
      }

      return chatProvider.conversations
          .where((conversation) => conversation.hasNewMessages)
          .length;
    } catch (e) {
      debugPrint('MessageHelper: Error getting unread count: $e');
      return 0;
    }
  }

  /// Builds a customizable message badge
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

  /// Creates a message badge for use in bottom navigation
  static Widget buildBottomNavBadge({
    required BuildContext context,
    required Widget child,
    bool showBadge = true,
  }) {
    if (!showBadge) return child;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final count = _getUnreadMessageCount(chatProvider);

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

  /// Utility method to check if there are unread messages
  static bool hasUnreadMessages(BuildContext context) {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      return _getUnreadMessageCount(chatProvider) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Utility method to get unread message count without listening
  static int getUnreadMessageCount(BuildContext context) {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      return _getUnreadMessageCount(chatProvider);
    } catch (e) {
      return 0;
    }
  }

  /// Refreshes conversations to update unread counts
  static Future<void> refreshMessageCounts(BuildContext context) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.refreshConversationCounts();
    } catch (e) {
      debugPrint('MessageHelper: Error refreshing message counts: $e');
    }
  }

  /// Initializes chat for the current user (helper method)
  static Future<void> initializeChatForUser(
    BuildContext context,
    String userId,
  ) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize(userId);
    } catch (e) {
      debugPrint('MessageHelper: Error initializing chat for user $userId: $e');
    }
  }
}
