import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Data/Models/auth_model.dart';
import 'auth_api.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static TokenManager get instance => _instance;

  AuthModel? _currentAuth;
  final _tokenController = StreamController<AuthModel?>.broadcast();
  bool _isRefreshing = false;
  bool _isInitialized = false;

  AuthModel? get currentAuth => _currentAuth;
  Stream<AuthModel?> get tokenStream => _tokenController.stream;
  String? get token => _currentAuth?.accessToken;
  bool get hasValidToken => _currentAuth != null;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing TokenManager...');
      final storage = await SharedPreferences.getInstance();
      final authData = storage.getString('authData');

      if (authData != null) {
        debugPrint('Found stored auth data');
        _currentAuth = AuthModel.fromJson(jsonDecode(authData));
        _tokenController.add(_currentAuth);
      }
    } catch (e) {
      debugPrint('Token initialization error: $e');
    } finally {
      _isInitialized = true;
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
    debugPrint('Setting new token: ${authModel.accessToken}');
    _currentAuth = authModel;
    _tokenController.add(authModel);

    try {
      final storage = await SharedPreferences.getInstance();
      await storage.setString('authData', jsonEncode(authModel.toJson()));
      debugPrint('Token saved to storage');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<void> clearToken() async {
    debugPrint('Clearing token');
    _currentAuth = null;
    _tokenController.add(null);

    try {
      final storage = await SharedPreferences.getInstance();
      await storage.remove('authData');
      debugPrint('Token cleared from storage');
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  void dispose() {
    _tokenController.close();
  }
}
