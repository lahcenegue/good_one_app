import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_service.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';

import 'package:good_one_app/Features/Both/Models/account_edit_request.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';
import 'package:good_one_app/Features/Both/Models/tax_model.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';

/// Enhanced API service for Both (shared) functionality
/// with improved error handling, logging, and retry mechanisms
class BothApi {
  static final _api = ApiService.instance;

  /// Get user information
  static Future<ApiResponse<UserInfo>> getUserInfo() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<UserInfo>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      return await _api.post<UserInfo>(
        url: ApiEndpoints.me,
        body: {},
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            return UserInfo.fromJson(response);
          }
          throw Exception('Invalid response format for user info');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<UserInfo>(
        success: false,
        error: 'Failed to get user info: ${e.toString()}',
      );
    }
  }

  /// Edit user account
  static Future<ApiResponse<UserInfo>> editAccount(
      AccountEditRequest request) async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<UserInfo>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      return await _api.postMultipart<UserInfo>(
        url: ApiEndpoints.accountEdit,
        fields: request.toFields(),
        files: request.toFiles(),
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            return UserInfo.fromJson(response);
          }
          throw Exception('Invalid response format for account edit');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<UserInfo>(
        success: false,
        error: 'Failed to edit account: ${e.toString()}',
      );
    }
  }

  /// Fetch all notifications for the user
  /// Enhanced with better error handling and data validation
  static Future<ApiResponse<List<NotificationModel>>>
      fetchNotifications() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<List<NotificationModel>>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      final response = await _api.get<List<NotificationModel>>(
        url: ApiEndpoints.notifications,
        fromJson: (dynamic response) {
          if (response is List) {
            try {
              final parsed = response.map((item) {
                if (item is Map<String, dynamic>) {
                  return NotificationModel.fromJson(item);
                }
                throw Exception('Invalid notification item format');
              }).toList();

              // Sort by creation date (newest first)
              parsed.sort((a, b) {
                return b.createdAt.compareTo(a.createdAt);
              });

              return parsed;
            } catch (e) {
              throw Exception('Failed to parse notifications: ${e.toString()}');
            }
          }
          throw Exception(
              'Invalid response format: expected List, got ${response.runtimeType}');
        },
        token: token,
      );

      return response;
    } catch (e) {
      return ApiResponse<List<NotificationModel>>(
        success: false,
        error: 'Failed to fetch notifications: ${e.toString()}',
      );
    }
  }

  /// Get count of new notifications (never seen before)
  /// Enhanced with better error handling
  static Future<ApiResponse<int>> getNewNotificationsCount() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<int>(
          success: false,
          error: 'Authentication token not found',
          data: 0,
        );
      }

      return await _api.get<int>(
        url: ApiEndpoints.newNotificationsCount,
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            final count = response['new_notifications_count'];
            if (count is int) {
              return count;
            }
            if (count is String) {
              return int.tryParse(count) ?? 0;
            }
            return 0;
          }
          throw Exception('Invalid response format for notification count');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        error: 'Failed to get new notifications count: ${e.toString()}',
        data: 0,
      );
    }
  }

  /// Get count of unread notifications (seen but not marked as read)
  /// Enhanced with better error handling
  static Future<ApiResponse<int>> getUnreadNotificationsCount() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<int>(
          success: false,
          error: 'Authentication token not found',
          data: 0,
        );
      }

      return await _api.get<int>(
        url: ApiEndpoints.unreadNotificationsCount,
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            final count = response['unread_notifications_count'];
            if (count is int) {
              return count;
            }
            if (count is String) {
              return int.tryParse(count) ?? 0;
            }
            return 0;
          }
          throw Exception(
              'Invalid response format for unread notification count');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        error: 'Failed to get unread notifications count: ${e.toString()}',
        data: 0,
      );
    }
  }

  /// Mark all notifications as seen (when entering notifications screen)
  /// Enhanced with better error handling and response validation
  static Future<ApiResponse<String>> markNotificationsAsSeen() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<String>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      return await _api.post<String>(
        url: ApiEndpoints.markNotificationsAsSeen,
        body: {},
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            final success = response['success'] ?? true;
            final message = response['message'] as String? ?? 'Success';

            if (success == true || success == 'true') {
              return message;
            } else {
              throw Exception('Backend reported failure: $message');
            }
          }
          throw Exception('Invalid response format for mark as seen');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: 'Failed to mark notifications as seen: ${e.toString()}',
      );
    }
  }

  /// Mark specific notifications as read
  /// Enhanced with validation and error handling
  static Future<ApiResponse<String>> markNotificationsAsRead(
      List<String> notificationIds) async {
    try {
      if (notificationIds.isEmpty) {
        return ApiResponse<String>(
          success: false,
          error: 'No notification IDs provided',
        );
      }

      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<String>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      // Convert string IDs to integers and filter out invalid ones
      final validIds = notificationIds
          .map((id) => int.tryParse(id))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (validIds.isEmpty) {
        return ApiResponse<String>(
          success: false,
          error: 'No valid notification IDs provided',
        );
      }

      return await _api.post<String>(
        url: ApiEndpoints.markNotificationsAsRead,
        body: {
          'notification_ids': validIds,
        },
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            final success = response['success'] ?? true;
            final message = response['message'] as String? ?? 'Success';

            if (success == true || success == 'true') {
              return message;
            } else {
              throw Exception('Backend reported failure: $message');
            }
          }
          throw Exception('Invalid response format for mark as read');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: 'Failed to mark notifications as read: ${e.toString()}',
      );
    }
  }

  /// Mark all notifications as read
  /// Enhanced with better error handling and response validation
  static Future<ApiResponse<String>> markAllNotificationsAsRead() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);

      if (token == null) {
        return ApiResponse<String>(
          success: false,
          error: 'Authentication token not found',
        );
      }

      return await _api.post<String>(
        url: ApiEndpoints.markAllNotificationsAsRead,
        body: {},
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            final success = response['success'] ?? true;
            final message = response['message'] as String? ?? 'Success';

            if (success == true || success == 'true') {
              return message;
            } else {
              throw Exception('Backend reported failure: $message');
            }
          }
          throw Exception('Invalid response format for mark all as read');
        },
        token: token,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: 'Failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }

  /// Fetch taxes based on region
  /// Enhanced with better error handling
  static Future<ApiResponse<TaxModel>> fetchTaxes(String region) async {
    try {
      if (region.trim().isEmpty) {
        return ApiResponse<TaxModel>(
          success: false,
          error: 'Region parameter is required',
        );
      }

      return await _api.get<TaxModel>(
        url: '${ApiEndpoints.taxes}?region=${Uri.encodeComponent(region)}',
        fromJson: (dynamic response) {
          if (response is Map<String, dynamic>) {
            return TaxModel.fromJson(response);
          }
          throw Exception('Invalid response format for tax data');
        },
      );
    } catch (e) {
      return ApiResponse<TaxModel>(
        success: false,
        error: 'Failed to fetch taxes: ${e.toString()}',
      );
    }
  }

  /// Utility method to check if token is valid
  static Future<bool> isTokenValid() async {
    try {
      final token = await StorageManager.getString(StorageKeys.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
