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
