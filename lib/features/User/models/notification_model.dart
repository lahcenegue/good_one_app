/// Represents a notification item with user details, parsed from the API response.
class NotificationModel {
  final String? userName;
  final String? picture;
  final String? action;
  final DateTime? createdAt;

  NotificationModel({
    this.userName,
    this.picture,
    this.action,
    this.createdAt,
  });

  /// Parses a JSON object into a NotificationModel instance.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      userName: json['user'] as String? ?? 'User Name',
      picture: json['picture'] as String?,
      action: json['text'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converts the model to a JSON object (for potential future use).
  Map<String, dynamic> toJson() => {
        'user': userName,
        'picture': picture,
        'text': action,
        'created_at': createdAt?.toIso8601String(),
      };
}
