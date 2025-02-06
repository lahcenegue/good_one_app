class ChatUser {
  final int id;
  final String email;
  final String fullName;
  final String picture;

  ChatUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.picture,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
    );
  }
}

class ChatConversation {
  final ChatUser user;
  final bool hasNewMessages;
  final String? latestMessage;
  final String? time;

  ChatConversation({
    required this.user,
    required this.hasNewMessages,
    this.latestMessage,
    this.time,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      user: ChatUser.fromJson(json['with'] as Map<String, dynamic>),
      hasNewMessages: json['new_messages'] as bool? ?? false,
      latestMessage: json['latest_message'] as String?,
      time: json['time'] as String?,
    );
  }
}
