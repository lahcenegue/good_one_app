import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config/app_config.dart';

class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  // Private constructor
  StorageService._();

  // Singleton pattern
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Key management
  String _makeKey(String key) => '${AppConfig.storagePrefix}$key';

  // Basic operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(_makeKey(key), value);
  }

  String? getString(String key) {
    return _prefs.getString(_makeKey(key));
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(_makeKey(key), value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(_makeKey(key));
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(_makeKey(key), value);
  }

  int? getInt(String key) {
    return _prefs.getInt(_makeKey(key));
  }

  // Object operations
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(_makeKey(key), json.encode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final data = _prefs.getString(_makeKey(key));
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(_makeKey(key), value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(_makeKey(key));
  }

  // Remove operations
  Future<bool> remove(String key) async {
    return await _prefs.remove(_makeKey(key));
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check operations
  bool hasKey(String key) {
    return _prefs.containsKey(_makeKey(key));
  }

  // Batch operations
  Future<void> setMultiple(Map<String, dynamic> values) async {
    for (var entry in values.entries) {
      if (entry.value is String) {
        await setString(entry.key, entry.value as String);
      } else if (entry.value is bool) {
        await setBool(entry.key, entry.value as bool);
      } else if (entry.value is int) {
        await setInt(entry.key, entry.value as int);
      } else if (entry.value is Map) {
        await setObject(entry.key, entry.value as Map<String, dynamic>);
      } else if (entry.value is List<String>) {
        await setStringList(entry.key, entry.value as List<String>);
      }
    }
  }
}
