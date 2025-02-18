// storage_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static StorageManager? _instance;
  static SharedPreferences? _preferences;

  StorageManager._();

  static Future<void> init() async {
    if (_instance == null) {
      _instance = StorageManager._();
      _preferences = await SharedPreferences.getInstance();
    }
  }

  // Direct access methods
  static String? getString(String key) => _preferences?.getString(key);
  static bool? getBool(String key) => _preferences?.getBool(key);
  static int? getInt(String key) => _preferences?.getInt(key);
  static double? getDouble(String key) => _preferences?.getDouble(key);
  static List<String>? getStringList(String key) =>
      _preferences?.getStringList(key);

  // Setter methods
  static Future<bool> setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences?.setStringList(key, value) ?? false;
  }

  // Object operations
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _preferences?.setString(key, json.encode(value)) ?? false;
  }

  static Map<String, dynamic>? getObject(String key) {
    final data = _preferences?.getString(key);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Utility methods
  static bool hasKey(String key) => _preferences?.containsKey(key) ?? false;

  static Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  // Safe getter for preferences
  static SharedPreferences get preferences {
    if (_preferences == null) {
      throw Exception('StorageManager not initialized. Call init() first.');
    }
    return _preferences!;
  }
}
