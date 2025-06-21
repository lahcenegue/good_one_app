import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';

class UserHelper {
  /// Gets the current user ID from either UserManagerProvider or WorkerManagerProvider
  /// Returns null if no user is found in either provider
  static String? getCurrentUserId(BuildContext context) {
    try {
      // First try UserManagerProvider
      final userProvider = context.read<UserManagerProvider>();
      if (userProvider.userInfo != null) {
        debugPrint(
            'UserHelper: Found user in UserManagerProvider - ID: ${userProvider.userInfo!.id}');
        return userProvider.userInfo!.id.toString();
      }

      // Fallback to WorkerManagerProvider
      final workerProvider = context.read<WorkerManagerProvider>();
      if (workerProvider.workerInfo != null) {
        debugPrint(
            'UserHelper: Found user in WorkerManagerProvider - ID: ${workerProvider.workerInfo!.id}');
        return workerProvider.workerInfo!.id.toString();
      }

      debugPrint('UserHelper: No user found in either provider');
      return null;
    } catch (e) {
      debugPrint('UserHelper: Error getting user ID: $e');
      return null;
    }
  }

  /// Gets the current user's full name from either provider
  static String? getCurrentUserName(BuildContext context) {
    try {
      // First try UserManagerProvider
      final userInfo = context.read<UserManagerProvider>().userInfo;
      if (userInfo != null) {
        return userInfo.fullName;
      }

      // Fallback to WorkerManagerProvider
      final workerInfo = context.read<WorkerManagerProvider>().workerInfo;
      if (workerInfo != null) {
        return workerInfo.fullName;
      }

      return null;
    } catch (e) {
      debugPrint('UserHelper: Error getting user name: $e');
      return null;
    }
  }

  /// Determines if the current user is a worker
  static bool isWorker(BuildContext context) {
    try {
      final workerInfo = context.read<WorkerManagerProvider>().workerInfo;
      return workerInfo != null;
    } catch (e) {
      debugPrint('UserHelper: Error checking if user is worker: $e');
      return false;
    }
  }

  /// Determines if the current user is a customer/user
  static bool isUser(BuildContext context) {
    try {
      final userInfo = context.read<UserManagerProvider>().userInfo;
      return userInfo != null;
    } catch (e) {
      debugPrint('UserHelper: Error checking if user is customer: $e');
      return false;
    }
  }
}
