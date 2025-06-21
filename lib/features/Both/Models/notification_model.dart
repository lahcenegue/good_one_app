import 'package:flutter/foundation.dart';

/// Enhanced notification model with better data validation,
/// error handling, and utility methods
@immutable
class NotificationModel {
  final String id;
  final String userName;
  final String? picture;
  final String action;
  final DateTime createdAt;
  final bool isRead;
  final bool isNew;
  final DateTime? seenAt;
  final DateTime? readAt;
  final String? orderId;

  const NotificationModel({
    required this.id,
    required this.userName,
    this.picture,
    required this.action,
    required this.createdAt,
    this.isRead = false,
    this.isNew = true,
    this.seenAt,
    this.readAt,
    this.orderId,
  });

  /// Enhanced JSON parsing with better error handling and validation
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse ID with fallback
      String parsedId;
      if (json['id'] != null) {
        parsedId = json['id'].toString();
      } else {
        parsedId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Parse user name with fallback
      String parsedUserName = 'Unknown User';
      if (json['user'] is String && (json['user'] as String).isNotEmpty) {
        parsedUserName = json['user'] as String;
      } else if (json['user_name'] is String &&
          (json['user_name'] as String).isNotEmpty) {
        parsedUserName = json['user_name'] as String;
      }

      // Parse action/text with fallback
      String parsedAction = 'No message';
      if (json['text'] is String && (json['text'] as String).isNotEmpty) {
        parsedAction = json['text'] as String;
      } else if (json['action'] is String &&
          (json['action'] as String).isNotEmpty) {
        parsedAction = json['action'] as String;
      }

      // Parse creation date with fallback
      DateTime parsedCreatedAt = DateTime.now();
      if (json['created_at'] is String) {
        try {
          parsedCreatedAt = DateTime.parse(json['created_at'] as String);
        } catch (e) {
          debugPrint('Error parsing created_at: $e');
        }
      }

      // Parse boolean fields with proper conversion
      bool parsedIsRead = false;
      final isReadValue = json['is_read'];
      if (isReadValue is bool) {
        parsedIsRead = isReadValue;
      } else if (isReadValue is int) {
        parsedIsRead = isReadValue == 1;
      } else if (isReadValue is String) {
        parsedIsRead =
            isReadValue.toLowerCase() == 'true' || isReadValue == '1';
      }

      bool parsedIsNew = true;
      final isNewValue = json['is_new'];
      if (isNewValue is bool) {
        parsedIsNew = isNewValue;
      } else if (isNewValue is int) {
        parsedIsNew = isNewValue == 1;
      } else if (isNewValue is String) {
        parsedIsNew = isNewValue.toLowerCase() == 'true' || isNewValue == '1';
      }

      // Parse optional dates
      DateTime? parsedSeenAt;
      if (json['seen_at'] is String) {
        try {
          parsedSeenAt = DateTime.parse(json['seen_at'] as String);
        } catch (e) {
          debugPrint('Error parsing seen_at: $e');
        }
      }

      DateTime? parsedReadAt;
      if (json['read_at'] is String) {
        try {
          parsedReadAt = DateTime.parse(json['read_at'] as String);
        } catch (e) {
          debugPrint('Error parsing read_at: $e');
        }
      }

      // Parse order ID
      String? parsedOrderId;
      if (json['order_id'] != null) {
        parsedOrderId = json['order_id'].toString();
      }

      return NotificationModel(
        id: parsedId,
        userName: parsedUserName,
        picture: json['picture'] as String?,
        action: parsedAction,
        createdAt: parsedCreatedAt,
        isRead: parsedIsRead,
        isNew: parsedIsNew,
        seenAt: parsedSeenAt,
        readAt: parsedReadAt,
        orderId: parsedOrderId,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing NotificationModel: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('JSON data: $json');

      // Return a fallback notification model
      return NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'Unknown User',
        action: 'Failed to load notification',
        createdAt: DateTime.now(),
        isRead: false,
        isNew: true,
      );
    }
  }

  /// Enhanced JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'user': userName,
        'picture': picture,
        'text': action,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'is_new': isNew,
        'seen_at': seenAt?.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
        'order_id': orderId,
      };

  /// Enhanced copyWith method
  NotificationModel copyWith({
    String? id,
    String? userName,
    String? picture,
    String? action,
    DateTime? createdAt,
    bool? isRead,
    bool? isNew,
    DateTime? seenAt,
    DateTime? readAt,
    String? orderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      picture: picture ?? this.picture,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isNew: isNew ?? this.isNew,
      seenAt: seenAt ?? this.seenAt,
      readAt: readAt ?? this.readAt,
      orderId: orderId ?? this.orderId,
    );
  }

  /// Utility methods
  bool get hasBeenSeen => seenAt != null;
  bool get hasBeenRead => readAt != null;

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get priority {
    if (isNew) return 'high';
    if (!isRead) return 'medium';
    return 'low';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel{id: $id, userName: $userName, action: $action, isNew: $isNew, isRead: $isRead}';
  }
}
