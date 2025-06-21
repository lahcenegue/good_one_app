import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Infrastructure/Websocket/websocket_service.dart';
import 'package:good_one_app/Features/Chat/Models/chat_conversation.dart';
import 'package:good_one_app/Features/Chat/Models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final WebSocketService _socketService;
  final ScrollController _scrollController = ScrollController();

  // Cache for better performance
  final Map<String, List<ChatMessage>> _messagesCache = {};

  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isConnected = false;
  bool _initialFetchComplete = false;
  String? _error;
  String? _currentChatUserId;
  String? _currentId;

  // Event listener management
  bool _listenersSetup = false;
  final Set<String> _activeRooms = {};

  // Simple timeout management
  Timer? _conversationsTimeout;
  Timer? _messagesTimeout;

  static const int _timeoutSeconds = 10;
  static const int _maxRetries = 2;

  ChatProvider({WebSocketService? socketService})
      : _socketService = socketService ?? WebSocketService();

  // Getters
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

  /// Getter for unread message count
  int get unreadMessageCount {
    try {
      return _conversations
          .where((conversation) => conversation.hasNewMessages)
          .length;
    } catch (e) {
      debugPrint('ChatProvider: Error calculating unread count: $e');
      return 0;
    }
  }

  Future<void> initialize(String id) async {
    debugPrint('ChatProvider: Initialize called with user ID: $id');
    debugPrint('ChatProvider: Current user ID: $_currentId');

    // ALWAYS clear state when user changes OR when initializing for the first time
    if (_currentId != id || !_initialFetchComplete) {
      debugPrint(
          'ChatProvider: User changed or first initialization - clearing all data');
      _currentId = id;
      _clearAllStateCompletely(); // Use new comprehensive clearing method
      _clearError();
    } else if (_currentId == id && _initialFetchComplete && _isConnected) {
      debugPrint(
          'ChatProvider: Already initialized for user $id and connected');
      return;
    }

    debugPrint('ChatProvider: Initializing chat for user ID: $id');
    _currentId = id;

    try {
      // Force disconnect and reconnect to ensure clean state
      if (_isConnected) {
        debugPrint('ChatProvider: Force disconnecting existing connection');
        _socketService.disconnect();
        _isConnected = false;
        await Future.delayed(const Duration(milliseconds: 500)); // Brief delay
      }

      // Setup listeners only once
      if (!_listenersSetup) {
        _setupSocketListeners();
        _listenersSetup = true;
      }

      await _connectWithRetry();

      if (_isConnected) {
        debugPrint('ChatProvider: Emitting init event for user: $id');
        _socketService.emit('init', [id]);

        await Future.delayed(const Duration(milliseconds: 500));
        await _loadConversations();
      } else {
        setError('Failed to establish connection');
      }
    } catch (e) {
      debugPrint('ChatProvider: Initialization error: $e');
      setError('Initialization failed: $e');
    } finally {
      _initialFetchComplete = true;
      _setLoadingConversations(false);
      notifyListeners();
    }
  }

  Future<void> switchUser(String newUserId) async {
    debugPrint('ChatProvider: Switching user from $_currentId to $newUserId');

    // Force disconnect and clear everything
    _socketService.disconnect();
    _isConnected = false;
    _listenersSetup = false; // Reset listeners setup flag

    // Complete state clear
    _clearAllStateCompletely();

    // Small delay to ensure clean disconnect
    await Future.delayed(const Duration(milliseconds: 500));

    // Reinitialize with new user
    await initialize(newUserId);
  }

  Future<void> _connectWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('ChatProvider: Connection attempt $attempt');

        await _socketService.connect();
        _isConnected =
            await _socketService.waitForConnection(timeoutSeconds: 8);

        if (_isConnected) {
          debugPrint('ChatProvider: Connected successfully');
          return;
        }

        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        debugPrint('ChatProvider: Connection attempt $attempt failed: $e');
        if (attempt == _maxRetries) rethrow;
      }
    }
  }

  Future<void> _loadConversations() async {
    _setLoadingConversations(true);

    try {
      // Set timeout
      _conversationsTimeout = Timer(Duration(seconds: _timeoutSeconds), () {
        if (_isLoadingConversations) {
          setError('Loading conversations timed out');
          _setLoadingConversations(false);
        }
      });

      // Request conversations
      _socketService.emit('get-chats', []);
      debugPrint('ChatProvider: Requested conversations');
    } catch (e) {
      setError('Failed to request conversations: $e');
      _setLoadingConversations(false);
    }
  }

  Future<void> initializeConversations() async {
    await _loadConversations();
  }

  Future<void> initializeChat(String otherUserId) async {
    if (_currentChatUserId == otherUserId && _messages.isNotEmpty) {
      debugPrint('ChatProvider: Chat already loaded for user $otherUserId');
      return;
    }

    _currentChatUserId = otherUserId;
    _setLoadingMessages(true);
    _clearError();

    try {
      // Check cache first
      if (_messagesCache.containsKey(otherUserId)) {
        _messages = List.from(_messagesCache[otherUserId]!);
        _setLoadingMessages(false);
        _scrollToBottom();
        notifyListeners();
        debugPrint('ChatProvider: Loaded messages from cache');
        return;
      }

      // Set timeout
      _messagesTimeout = Timer(Duration(seconds: _timeoutSeconds), () {
        if (_isLoadingMessages) {
          setError('Loading messages timed out');
          _setLoadingMessages(false);
        }
      });

      // Leave previous room
      if (_activeRooms.isNotEmpty) {
        for (final roomId in _activeRooms) {
          _socketService.emit('leave-room', [roomId]);
        }
        _activeRooms.clear();
      }

      // Join new room and request messages
      _socketService.emit('join-room', [otherUserId]);
      _activeRooms.add(otherUserId);
      _socketService.emit('get-messages', [otherUserId, 0]);

      debugPrint('ChatProvider: Requested messages for user $otherUserId');

      // Reset new message indicator
      _resetNewMessageIndicator(otherUserId);
    } catch (e) {
      setError('Failed to load chat: $e');
      _setLoadingMessages(false);
    }
  }

  void sendMessage(String message, String otherUserId) {
    if (!_isConnected || message.trim().isEmpty) return;

    final chatMessage = ChatMessage(
      message: message.trim(),
      userId: _currentId!,
      timestamp: DateTime.now(),
    );

    // Add message optimistically
    _messages.add(chatMessage);
    _updateMessagesCache(otherUserId, chatMessage);
    _updateConversationOptimistically(otherUserId, chatMessage);

    notifyListeners();
    _scrollToBottom();

    // Send to server
    _socketService.emit('send-message', [otherUserId, message.trim()]);
  }

  void _setupSocketListeners() {
    // Connection handlers
    _socketService.onConnected = () {
      _isConnected = true;
      _clearError();
      debugPrint('ChatProvider: WebSocket connected');
      notifyListeners();
    };

    _socketService.onDisconnected = () {
      _isConnected = false;
      setError('Disconnected from server');
      if (!isDisposed) notifyListeners();
    };

    _socketService.onError = (error) {
      setError('Connection error: $error');
    };

    // Data handlers
    _socketService.on('chats', _handleChatsReceived);
    _socketService.on('messages', _handleMessagesReceived);
    _socketService.on('receive-message', _handleNewMessage);
  }

  void _handleChatsReceived(dynamic data) {
    try {
      debugPrint('ChatProvider: Raw chats data received: $data');
      debugPrint('ChatProvider: Data type: ${data.runtimeType}');

      _conversationsTimeout?.cancel();

      final conversations = _parseConversationsFromData(data);
      _conversations = conversations;
      _setLoadingConversations(false);

      debugPrint(
          'ChatProvider: Successfully loaded ${conversations.length} conversations');
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error handling chats: $e');
      setError('Failed to process conversations: $e');
      _setLoadingConversations(false);
    }
  }

  void _handleMessagesReceived(dynamic data) {
    try {
      debugPrint('ChatProvider: Raw messages data received: $data');
      debugPrint('ChatProvider: Data type: ${data.runtimeType}');

      _messagesTimeout?.cancel();

      final messages = _parseMessagesFromData(data);
      _messages = messages;

      if (_currentChatUserId != null) {
        _messagesCache[_currentChatUserId!] = List.from(messages);
      }

      _setLoadingMessages(false);

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      debugPrint(
          'ChatProvider: Successfully loaded ${messages.length} messages');
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error handling messages: $e');
      setError('Failed to process messages: $e');
      _setLoadingMessages(false);
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      final message = _parseMessageFromData(data);
      final senderId = message.userId;

      debugPrint('ChatProvider: Received new message from $senderId');

      // Add to current chat if applicable
      if (_currentChatUserId == senderId && !_isDuplicateMessage(message)) {
        _messages.add(message);
        _updateMessagesCache(senderId, message);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }

      // Update conversation
      _updateConversationFromMessage(senderId, message);
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error handling new message: $e');
    }
  }

  /// Refreshes only conversation counts for badge updates
  Future<void> refreshConversationCounts() async {
    if (!_isConnected || _currentId == null) return;

    try {
      debugPrint('ChatProvider: Refreshing conversation counts...');
      _socketService.emit('get-chats', []);
    } catch (e) {
      debugPrint('ChatProvider: Error refreshing conversation counts: $e');
    }
  }

  // Efficient data parsing methods - Fixed to match server response format
  List<ChatConversation> _parseConversationsFromData(dynamic data) {
    debugPrint('ChatProvider: Parsing conversations data: $data');

    if (data == null) {
      debugPrint('ChatProvider: Data is null, returning empty list');
      return [];
    }

    final List<ChatConversation> conversations = [];

    try {
      // Handle string response (JSON string)
      if (data is String) {
        debugPrint('ChatProvider: Converting string data to JSON');
        data = json.decode(data);
      }

      // The server sends data as a Map where keys are user IDs
      if (data is Map<String, dynamic>) {
        debugPrint(
            'ChatProvider: Processing Map data with ${data.length} entries');

        for (final entry in data.entries) {
          try {
            final userId = entry.key;
            final conversationData = entry.value as Map<String, dynamic>;
            final userInfo =
                conversationData['user_info'] as Map<String, dynamic>? ?? {};

            debugPrint(
                'ChatProvider: Processing conversation for user $userId');

            final conversation = ChatConversation(
              user: ChatUser(
                id: int.tryParse(userId) ?? 0,
                email: '',
                fullName: userInfo['full_name']?.toString() ?? 'Unknown User',
                picture: userInfo['picture']?.toString() ?? '',
              ),
              latestMessage: conversationData['latest_message']?.toString(),
              time: DateTime.now().toIso8601String(),
              hasNewMessages:
                  _parseNewMessageFlag(conversationData['new_message']),
            );

            conversations.add(conversation);
            debugPrint(
                'ChatProvider: Added conversation for ${conversation.user.fullName}');
          } catch (e) {
            debugPrint(
                'ChatProvider: Error parsing individual conversation: $e');
          }
        }
      } else {
        debugPrint('ChatProvider: Unexpected data type: ${data.runtimeType}');
      }
    } catch (e) {
      debugPrint('ChatProvider: Error parsing conversations: $e');
    }

    // Sort by time (most recent first)
    conversations.sort((a, b) => (b.time ?? '').compareTo(a.time ?? ''));
    debugPrint('ChatProvider: Returning ${conversations.length} conversations');
    return conversations;
  }

  List<ChatMessage> _parseMessagesFromData(dynamic data) {
    debugPrint('ChatProvider: Parsing messages data: $data');

    if (data == null) {
      debugPrint('ChatProvider: Messages data is null, returning empty list');
      return [];
    }

    final List<ChatMessage> messages = [];

    try {
      // Handle string response (JSON string)
      if (data is String) {
        debugPrint('ChatProvider: Converting string messages data to JSON');
        data = json.decode(data);
      }

      // The server sends messages as a Map where keys are message IDs
      if (data is Map<String, dynamic>) {
        debugPrint(
            'ChatProvider: Processing messages Map data with ${data.length} entries');

        for (final entry in data.entries) {
          try {
            final messageId = entry.key;
            final messageData = entry.value as Map<String, dynamic>;

            debugPrint(
                'ChatProvider: Processing message $messageId: $messageData');

            final message = ChatMessage(
              message: messageData['message']?.toString() ?? '',
              userId: messageData['from_user']?.toString() ?? '',
              timestamp: _parseTimestamp(messageData['time']),
            );

            messages.add(message);
            debugPrint(
                'ChatProvider: Added message from user ${message.userId}: ${message.message}');
          } catch (e) {
            debugPrint('ChatProvider: Error parsing individual message: $e');
          }
        }
      } else {
        debugPrint(
            'ChatProvider: Unexpected messages data type: ${data.runtimeType}');
      }
    } catch (e) {
      debugPrint('ChatProvider: Error parsing messages: $e');
    }

    // Sort by timestamp (oldest first for chat display)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    debugPrint('ChatProvider: Returning ${messages.length} messages');
    return messages;
  }

  ChatMessage _parseMessageFromData(dynamic data) {
    final map =
        data is String ? json.decode(data) : data as Map<String, dynamic>;

    return ChatMessage(
      message: map['message']?.toString() ?? '',
      userId: map['from_user']?.toString() ?? map['userId']?.toString() ?? '',
      timestamp: _parseTimestamp(map['time'] ?? map['timestamp']),
    );
  }

  DateTime _parseTimestamp(dynamic timeValue) {
    if (timeValue == null) return DateTime.now();

    try {
      if (timeValue is String) {
        return DateTime.parse(timeValue);
      } else if (timeValue is num) {
        // Server sends Unix timestamp in seconds, convert to milliseconds
        final milliseconds = timeValue < 1000000000000
            ? (timeValue * 1000).toInt()
            : timeValue.toInt();
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    } catch (e) {
      debugPrint('ChatProvider: Error parsing timestamp $timeValue: $e');
    }
    return DateTime.now();
  }

  bool _parseNewMessageFlag(dynamic flag) {
    if (flag is bool) return flag;
    if (flag is String) return flag.isNotEmpty;
    if (flag is num) return flag > 0;
    return false;
  }

  // Helper methods (same as before but simplified)
  void _updateMessagesCache(String userId, ChatMessage message) {
    _messagesCache.putIfAbsent(userId, () => []).add(message);
  }

  void _updateConversationOptimistically(String userId, ChatMessage message) {
    final index =
        _conversations.indexWhere((c) => c.user.id.toString() == userId);

    if (index != -1) {
      _conversations[index] = ChatConversation(
        user: _conversations[index].user,
        latestMessage: message.message,
        time: message.timestamp.toIso8601String(),
        hasNewMessages: false,
      );
    }

    _conversations.sort((a, b) => (b.time ?? '').compareTo(a.time ?? ''));
  }

  void _updateConversationFromMessage(
    String userId,
    ChatMessage message,
  ) {
    final index =
        _conversations.indexWhere((c) => c.user.id.toString() == userId);

    bool hasNewMessages = _currentChatUserId != userId;

    if (index != -1) {
      _conversations[index] = ChatConversation(
        user: _conversations[index].user,
        latestMessage: message.message,
        time: message.timestamp.toIso8601String(),
        hasNewMessages: hasNewMessages,
      );
    } else {
      _conversations.add(
        ChatConversation(
          user: ChatUser(
            id: int.tryParse(userId) ?? 0,
            email: '',
            fullName: 'Unknown User',
            picture: '',
          ),
          latestMessage: message.message,
          time: message.timestamp.toIso8601String(),
          hasNewMessages: true,
        ),
      );
    }

    _conversations.sort((a, b) => (b.time ?? '').compareTo(a.time ?? ''));

    notifyListeners();
  }

  void _resetNewMessageIndicator(String otherUserId) {
    final index =
        _conversations.indexWhere((c) => c.user.id.toString() == otherUserId);
    if (index != -1) {
      _conversations[index] = ChatConversation(
        user: _conversations[index].user,
        latestMessage: _conversations[index].latestMessage,
        time: _conversations[index].time,
        hasNewMessages: false,
      );
    }
  }

  bool _isDuplicateMessage(ChatMessage newMessage) {
    return _messages.any((m) =>
        m.timestamp.isAtSameMomentAs(newMessage.timestamp) &&
        m.message == newMessage.message &&
        m.userId == newMessage.userId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // Add this method to your ChatProvider class
  void disconnect() {
    debugPrint('ChatProvider: Manually disconnecting and clearing all state');

    // Disconnect the socket
    _socketService.disconnect();

    // Clear all state completely
    _clearAllStateCompletely();

    // Reset connection flags
    _isConnected = false;
    _listenersSetup = false;

    // Reset current user
    _currentId = null;

    notifyListeners();
  }

  // State management helpers
  void _clearAllStateCompletely() {
    debugPrint('ChatProvider: Performing complete state clear');

    // Clear all collections
    _messages.clear();
    _conversations.clear();
    _messagesCache.clear();
    _activeRooms.clear();

    // Reset all flags
    _initialFetchComplete = false;
    _isLoadingConversations = false;
    _isLoadingMessages = false;
    _currentChatUserId = null;

    // Cancel all timers
    _conversationsTimeout?.cancel();
    _messagesTimeout?.cancel();

    // Clear error state
    _error = null;

    debugPrint('ChatProvider: Complete state clear finished');
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _setLoadingConversations(bool value) {
    if (_isLoadingConversations != value) {
      _isLoadingConversations = value;
      notifyListeners();
    }
  }

  void _setLoadingMessages(bool value) {
    if (_isLoadingMessages != value) {
      _isLoadingMessages = value;
      notifyListeners();
    }
  }

  // Public retry methods
  Future<void> retryInitialization() async {
    if (_currentId != null) {
      await initialize(_currentId!);
    }
  }

  Future<void> retryLoadMessages() async {
    if (_currentChatUserId != null) {
      _messagesCache.remove(_currentChatUserId!);
      await initializeChat(_currentChatUserId!);
    }
  }

  // Dispose
  bool _disposed = false;
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    _conversationsTimeout?.cancel();
    _messagesTimeout?.cancel();
    _scrollController.dispose();
    _socketService.disconnect();
    super.dispose();
  }
}
