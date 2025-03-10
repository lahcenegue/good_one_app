/// Represents a notification item with user details, parsed from the API response.
class NotificationModel {
  final String? userName; // Name of the user (e.g., "Honey Bee" or fallback)
  final String? picture; // URL or path to the user's profile picture
  final String? action; // Action text (e.g., "Approved your service request")
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
      userName: json['user']?['name'] as String? ?? 'User Name',
      picture: json['picture'] as String?,
      action: json['text'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converts the model to a JSON object (for potential future use).
  Map<String, dynamic> toJson() => {
        'user': {'name': userName, 'picture': picture},
        'text': action,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Validates the model to ensure required fields are present.
  bool isValid() =>
      action != null && createdAt != null; // Only require action and createdAt
}
