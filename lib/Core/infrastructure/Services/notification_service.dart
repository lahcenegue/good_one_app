import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:good_one_app/Core/infrastructure/Services/token_manager.dart';

/// Enhanced NotificationService that works with the refactored TokenManager
class NotificationService {
  // Singleton pattern
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;

  // Constants
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  // Private fields
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Callback functions for custom handling
  void Function(RemoteMessage)? onMessageReceived;
  void Function(RemoteMessage)? onMessageOpenedApp;

  /// Initialize the notification service
  Future<void> initialize({
    void Function(RemoteMessage)? onMessageReceived,
    void Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_isInitialized) return;

    try {
      // Set custom callbacks
      this.onMessageReceived = onMessageReceived;
      this.onMessageOpenedApp = onMessageOpenedApp;

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Setup local notifications
      await _setupLocalNotifications();

      // Setup message handlers
      await _setupMessageHandlers();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
      // Don't rethrow - app should continue even if notifications fail
    }
  }

  /// Setup local notifications with Android channel and iOS settings
  Future<void> _setupLocalNotifications() async {
    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Setup Firebase message handlers
  Future<void> _setupMessageHandlers() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Received foreground message: ${message.messageId}');
      showNotification(message);
      onMessageReceived?.call(message);
    });

    // Background message opened app
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message opened app from background: ${message.messageId}');
      _handleBackgroundMessage(message);
      onMessageOpenedApp?.call(message);
    });

    // Check for initial message when app was terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          'App opened from terminated state via notification: ${initialMessage.messageId}');
      // Delay handling to ensure app is fully initialized
      Future.delayed(const Duration(seconds: 1), () {
        _handleBackgroundMessage(initialMessage);
        onMessageOpenedApp?.call(initialMessage);
      });
    }
  }

  /// Show local notification for foreground messages
  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: _createPayload(message),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      _handleNotificationNavigation(response.payload!);
    }
  }

  /// Handle background message and navigation
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Handling background message: ${message.messageId}');

    final payload = _createPayload(message);

    _handleNotificationNavigation(payload);
  }

  /// Handle notification-based navigation
  void _handleNotificationNavigation(String payload) {
    try {
      // Parse payload and handle navigation
      // You can customize this based on your app's navigation structure

      if (payload.contains('chat')) {
        debugPrint('Navigating to chat from notification');
        // Add your chat navigation logic here
      } else if (payload.contains('order')) {
        debugPrint('Navigating to order from notification');
        // Add your order navigation logic here
      } else if (payload.contains('booking')) {
        debugPrint('Navigating to booking from notification');
        // Add your booking navigation logic here
      }

      // You can extend this with more navigation cases
    } catch (e) {
      debugPrint('Error handling notification navigation: $e');
    }
  }

  /// Create payload from message data
  String _createPayload(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return 'general';

    // Create a simple payload string
    final type = data['type'] ?? 'general';
    final id = data['id'] ?? '';

    return '${type}_$id';
  }

  /// Get FCM token from TokenManager
  Future<String> getDeviceToken() async {
    return await TokenManager.instance.getDeviceToken();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await TokenManager.instance.hasNotificationPermissions();
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    return await TokenManager.instance.requestNotificationPermissions();
  }

  /// Get notification status for debugging
  String get notificationStatus {
    return TokenManager.instance.notificationStatus.description;
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');

  // Initialize minimal services needed for background processing
  // Note: This runs in a separate isolate, so you can't access app state

  // You can show notifications here if needed, but usually
  // the system handles this automatically for background messages
}
