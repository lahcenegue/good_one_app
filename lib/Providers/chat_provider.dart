import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../Core/infrastructure/websocket/websocket_service.dart';
import '../Features/Chat/Models/chat_conversation.dart';
import '../Features/Chat/Models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final WebSocketService _socket = WebSocketService();
  final scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;
  String? _currentChatUserId;
  String? _currentUserId;

  // Getters
  List<ChatMessage> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;
  String? get currentChatUserId => _currentChatUserId;
  String? get currentUserId => _currentUserId;
  ScrollController get messageScrollController => scrollController;

  // Initialize conversations list using WebSocket
  Future<void> initializeConversations() async {
    try {
      _setLoading(true);
      _error = null;

      if (!_isConnected || _currentUserId == null) {
        _error = 'Not connected to chat server';
        return;
      }

      // Emit get-chats event to retrieve conversations
      _socket.emit('get-chats', []);
    } catch (e) {
      _error = 'Failed to load conversations: ${e.toString()}';
      debugPrint('Chat initialization error: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Initialize WebSocket and chat
  Future<bool> initialize(String userId) async {
    _currentUserId = userId;
    try {
      _setupSocketListeners();
      await _socket.connect();
      await _socket.waitForConnection();
      return _isConnected;
    } catch (e) {
      _handleError('Connection error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> waitForConnection() async {
    int attempts = 0;
    const maxAttempts = 10;
    const timeoutDuration = Duration(seconds: 1);

    while (attempts < maxAttempts && !_isConnected) {
      if (_socket.isConnected) {
        _isConnected = true;
        return true;
      }
      await Future.delayed(timeoutDuration);
      attempts++;
      debugPrint('Connection attempt $attempts of $maxAttempts');
    }

    return _isConnected;
  }

  void _setupSocketListeners() {
    _socket.onConnected = () {
      _isConnected = true;
      _error = null;
      notifyListeners();
      if (_currentUserId != null) {
        debugPrint('Emitting init with userId: $_currentUserId');
        _socket.emit('init', [_currentUserId!]);

// Get initial conversations after connection
        Future.delayed(const Duration(milliseconds: 500), () {
          debugPrint('Requesting chats after init');
          initializeConversations();
        });
      }
    };

    _socket.onDisconnected = () {
      _isConnected = false;
      notifyListeners();
    };

    _socket.onError = (error) {
      _handleError('WebSocket error: $error');
    };

    _socket.onMessageReceived = (data) {
      debugPrint('Received message data type: ${data.runtimeType}');
      debugPrint('Received message data: $data');
      _handleMessageReceived(data);
    };

    // Add listener for chats event
    _socket.on('chats', (data) {
      _handleChatsReceived(data);
    });
  }

  void _handleChatsReceived(dynamic data) {
    try {
      debugPrint('Processing chats data: $data');

      // Ensure we have a Map to work with
      final Map chatData = data is String ? json.decode(data) : data;

      final List<ChatConversation> newConversations = [];

      chatData.forEach((key, value) {
        try {
          debugPrint('Processing chat entry: key=$key, value=$value');
          if (value is Map && value.containsKey('user_info')) {
            final userInfo = value['user_info'] as Map;
            final hasNewMessages =
                value['new_message']?.toString().isNotEmpty ?? false;
            final latestMessage = value['latest_message']?.toString() ?? '';

            newConversations.add(ChatConversation(
              user: ChatUser(
                id: int.tryParse(key) ?? 0,
                email: '', // Add if available
                fullName: userInfo['full_name']?.toString() ?? '',
                picture: userInfo['picture']?.toString() ?? '',
              ),
              latestMessage: latestMessage,
              time: DateTime.now()
                  .toString(), // Add proper timestamp if available
              hasNewMessages: hasNewMessages,
            ));
            debugPrint(
                'Successfully added conversation for user: ${userInfo['full_name']}');
          }
        } catch (e) {
          debugPrint('Error processing individual chat: $e');
        }
      });

      debugPrint(
          'Successfully processed ${newConversations.length} conversations');
      _conversations = newConversations;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error processing chats: $e');
      _handleError('Error processing conversations: $e');
    }
  }

  void _handleMessageReceived(dynamic data) {
    debugPrint('Received message data type: ${data.runtimeType}');
    debugPrint('Received message data: $data');
    try {
      if (data is String) {
        data = json.decode(data);
      }

      // Check if this is a chats response
      if (data is Map &&
          data.values.any((v) => v is Map && v.containsKey('user_info'))) {
        debugPrint('Detected chats response, processing...');
        _handleChatsReceived(data);
        return;
      }

      // Handle other message types
      if (data is Map) {
        if (data.containsKey('0')) {
          _handleMessageHistory(data);
        } else if (data.containsKey('message')) {
          _handleSingleMessage(data);
        }
      }
    } catch (e) {
      debugPrint('Error in _handleMessageReceived: $e');
    }
  }

  void _handleMessageHistory(Map data) {
    final List<ChatMessage> messages = [];
    data.forEach((key, value) {
      if (value is Map) {
        try {
          messages.add(_createChatMessage(value));
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }
      }
    });
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _messages = messages;
    _setLoading(false);
    notifyListeners();
  }

  void _handleSingleMessage(Map data) {
    final message = _createChatMessage(data);
    _messages.add(message);
    notifyListeners();
  }

  ChatMessage _createChatMessage(Map data) {
    return ChatMessage(
      message: data['message']?.toString() ?? '',
      userId: data['from_user']?.toString() ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          ((data['time'] ?? (DateTime.now().millisecondsSinceEpoch / 1000)) *
                  1000)
              .toInt()),
    );
  }

  // Initialize chat with specific user
  Future<void> initializeChat(String otherUserId) async {
    _currentChatUserId = otherUserId;
    _messages.clear();
    _error = null;
    _setLoading(true);
    notifyListeners();

    if (!_isConnected) {
      if (_currentUserId == null || !await initialize(_currentUserId!)) {
        _handleError('Failed to connect to chat server');
        return;
      }
    }

    debugPrint('Joining room with user: $otherUserId');
    _socket.emit('join-room', [otherUserId]);

    await Future.delayed(const Duration(milliseconds: 500));
    _socket.emit('get-messages', [otherUserId, 0]);
  }

  void sendMessage(String message, String otherUserId) {
    if (!_isConnected) {
      _handleError('Not connected to chat server');
      return;
    }

    if (message.trim().isEmpty) return;

    debugPrint('Sending message to user: $otherUserId');
    _socket.emit('send-message', [otherUserId, message]);
  }

  void loadMoreMessages(String userId, {int? startFrom}) {
    if (!_isConnected) return;
    debugPrint('Loading more messages from: $startFrom');
    _socket.emit('get-messages', [userId, startFrom ?? _messages.length]);
  }

  // Leave current chat
  void leaveChat() {
    if (_currentChatUserId != null && _isConnected) {
      debugPrint('Leaving room with user: $_currentChatUserId');
      _socket.emit('leave-room', [_currentChatUserId!]);
      _currentChatUserId = null;
      _messages.clear();
      notifyListeners();
    }
  }

  void _handleError(String errorMessage) {
    _error = errorMessage;
    debugPrint(_error);
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _socket.disconnect();
    super.dispose();
  }
}
