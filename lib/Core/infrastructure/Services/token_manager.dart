import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Services/auth_api.dart';

/// Professional TokenManager following modern Flutter/Dart practices
///
/// Responsibilities:
/// - Authentication token management
/// - FCM token management with fallback strategies
/// - Token refresh and persistence
/// - Cross-platform notification handling
class TokenManager {
  TokenManager._();
  static final TokenManager _instance = TokenManager._();
  static TokenManager get instance => _instance;

  // Constants
  static const Duration _tokenRefreshDelay = Duration(seconds: 1);
  static const Duration _apnsRetryDelay = Duration(seconds: 2);
  static const String _authDataKey = 'authData';
  static const String _apnsTokenKey = 'apns_token';

  // Private fields
  AuthModel? _currentAuth;
  String? _fcmToken;
  String? _apnsToken;
  bool _isInitialized = false;
  bool _isRefreshing = false;
  late final StreamController<AuthModel?> _authStreamController;
  late final FirebaseMessaging _firebaseMessaging;

  // Public getters
  AuthModel? get currentAuth => _currentAuth;
  Stream<AuthModel?> get authStream => _authStreamController.stream;
  Stream<AuthModel?> get tokenStream =>
      _authStreamController.stream; // Alias for compatibility
  String? get accessToken => _currentAuth?.accessToken;
  String? get fcmToken => _fcmToken;
  String? get apnsToken => _apnsToken;
  bool get hasValidAuth => _currentAuth != null;
  bool get isInitialized => _isInitialized;

  /// Initialize the TokenManager
  /// Should be called once during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    _authStreamController = StreamController<AuthModel?>.broadcast();
    _firebaseMessaging = FirebaseMessaging.instance;

