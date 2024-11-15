import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Constants/app_links.dart';
import '../../Data/Models/auth_model.dart';
import '../Core/Apis/login_api.dart';

class AuthProvider with ChangeNotifier {
  AuthModel? _authData;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isAuth => _authData?.accessToken != null;
  String? get token => _authData?.accessToken;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(
        url: AppLinks.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      _authData = AuthModel.fromJson(response);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authData', json.encode(_authData!.toJson()));

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw error.toString();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authData')) return false;

    try {
      final authData = json.decode(prefs.getString('authData')!);
      _authData = AuthModel.fromJson(authData);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _authData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authData');
    notifyListeners();
  }
}
