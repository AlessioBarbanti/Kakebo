import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary; tests can provide an in-memory store.
abstract interface class KakeboStorage {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, Object> data);
}

class PreferencesStorage implements KakeboStorage {
  PreferencesStorage({SharedPreferencesAsync? preferences}) : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  static const _key = 'kakebo';

  @override
  Future<Map<String, dynamic>?> load() async {
    final raw = await _preferences.getString(_key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> save(Map<String, Object> data) => _preferences.setString(_key, jsonEncode(data));
}
