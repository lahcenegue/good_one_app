class ChatMessage {
  final String message;
  final String userId;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Extract and validate 'message'
    final message = json['message'] as String? ?? '';

    // Extract 'userId' with a default value if missing or invalid
    final userId = (json['userId'] as String?) ?? 'unknown_user';

    // Extract and validate 'timestamp'
    final timestampString = json['timestamp'] as String?;
    final timestamp = timestampString != null
        ? DateTime.parse(timestampString)
        : DateTime.now();

    return ChatMessage(
      message: message,
      userId: userId,
      timestamp: timestamp,
    );
  }
}