    try {
      await StorageManager.init();
      await _initializeAuthTokens();
      await _initializeFirebaseMessaging();
      _setupTokenRefreshListener();
      _isInitialized = true;

      if (kDebugMode) {
        _logInitializationStatus();
      }
    } catch (e) {
      debugPrint('TokenManager initialization failed: $e');
      rethrow;
    }
  }

  /// Get a guaranteed device token for API calls
  /// This method never returns null and handles all edge cases
  Future<String> getDeviceToken() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Return existing FCM token if available
      if (_fcmToken?.isNotEmpty == true) {
        return _fcmToken!;
      }

      // Try to get stored token
      final storedToken =
          await StorageManager.getString(StorageKeys.fcmTokenKey);
      if (storedToken?.isNotEmpty == true) {
        _fcmToken = storedToken;
        return storedToken!;
      }

      // Generate new token
      final newToken = await _generateDeviceToken();
      await _persistFcmToken(newToken);
      return newToken;
    } catch (e) {
      debugPrint('Error getting device token: $e');
      // Emergency fallback
      final emergencyToken = _createEmergencyToken();
      await _persistFcmToken(emergencyToken);
      return emergencyToken;
    }
  }

  /// Check if user has notification permissions
  Future<bool> hasNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return _isPermissionGranted(settings.authorizationStatus);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Request notification permissions and attempt to get real FCM token
  Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (_isPermissionGranted(settings.authorizationStatus)) {
        final token = await _firebaseMessaging.getToken();
        if (token?.isNotEmpty == true) {
          _fcmToken = token;
          await _persistFcmToken(token!);
          debugPrint('Real FCM token obtained after permission grant');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Request notification permissions and attempt to get real FCM token
  /// Alias for compatibility with AuthProvider
  Future<bool> requestPermissionsAndRetryToken() async {
    return await requestNotificationPermissions();
  }

  /// Refresh authentication token
  Future<bool> refreshAuthToken() async {
    if (_isRefreshing || _currentAuth?.accessToken == null) {
      return false;
    }

    try {
      _isRefreshing = true;
      final response = await AuthApi.refreshToken(
        token: _currentAuth!.accessToken,
      );

      if (response.success && response.data != null) {
        await setAuthToken(response.data!);
        return true;
      } else {
        await clearAuthToken();
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await clearAuthToken();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Set authentication token
  Future<void> setAuthToken(AuthModel authModel) async {
    _currentAuth = authModel;
    _authStreamController.add(authModel);
    await Future.wait([
      StorageManager.setString(StorageKeys.tokenKey, authModel.accessToken),
      StorageManager.setString(_authDataKey, jsonEncode(authModel.toJson())),
    ]);
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    _currentAuth = null;
    _authStreamController.add(null);
    await Future.wait([
      StorageManager.remove(StorageKeys.tokenKey),
      StorageManager.remove(_authDataKey),
    ]);
  }

  /// Get notification status for debugging
  NotificationStatus get notificationStatus {
    if (_fcmToken == null) return NotificationStatus.notConfigured;
    if (_fcmToken!.startsWith('fallback_') ||
        _fcmToken!.startsWith('emergency_')) {
      return NotificationStatus.fallback;
    }
    if (Platform.isIOS && _apnsToken == null) {
      return NotificationStatus.simulator;
    }
    return NotificationStatus.ready;
  }

  /// Dispose resources
  void dispose() {
    _authStreamController.close();
  }

  // Private methods
  Future<void> _initializeAuthTokens() async {
    try {
      final authData = await StorageManager.getString(_authDataKey);
      if (authData != null) {
        _currentAuth = AuthModel.fromJson(jsonDecode(authData));
        _authStreamController.add(_currentAuth);
      }
    } catch (e) {
      debugPrint('Auth token initialization error: $e');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      await _requestFirebasePermissions();
      if (Platform.isIOS) {
        await _initializeApnsToken();
      }
      await _initializeFcmToken();
    } catch (e) {
      debugPrint('Firebase messaging initialization error: $e');
      // Don't rethrow - app should continue without push notifications
    }
  }

  Future<void> _requestFirebasePermissions() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('Error requesting Firebase permissions: $e');
    }
  }

  Future<void> _initializeApnsToken() async {
    try {
      await Future.delayed(_tokenRefreshDelay);
      _apnsToken = await _firebaseMessaging.getAPNSToken();
      if (_apnsToken == null) {
        // Retry once
        await Future.delayed(_apnsRetryDelay);
        _apnsToken = await _firebaseMessaging.getAPNSToken();
      }
      if (_apnsToken != null) {
        await StorageManager.setString(_apnsTokenKey, _apnsToken!);
      }
    } catch (e) {
      debugPrint('APNS token initialization error: $e');
    }
  }

  Future<void> _initializeFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken?.isNotEmpty == true) {
        await _persistFcmToken(_fcmToken!);
      } else {
        _fcmToken = await _generateDeviceToken();
        await _persistFcmToken(_fcmToken!);
      }
    } catch (e) {
      debugPrint('FCM token initialization error: $e');
      _fcmToken = _createEmergencyToken();
      await _persistFcmToken(_fcmToken!);
    }
  }

  Future<String> _generateDeviceToken() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      final permissionStatus =
          _getPermissionStatusString(settings.authorizationStatus);
      final platformIdentifier = _getPlatformIdentifier();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'fallback_${permissionStatus}_${platformIdentifier}_$timestamp';
    } catch (e) {
      return _createEmergencyToken();
    }
  }

  String _createEmergencyToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final platform = Platform.operatingSystem;
    return 'emergency_${platform}_$timestamp';
  }

  String _getPlatformIdentifier() {
    if (Platform.isIOS) {
      return _apnsToken == null ? 'ios_simulator' : 'ios_device';
    }
    return 'android';
  }

  String _getPermissionStatusString(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'authorized';
      case AuthorizationStatus.denied:
        return 'denied';
      case AuthorizationStatus.notDetermined:
        return 'not_determined';
      case AuthorizationStatus.provisional:
        return 'provisional';
    }
  }

  bool _isPermissionGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _persistFcmToken(String token) async {
    _fcmToken = token;
    await StorageManager.setString(StorageKeys.fcmTokenKey, token);
  }

  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed');
      await _persistFcmToken(newToken);
    });
  }

  void _logInitializationStatus() {
    debugPrint('=== TokenManager Status ===');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint(
        'Auth Token: ${_currentAuth != null ? 'Available' : 'Not available'}');
    debugPrint(
        'FCM Token: ${_fcmToken != null ? 'Available' : 'Not available'}');
    debugPrint(
        'APNS Token: ${_apnsToken != null ? 'Available' : 'Not available'}');
    debugPrint('Notification Status: ${notificationStatus.name}');
    debugPrint('========================');
  }
}

/// Enum representing notification configuration status
enum NotificationStatus {
  ready,
  fallback,
  simulator,
  notConfigured,
}

extension NotificationStatusExtension on NotificationStatus {
  String get description {
    switch (this) {
      case NotificationStatus.ready:
        return 'Ready for notifications';
      case NotificationStatus.fallback:
        return 'Using fallback token';
      case NotificationStatus.simulator:
        return 'Simulator (limited functionality)';
      case NotificationStatus.notConfigured:
        return 'Not configured';
    }
  }
}
