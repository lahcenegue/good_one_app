import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
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
    }
  }

  Future<void> _setupLocalNotifications() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();

    await _localNotifications.initialize(
      InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (details) =>
          debugPrint('Notification tapped: ${details.payload}'),
    );
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) _handleBackgroundMessage(initialMessage);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Handling background message: ${message.messageId}');
    if (message.data['type'] == 'chat') {
      // TODO: Handle chat-specific navigation
    }
  }

  // Get FCM token from TokenManager
  String? get fcmToken => TokenManager.instance.fcmToken;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // You can show notifications here if needed
}
