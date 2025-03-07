import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  static StorageManager? _instance;
  static FlutterSecureStorage? _storage;

  StorageManager._();

  // Initialize the singleton instance
  static Future<void> init({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    if (_instance == null) {
      _instance = StorageManager._();
      _storage = const FlutterSecureStorage(
        iOptions: IOSOptions.defaultOptions,
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    }
  }

  // Direct access methods

  static Future<String?> getString(String key) async {
    return await _storage?.read(key: key);
  }

  static Future<bool?> getBool(String key) async {
    final value = await _storage?.read(key: key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  static Future<int?> getInt(String key) async {
    final value = await _storage?.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<double?> getDouble(String key) async {
    final value = await _storage?.read(key: key);
    return value != null ? double.tryParse(value) : null;
  }

  static Future<List<String>?> getStringList(String key) async {
    final value = await _storage?.read(key: key);
    if (value != null) {
      return (json.decode(value) as List).cast<String>();
    }
    return null;
  }

  // Setter methods
  static Future<void> setString(String key, String value) async {
    await _storage?.write(key: key, value: value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setInt(String key, int value) async {
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setDouble(String key, double value) async {
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _storage?.write(key: key, value: json.encode(value));
  }

  // Object operations
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _storage?.write(key: key, value: json.encode(value));
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final data = await _storage?.read(key: key);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Utility methods
  static Future<bool> hasKey(String key) async {
    final value = await _storage?.read(key: key);
    return value != null;
  }

  static Future<void> remove(String key) async {
    await _storage?.delete(key: key);
  }

  static Future<void> clear() async {
    await _storage?.deleteAll();
  }

  // Safe getter for storage
  static FlutterSecureStorage get storage {
    if (_storage == null) {
      throw Exception(
          'SecureStorageManager not initialized. Call init() first.');
    }
    return _storage!;
  }
}
