import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  static StorageManager? _instance;
  static FlutterSecureStorage? _storage;
  static final Completer<void> _initCompleter = Completer<void>();
  static bool _isInitializing = false;

  StorageManager._();

  // Thread-safe initialization
  static Future<void> init({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    if (_instance != null) return; // Already initialized

    if (_isInitializing) {
      // Wait for ongoing initialization
      await _initCompleter.future;
      return;
    }

    _isInitializing = true;

    try {
      _instance = StorageManager._();
      _storage = const FlutterSecureStorage(
        iOptions: IOSOptions.defaultOptions,
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      _isInitializing = false;
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
      rethrow;
    }
  }

  // Direct access methods
  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    return await _storage?.read(key: key);
  }

  static Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    final value = await _storage?.read(key: key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  static Future<int?> getInt(String key) async {
    await _ensureInitialized();
    final value = await _storage?.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    final value = await _storage?.read(key: key);
    return value != null ? double.tryParse(value) : null;
  }

  static Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    final value = await _storage?.read(key: key);
    if (value != null) {
      return (json.decode(value) as List).cast<String>();
    }
    return null;
  }

  // Setter methods
  static Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setInt(String key, int value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setDouble(String key, double value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: value.toString());
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: json.encode(value));
  }

  // Object operations
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    await _storage?.write(key: key, value: json.encode(value));
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    await _ensureInitialized();
    final data = await _storage?.read(key: key);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Utility methods
  static Future<bool> hasKey(String key) async {
    await _ensureInitialized();
    final value = await _storage?.read(key: key);
    return value != null;
  }

  static Future<void> remove(String key) async {
    await _ensureInitialized();
    await _storage?.delete(key: key);
  }

  static Future<void> clear() async {
    await _ensureInitialized();
    await _storage?.deleteAll();
  }

  // Safe getter for storage
  static FlutterSecureStorage get storage {
    if (_storage == null) {
      throw Exception('StorageManager not initialized. Call init() first.');
    }
    return _storage!;
  }

  // Ensure initialization before any operation
  static Future<void> _ensureInitialized() async {
    if (_instance == null) {
      await init();
    }
  }
}
