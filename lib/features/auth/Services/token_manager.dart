import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Services/auth_api.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static TokenManager get instance => _instance;

  // Authentication tokens
  AuthModel? _currentAuth;
  final _tokenController = StreamController<AuthModel?>.broadcast();
  bool _isRefreshing = false;
  bool _isInitialized = false;

  // Firebase tokens
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String? _apnsToken;

  // Getters for auth tokens
  AuthModel? get currentAuth => _currentAuth;
  Stream<AuthModel?> get tokenStream => _tokenController.stream;
  String? get token => _currentAuth?.accessToken;
  bool get hasValidToken => _currentAuth != null;

  // Getters for Firebase tokens
  String? get fcmToken => _fcmToken;
  String? get apnsToken => _apnsToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await StorageManager.init();

    try {
      debugPrint('Initializing TokenManager...');

      // Initialize auth tokens
      await _initializeAuthTokens();

      // Initialize Firebase tokens (with error handling)
      await _initializeFirebaseTokens();
    } catch (e) {
      debugPrint('Token initialization error: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> _initializeAuthTokens() async {
    try {
      final authData = await StorageManager.getString('authData');

      if (authData != null) {
        debugPrint('Found stored auth data');
        _currentAuth = AuthModel.fromJson(jsonDecode(authData));
        _tokenController.add(_currentAuth);
      }
    } catch (e) {
      debugPrint('Auth token initialization error: $e');
    }
  }

  Future<void> _initializeFirebaseTokens() async {
    try {
      // Request permissions first
      await _requestFirebasePermissions();

      // For iOS, get APNS token first
      if (Platform.isIOS) {
        await _getAPNSToken();
      }

      // Then get FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        await StorageManager.setString(StorageKeys.fcmTokenKey, newToken);
      });

      debugPrint('Firebase tokens initialized successfully');
    } catch (e) {
      debugPrint('Firebase token initialization error: $e');
      // Don't throw the error, just log it
      // The app should continue to work even if push notifications fail
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

  Future<void> _getAPNSToken() async {
    if (Platform.isIOS) {
      try {
        // Wait a bit for APNS to be ready
        await Future.delayed(Duration(seconds: 1));

        _apnsToken = await _firebaseMessaging.getAPNSToken();
        if (_apnsToken != null) {
          debugPrint('APNS Token obtained: ${_apnsToken!.substring(0, 20)}...');
          await StorageManager.setString('apns_token', _apnsToken!);
        } else {
          debugPrint('APNS Token is null, retrying...');
          // Retry after a delay
          await Future.delayed(Duration(seconds: 2));
          _apnsToken = await _firebaseMessaging.getAPNSToken();
          if (_apnsToken != null) {
            debugPrint(
                'APNS Token obtained on retry: ${_apnsToken!.substring(0, 20)}...');
            await StorageManager.setString('apns_token', _apnsToken!);
          } else {
            debugPrint(
                'Unable to get APNS token - this is normal in simulator');
          }
        }
      } catch (e) {
        debugPrint('Error getting APNS token: $e');
      }
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
        await StorageManager.setString(StorageKeys.fcmTokenKey, _fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Method to retry getting Firebase tokens if needed
  Future<void> retryFirebaseTokenInitialization() async {
    if (_fcmToken == null || (Platform.isIOS && _apnsToken == null)) {
      debugPrint('Retrying Firebase token initialization...');
      await _initializeFirebaseTokens();
    }
  }

  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      debugPrint('Token refresh already in progress');
      return false;
    }

    if (_currentAuth?.accessToken == null) {
      debugPrint('No token to refresh');
      return false;
    }

    try {
      _isRefreshing = true;
      debugPrint('Attempting to refresh token');

      final response = await AuthApi.refreshToken(
        token: _currentAuth!.accessToken,
      );

      if (response.success && response.data != null) {
        debugPrint('Token refreshed successfully');
        await setToken(response.data!);
        return true;
      } else {
        debugPrint('Token refresh failed: ${response.error}');
        await clearToken();
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await clearToken();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> setToken(AuthModel authModel) async {
    _currentAuth = authModel;
    _tokenController.add(authModel);

    try {
      await StorageManager.setString(
          StorageKeys.tokenKey, authModel.accessToken);
      await StorageManager.setString(
        'authData',
        jsonEncode(authModel.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<void> clearToken() async {
    debugPrint('Clearing auth token');
    _currentAuth = null;
    _tokenController.add(null);

    try {
      await StorageManager.remove('authData');
      debugPrint('Auth token cleared from storage');
    } catch (e) {
      debugPrint('Error clearing auth token: $e');
    }
  }

  void dispose() {
    _tokenController.close();
  }
}
