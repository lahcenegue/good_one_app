import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  Timer? _heartbeatTimer;

  // Callbacks
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(String)? onError;
  final Map<String, void Function(dynamic)> _eventListeners = {};

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;
    try {
      _socket = io.io(
        'ws://162.254.35.98:3000',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(10000)
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .build(),
      );
      _setupListeners();
      _startHeartbeat();
    } catch (e) {
      onError?.call('Connection failed: $e');
    }
  }

  Future<bool> waitForConnection() async {
    const maxAttempts = 5;
    for (var i = 0; i < maxAttempts; i++) {
      if (_isConnected) return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  void emit(String event, List<dynamic> data) {
    if (_isConnected && _socket != null) {
      _socket!.emit(event, data);
    }
  }

  void on(String event, void Function(dynamic) callback) {
    _eventListeners[event] = callback;
    _socket?.on(event, callback);
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      onConnected?.call();
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      onDisconnected?.call();
    });

    _socket?.onError((error) => onError?.call('Socket error: $error'));

    _socket?.onConnectError((error) => onError?.call('Connect error: $error'));

    _eventListeners.forEach((event, callback) {
      _socket?.on(event, callback);
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isConnected) emit('heartbeat', []);
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _socket?.disconnect();
    _isConnected = false;
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

// class WebSocketService {
//   static final WebSocketService _instance = WebSocketService._internal();
//   factory WebSocketService() => _instance;

//   // Private constructor
//   WebSocketService._internal();

//   io.Socket? _socket;
//   bool _isConnected = false;
//   Timer? _heartbeatTimer;
//   int _reconnectAttempts = 0;
//   static const int maxReconnectAttempts = 5;

//   // Stream controllers
//   final _connectionStateController = StreamController<bool>.broadcast();
//   final _messageController = StreamController<Map<String, dynamic>>.broadcast();

//   // Getters
//   bool get isConnected => _isConnected;
//   Stream<bool> get connectionState => _connectionStateController.stream;
//   Stream<Map<String, dynamic>> get messages => _messageController.stream;

//   // Callback setters
//   Function()? onConnected;
//   Function()? onDisconnected;
//   Function(String error)? onError;
//   Function(Map<String, dynamic> data)? onMessageReceived;

//   Future<void> connect() async {
//     if (_isConnected) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();

//       _socket = io.io(
//         'ws://162.254.35.98:3000',
//         io.OptionBuilder()
//             .setTransports(['websocket'])
//             .enableForceNew()
//             .setTimeout(10000)
//             .setReconnectionAttempts(maxReconnectAttempts)
//             .setReconnectionDelay(2000)
//             .enableAutoConnect()
//             .enableReconnection()
//             .build(),
//       );

//       _setupSocketListeners();
//       _startHeartbeat();

//       // Restore queued messages from local storage
//       _restoreMessageQueue(prefs);
//     } catch (e) {
//       debugPrint('Socket connection error: $e');
//       _isConnected = false;
//       _connectionStateController.add(false);
//       if (onError != null) {
//         onError!(e.toString());
//       }
//     }
//   }

//   void _setupSocketListeners() {
//     _socket?.onConnect((_) {
//       debugPrint('Socket connected');
//       _isConnected = true;
//       _reconnectAttempts = 0;
//       _connectionStateController.add(true);
//       if (onConnected != null) {
//         onConnected!();
//       }
//     });

//     _socket?.onDisconnect((_) {
//       debugPrint('Socket disconnected');
//       _handleDisconnect();
//     });

//     _socket?.onError((error) {
//       debugPrint('Socket error: $error');
//       _handleError(error);
//     });

//     _socket?.onConnectError((error) {
//       debugPrint('Socket connection error: $error');
//       _handleError(error);
//     });

//     _socket?.on('chats', (data) {
//       debugPrint('Received chats event: $data');
//       try {
//         final parsedData = data is String ? json.decode(data) : data;
//         if (onMessageReceived != null) {
//           onMessageReceived!(parsedData);
//         }
//       } catch (e) {
//         debugPrint('Error processing chats data: $e');
//       }
//     });

//     _socket?.on('messages', (data) {
//       debugPrint('Received messages event: $data');
//       if (data != null && onMessageReceived != null) {
//         final messageData = data is String ? json.decode(data) : data;
//         onMessageReceived!(messageData);
//       }
//     });

//     _socket?.on('receive-message', (data) {
//       debugPrint('Received new message event: $data');
//       if (data != null && onMessageReceived != null) {
//         final messageData = data is String ? json.decode(data) : data;
//         onMessageReceived!(messageData);
//       }
//     });

//     _socket?.on('get-messages', (data) {
//       debugPrint('Received old messages: $data');
//       if (data is Map<String, dynamic>) {
//         if (onMessageReceived != null) {
//           onMessageReceived!(data);
//         }
//       }
//     });

//     _socket?.on('new-message', (data) {
//       debugPrint('Received new-message event: $data');
//       if (onMessageReceived != null) {
//         onMessageReceived!(data);
//       }
//     });
//   }

//   void _handleDisconnect() {
//     _isConnected = false;
//     _connectionStateController.add(false);
//     if (onDisconnected != null) {
//       onDisconnected!();
//     }

//     if (_reconnectAttempts < maxReconnectAttempts) {
//       _reconnectAttempts++;
//       _attemptReconnect();
//     }
//   }

//   void _handleError(dynamic error) {
//     _isConnected = false;
//     _connectionStateController.add(false);
//     if (onError != null) {
//       onError!(error.toString());
//     }
//   }

//   Future<void> _attemptReconnect() async {
//     if (!_isConnected && _reconnectAttempts < maxReconnectAttempts) {
//       debugPrint('Attempting reconnection: Attempt $_reconnectAttempts');
//       await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
//       connect();
//     }
//   }

//   void _startHeartbeat() {
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (_isConnected) {
//         _socket?.emit('heartbeat');
//       }
//     });
//   }

//   void emit(String event, List<dynamic> data) {
//     if (!_isConnected || _socket == null) {
//       debugPrint('Socket not connected, cannot emit event: $event');
//       return;
//     }

//     try {
//       debugPrint('Emitting event: $event, data: $data');
//       _socket!.emit(event, data);
//     } catch (e) {
//       debugPrint('Error emitting event: $e');
//     }
//   }

//   void on(String event, Function(dynamic) callback) {
//     _socket?.on(event, (data) {
//       debugPrint('Received event: $event, data: $data');
//       _messageController.add({
//         'event': event,
//         'data': data,
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//       callback(data);
//     });
//   }

//   void off(String event) {
//     _socket?.off(event);
//   }

//   Future<void> disconnect() async {
//     debugPrint('Disconnecting socket');
//     _heartbeatTimer?.cancel();
//     await _connectionStateController.close();
//     await _messageController.close();
//     _socket?.disconnect();
//     _socket?.disconnect();
//     _socket = null;
//     _isConnected = false;
//   }

//   Future<bool> waitForConnection() async {
//     int attempts = 0;
//     const maxAttempts = 5;

//     while (attempts < maxAttempts) {
//       if (_socket?.connected == true) {
//         _isConnected = true;
//         _connectionStateController.add(true);
//         if (onConnected != null) {
//           onConnected!();
//         }
//         return true;
//       }
//       await Future.delayed(const Duration(seconds: 1));
//       attempts++;
//       debugPrint('Connection attempt $attempts of $maxAttempts');
//     }

//     return false;
//   }

//   void _restoreMessageQueue(SharedPreferences prefs) {
//     // Implement restoration logic if needed
//   }
// }
