import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:good_one_app/Core/infrastructure/websocket/websocket_service.dart';
import 'package:good_one_app/Features/Chat/Models/chat_conversation.dart';
import 'package:good_one_app/Features/Chat/Models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final WebSocketService _socketService;
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isConnected = false;
  bool _initialFetchComplete = false;
  String? _error;
  String? _currentChatUserId;
  String? _currentId;

  ChatProvider({WebSocketService? socketService})
      : _socketService = socketService ?? WebSocketService();

  List<ChatMessage> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isConnected => _isConnected;
  bool get initialFetchComplete => _initialFetchComplete;
  String? get error => _error;
  String? get currentChatUserId => _currentChatUserId;
  String? get currentUserId => _currentId;
  ScrollController get scrollController => _scrollController;

  Future<void> initialize(String id) async {
    _currentId = id;
    try {
      _setupSocketListeners();
      await _socketService.connect();
      _isConnected = await _socketService.waitForConnection();
      if (_isConnected) {
        await initializeConversations();
      } else {
        _setError('Failed to establish WebSocket connection');
        _initialFetchComplete = true;
        notifyListeners();
      }
    } catch (e) {
      _setError('Initialization error: $e');
      _setLoadingConversations(false);
      _initialFetchComplete = true;
      notifyListeners();
    }
  }

  Future<void> initializeConversations() async {
    if (!_isConnected || _currentId == null) {
      _setError('Not connected or user ID missing');
      return;
    }
    _setLoadingConversations(true);
    _initialFetchComplete = false;
    try {
      _socketService.emit('get-chats', []);
      // Wait for a maximum of 5 seconds for the response
      await Future.delayed(const Duration(seconds: 5)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout waiting for chat conversations');
        },
      );
    } catch (e) {
      _setError('Failed to fetch conversations: $e');
    } finally {
      _initialFetchComplete = true;
      _setLoadingConversations(false);
      notifyListeners();
    }
  }

  Future<void> initializeChat(String otherUserId) async {
    _currentChatUserId = otherUserId;
    _messages = [];
    _isLoadingMessages = true;
    _error = null;
    try {
      _socketService.emit('join-room', [otherUserId]);
      _socketService.emit('get-messages', [otherUserId, 0]);
      final index =
          _conversations.indexWhere((c) => c.user.id.toString() == otherUserId);
      if (index != -1) {
        _conversations[index] = ChatConversation(
          user: _conversations[index].user,
          latestMessage: _conversations[index].latestMessage,
          time: _conversations[index].time,
          hasNewMessages: false,
        );
        debugPrint(
            'Chat opened for $otherUserId, hasNewMessages reset to false');
        notifyListeners();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to initialize chat: $e');
    }
  }

  void sendMessage(String message, String otherUserId) {
    if (!_isConnected || message.trim().isEmpty) return;
    final chatMessage = ChatMessage(
      message: message,
      userId: _currentId!,
      timestamp: DateTime.now(),
    );
    _messages.add(chatMessage);
    _updateConversation(otherUserId, chatMessage, isSent: true);
    notifyListeners();
    _scrollToBottom();
    _socketService.emit('send-message', [otherUserId, message]);
  }

  void _setupSocketListeners() {
    _socketService.onConnected = () {
      _isConnected = true;
      _error = null;
      notifyListeners();
      if (_currentId != null) {
        _socketService.emit('init', [_currentId!]);
      }
    };

    _socketService.onDisconnected = () {
      _isConnected = false;
      _setError('Disconnected from chat server');
      if (!isDisposed) notifyListeners();
    };

    _socketService.onError = (error) => _setError('WebSocket error: $error');

    _socketService.on('chats', (data) => _handleChatsReceived(data));
    _socketService.on('messages', (data) => _handleMessageHistory(data));
    _socketService.on('receive-message', (data) => _handleSingleMessage(data));
  }

  void _handleChatsReceived(dynamic data) {
    try {
      List<ChatConversation> newConversations = [];

      if (data == null) {
        _conversations = [];
      } else if (data is String) {
        data = json.decode(data);
      }

      if (data is Map) {
        newConversations = data.entries.map((entry) {
          final userInfo = entry.value['user_info'] as Map;
          return ChatConversation(
            user: ChatUser(
              id: int.parse(entry.key),
              email: '',
              fullName: userInfo['full_name']?.toString() ?? '',
              picture: userInfo['picture']?.toString() ?? '',
            ),
            latestMessage: entry.value['latest_message']?.toString(),
            time: DateTime.now().toString(),
            hasNewMessages:
                entry.value['new_message']?.toString().isNotEmpty ?? false,
          );
        }).toList();
      } else if (data is List) {
        newConversations = (data).map((item) {
          final map = item as Map;
          final userInfo = map['user_info'] as Map? ?? {};
          return ChatConversation(
            user: ChatUser(
              id: int.parse(map['user_id']?.toString() ?? '0'),
              email: '',
              fullName: userInfo['full_name']?.toString() ?? '',
              picture: userInfo['picture']?.toString() ?? '',
            ),
            latestMessage: map['latest_message']?.toString(),
            time: map['time']?.toString() ?? DateTime.now().toString(),
            hasNewMessages: map['new_message']?.toString().isNotEmpty ?? false,
          );
        }).toList();
      } else {
        throw Exception('Unexpected data format: ${data.runtimeType}');
      }

      _conversations = newConversations;
      _initialFetchComplete = true;
      notifyListeners();
    } catch (e) {
      _setError('Error processing conversations: $e');
      _initialFetchComplete = true;
      notifyListeners();
    } finally {
      _setLoadingConversations(false);
    }
  }

  void _handleMessageHistory(dynamic data) {
    try {
      List<ChatMessage> newMessages = [];

      if (data is String) {
        data = json.decode(data);
      }

      if (data is Map<String, dynamic>) {
        newMessages = data.entries
            .map<ChatMessage>((e) => _createChatMessage(e.value))
            .toList();
      } else if (data is List) {
        newMessages =
            data.map<ChatMessage>((item) => _createChatMessage(item)).toList();
      } else {
        throw Exception(
            'Unexpected message history format: ${data.runtimeType}');
      }

      newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _messages = newMessages;
      notifyListeners();
    } catch (e) {
      _setError('Error processing message history: $e');
    } finally {
      _setLoadingMessages(false);
    }
  }

  void _handleSingleMessage(dynamic data) {
    try {
      final message = _createChatMessage(data);
      final senderId = message.userId;
      debugPrint('Received message from $senderId: ${message.message}');
      if (_currentChatUserId != null &&
          senderId != _currentId &&
          !_messages.any((m) =>
              m.timestamp == message.timestamp &&
              m.message == message.message)) {
        _messages.add(message);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      _updateConversation(senderId, message, isSent: false);
      debugPrint('Notifying listeners for new message from $senderId');
      notifyListeners();
    } catch (e) {
      _setError('Error processing message: $e');
    }
  }

  void _updateConversation(String userId, ChatMessage message,
      {required bool isSent}) {
    final index =
        _conversations.indexWhere((c) => c.user.id.toString() == userId);
    if (index != -1) {
      _conversations[index] = ChatConversation(
        user: _conversations[index].user,
        latestMessage: message.message,
        time: message.timestamp.toString(),
        hasNewMessages: !isSent ||
            _conversations[index]
                .hasNewMessages, // Set true for received, preserve for sent
      );
      debugPrint(
          'Updated conversation $userId: hasNewMessages = ${_conversations[index].hasNewMessages}');
    } else {
      _conversations.add(
        ChatConversation(
          user: ChatUser(
              id: int.parse(userId), email: '', fullName: '', picture: ''),
          latestMessage: message.message,
          time: message.timestamp.toString(),
          hasNewMessages: !isSent,
        ),
      );
      debugPrint('Added new conversation $userId: hasNewMessages = ${!isSent}');
    }
    _conversations.sort((a, b) => b.time!.compareTo(a.time!));
  }

  ChatMessage _createChatMessage(dynamic data) {
    final map = data is String ? json.decode(data) : data as Map;
    return ChatMessage(
      message: map['message']?.toString() ?? '',
      userId: map['from_user']?.toString() ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((map['time'] ?? DateTime.now().millisecondsSinceEpoch / 1000) * 1000)
            .toInt(),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _setLoadingConversations(bool value) {
    _isLoadingConversations = value;
    notifyListeners();
  }

  void _setLoadingMessages(bool value) {
    _isLoadingMessages = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  bool _disposed = false;
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    _scrollController.dispose();
    _socketService.disconnect();
    super.dispose();
  }
}
