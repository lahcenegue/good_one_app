import 'package:good_one_app/features/chat/domain/entities/chat_user.dart';

/// Data model for a chat user, used for serialization.
class ChatUserModel extends ChatUser {
  const ChatUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.picture,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'picture': picture,
    };
  }
}
