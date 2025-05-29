import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Timer? _connectionTimeoutTimer;

  // Improved connection configuration
  static const String _serverUrl = 'ws://goodone.cfd:3000';
  static const int _connectionTimeout = 8000; // Reduced timeout
  static const int _maxReconnectAttempts = 3; // Reduced attempts
  static const int _reconnectDelay = 1500; // Faster reconnection
  static const int _heartbeatInterval = 25; // More frequent heartbeat

  // Connection state tracking
  int _reconnectAttempts = 0;
  DateTime? _lastConnectionAttempt;
  String? _lastError;

  // Event listeners management
  final Map<String, List<Function(dynamic)>> _eventListeners = {};
  bool _listenersRegistered = false;

  // Callbacks
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(String)? onError;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      debugPrint('WebSocket: Already connected or connecting');
      return;
    }

    _isConnecting = true;
    _lastConnectionAttempt = DateTime.now();
    _lastError = null;

    try {
      debugPrint('WebSocket: Attempting to connect to $_serverUrl');

      // Dispose previous socket if exists
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
      }

      _socket = io.io(
        _serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(_connectionTimeout)
            .setReconnectionAttempts(0) // Handle reconnection manually
            .setReconnectionDelay(_reconnectDelay)
            .disableAutoConnect() // Disable auto connect, we'll handle it manually
            .setExtraHeaders({'Connection': 'upgrade'}) // Force upgrade
            .build(),
      );

      // Connect manually
      _socket!.connect();

      _setupConnectionTimeout();
      _setupListeners();
    } catch (e) {
      _isConnecting = false;
      _lastError = 'Connection failed: $e';
      debugPrint('WebSocket: Connection failed: $e');
      onError?.call(_lastError!);
      rethrow;
    }
  }

  void _setupConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer =
        Timer(Duration(milliseconds: _connectionTimeout), () {
      if (_isConnecting && !_isConnected) {
        debugPrint('WebSocket: Connection timeout');
        _isConnecting = false;
        _lastError = 'Connection timeout';
        onError?.call(_lastError!);
        _scheduleReconnect();
      }
    });
  }

  Future<bool> waitForConnection({int timeoutSeconds = 8}) async {
    if (_isConnected) return true;

    final completer = Completer<bool>();
    Timer? timeoutTimer;
    Timer? checkTimer;

    // Set up timeout
    timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      checkTimer?.cancel();
      if (!completer.isCompleted) {
        debugPrint('WebSocket: Wait for connection timeout');
        completer.complete(false);
      }
    });

    // Check connection status more frequently
    checkTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isConnected) {
        timer.cancel();
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } else if (!_isConnecting && !_isConnected) {
        // Connection failed
        timer.cancel();
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    });

    return completer.future;
  }

  void emit(String event, List<dynamic> data) {
    if (_isConnected && _socket != null) {
      try {
        _socket!.emit(event, data);
        debugPrint('WebSocket: Emitted "$event" with data: $data');
      } catch (e) {
        debugPrint('WebSocket: Error emitting "$event": $e');
        _lastError = 'Failed to emit event: $e';
        onError?.call(_lastError!);
      }
    } else {
      debugPrint('WebSocket: Cannot emit "$event" - not connected');
      _lastError = 'Cannot emit event - not connected';
      onError?.call(_lastError!);
    }
  }

  void on(String event, void Function(dynamic) callback) {
    // Store callback for re-registration
    _eventListeners.putIfAbsent(event, () => []).add(callback);

    // Register with socket if available
    _socket?.on(event, (data) {
      debugPrint('WebSocket: Received event "$event"');
      callback(data);
    });
  }

  void off(String event) {
    _eventListeners.remove(event);
    _socket?.off(event);
  }

  void _setupListeners() {
    if (_socket == null || _listenersRegistered) return;

    _socket!.onConnect((_) {
      debugPrint('WebSocket: Connected successfully');
      _connectionTimeoutTimer?.cancel();
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _lastError = null;
      _stopReconnectTimer();
      _startHeartbeat();
      _reregisterEventListeners();
      onConnected?.call();
    });

    _socket!.onDisconnect((reason) {
      debugPrint('WebSocket: Disconnected - reason: $reason');
      _isConnected = false;
      _isConnecting = false;
      _stopHeartbeat();
      onDisconnected?.call();

      // Auto-reconnect for unexpected disconnections
      if (reason != 'io client disconnect' &&
          reason != 'client namespace disconnect') {
        _scheduleReconnect();
      }
    });

    _socket!.onError((error) {
      debugPrint('WebSocket: Socket error: $error');
      _isConnecting = false;
      _lastError = 'Socket error: $error';
      onError?.call(_lastError!);
    });

    _socket!.onConnectError((error) {
      debugPrint('WebSocket: Connect error: $error');
      _connectionTimeoutTimer?.cancel();
      _isConnecting = false;
      _lastError = 'Connect error: $error';
      onError?.call(_lastError!);
      _scheduleReconnect();
    });

    // Handle heartbeat response
    _socket!.on('heartbeat-response', (_) {
      debugPrint('WebSocket: Heartbeat acknowledged');
    });

    // Handle server-side ping
    _socket!.on('ping', (_) {
      debugPrint('WebSocket: Received ping, sending pong');
      _socket!.emit('pong', []);
    });

    _listenersRegistered = true;
  }

  void _reregisterEventListeners() {
    // Re-register all custom event listeners
    _eventListeners.forEach((event, callbacks) {
      for (final callback in callbacks) {
        _socket?.on(event, (data) {
          debugPrint('WebSocket: Received event "$event"');
          callback(data);
        });
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnection attempts reached');
      _lastError = 'Max reconnection attempts reached';
      onError?.call(_lastError!);
      return;
    }

    if (_reconnectTimer?.isActive == true) return;

    // Exponential backoff with jitter
    final baseDelay = _reconnectDelay * (_reconnectAttempts + 1);
    final jitter =
        (baseDelay * 0.1 * (DateTime.now().millisecond % 100) / 100).round();
    final delay = Duration(milliseconds: baseDelay + jitter);

    debugPrint(
        'WebSocket: Scheduling reconnect attempt ${_reconnectAttempts + 1} in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _reconnect();
    });
  }

  Future<void> _reconnect() async {
    if (_isConnected || _isConnecting) return;

    debugPrint(
        'WebSocket: Attempting to reconnect (attempt $_reconnectAttempts)');

    try {
      await connect();
    } catch (e) {
      debugPrint('WebSocket: Reconnection failed: $e');
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect();
      }
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatInterval),
      (_) => _sendHeartbeat(),
    );
    debugPrint(
        'WebSocket: Heartbeat started (${_heartbeatInterval}s interval)');
  }

  void _sendHeartbeat() {
    if (_isConnected && _socket != null) {
      try {
        _socket!.emit('heartbeat', [DateTime.now().millisecondsSinceEpoch]);
      } catch (e) {
        debugPrint('WebSocket: Heartbeat failed: $e');
        // Don't trigger error callback for heartbeat failures
      }
    }
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _stopConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
  }

  void disconnect() {
    debugPrint('WebSocket: Manually disconnecting');

    _stopHeartbeat();
    _stopReconnectTimer();
    _stopConnectionTimeout();

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _listenersRegistered = false;
    _lastError = null;
  }

  // Force reconnection with clean slate
  Future<void> forceReconnect() async {
    debugPrint('WebSocket: Force reconnecting');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 1000));
    await connect();
  }

  // Clear all event listeners
  void clearEventListeners() {
    _eventListeners.clear();
    _socket?.clearListeners();
  }

  // Get connection info
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'reconnectAttempts': _reconnectAttempts,
      'lastConnectionAttempt': _lastConnectionAttempt?.toIso8601String(),
      'lastError': _lastError,
      'serverUrl': _serverUrl,
      'eventListenersCount': _eventListeners.length,
    };
  }

  // Health check
  bool isHealthy() {
    return _isConnected &&
        _socket != null &&
        _socket!.connected &&
        _lastError == null;
  }

  // Reset connection state
  void resetConnectionState() {
    _reconnectAttempts = 0;
    _lastError = null;
    _lastConnectionAttempt = null;
  }
}
