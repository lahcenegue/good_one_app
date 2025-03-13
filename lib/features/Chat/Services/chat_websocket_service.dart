import 'package:flutter/material.dart';

import '../../../Core/infrastructure/websocket/websocket_service.dart';

class ChatWebSocketService {
  final WebSocketService _socket = WebSocketService();
  final String _userId;
  final Function(Map<String, dynamic>) onMessageReceived;
  final Function(Map<String, dynamic>) onNewMessage;
  final Function(List<dynamic>) onMessagesLoaded;
  final Function() onConnected;
  final Function(String) onError;

  ChatWebSocketService({
    required String userId,
    required this.onMessageReceived,
    required this.onNewMessage,
    required this.onMessagesLoaded,
    required this.onConnected,
    required this.onError,
  }) : _userId = userId {
    _connectToServer();
  }

  void _connectToServer() {
    try {
      // Connect to Socket.IO server
      _socket.connect();

      // Set up event listeners
      _setupSocketListeners();

      // Initialize user by sending 'init' event with userId in an array
      _initializeUser();
    } catch (e) {
      onError('Connection error: ${e.toString()}');
    }
  }

  void _initializeUser() {
    debugPrint('Initializing user: $_userId');
    _socket.emit('init', [_userId]); // Sending userId in an array
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      debugPrint('Connected to chat server');
      onConnected();
    });

    _socket.on('receive-message', (data) {
      debugPrint('Received new message: $data');
      if (data is Map<String, dynamic>) {
        onMessageReceived(data);
      }
    });

    _socket.on('new-message', (data) {
      debugPrint('Received new message from other chat: $data');
      if (data is Map<String, dynamic>) {
        onNewMessage(data);
      }
    });

    _socket.on('get-messages', (data) {
      debugPrint('Received messages: $data');
      if (data is List) {
        onMessagesLoaded(data);
      } else {
        onError('Unexpected messages format: ${data.runtimeType}');
      }
    });

    _socket.on('connect_error', (error) {
      onError('Connection error: $error');
    });

    _socket.on('disconnect', (_) {
      onError('Connection closed');
    });
  }

  void joinRoom(String otherUserId) {
    debugPrint('Joining room with user: $otherUserId');
    _socket.emit('join-room', [otherUserId]); // Sending otherUserId in an array
  }

  void getMessages(String otherUserId, {int startFrom = 0}) {
    debugPrint('Requesting messages with user: $otherUserId, from: $startFrom');
    _socket.emit('get-messages',
        [otherUserId, startFrom]); // Sending both IDs in an array
  }

  void sendMessage(String message, String otherUserId) {
    if (!_socket.isConnected) {
      onError('Cannot send message: Not connected');
      return;
    }

    debugPrint('Sending message to user: $otherUserId');
    _socket.emit('send-message',
        [otherUserId, message]); // Sending otherUserId and message in an array
  }

  void leaveRoom(String otherUserId) {
    if (_socket.isConnected) {
      debugPrint('Leaving room with user: $otherUserId');
      _socket
          .emit('leave-room', [otherUserId]); // Sending otherUserId in an array
    }
  }

  void disconnect() {
    _socket.disconnect();
  }
}
