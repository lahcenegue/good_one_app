import 'package:flutter/foundation.dart';
import '../../../Core/infrastructure/api/api_endpoints.dart';
import '../../../Core/infrastructure/api/api_service.dart';
import '../../../Core/infrastructure/api/api_response.dart';
import '../Models/chat_conversation.dart';
import '../Models/chat_message.dart';

class ChatService {
  final ApiService _api = ApiService.instance;

  // Get all conversations
  Future<ApiResponse<List<ChatConversation>>> getConversations(
      {required String token}) async {
    try {
      final response = await _api.get<List<ChatConversation>>(
        url: ApiEndpoints.chat,
        token: token,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) =>
                    ChatConversation.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return ApiResponse.error('Failed to load conversations');
    }
  }

  // Get messages for a specific conversation
  Future<ApiResponse<List<ChatMessage>>> getMessages({
    required String token,
    required String userId,
    int? startFrom,
  }) async {
    try {
      final response = await _api.get<List<ChatMessage>>(
        url: ApiEndpoints.messages(userId, startFrom: startFrom),
        token: token,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) =>
                    ChatMessage.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return ApiResponse.error('Failed to load messages');
    }
  }

  // Send a message
  Future<ApiResponse<ChatMessage>> sendMessage({
    required String token,
    required String userId,
    required String message,
  }) async {
    try {
      final response = await _api.post<ChatMessage>(
        url: ApiEndpoints.send,
        body: {
          'user_id': userId,
          'message': message,
        },
        token: token,
        fromJson: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return ApiResponse.error('Failed to send message');
    }
  }
}
