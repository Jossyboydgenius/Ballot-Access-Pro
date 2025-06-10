import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum LocalStorageKeys {
  accessToken,
  refreshToken,
  userId,
  expiresIn,
  debugName,
  debugEmail,
  debugPassword,
  showedOnboarding,
  timedOut,
  useBiometric,
  fcmToken,
}

class LocalStorageService {
  final FlutterSecureStorage _storage = locator<FlutterSecureStorage>();

  String _keyToString(LocalStorageKeys key) {
    return key.toString().split('.').last;
  }

  Future<String?> getStorageValue(LocalStorageKeys key) async {
    try {
      return await _storage.read(key: _keyToString(key));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveStorageValue(LocalStorageKeys key, String value) async {
    try {
      await _storage.write(key: _keyToString(key), value: value);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  Future<void> clearAuthAll() async {
    await _storage.delete(key: _keyToString(LocalStorageKeys.accessToken));
    await _storage.delete(key: _keyToString(LocalStorageKeys.refreshToken));
    await _storage.delete(key: _keyToString(LocalStorageKeys.expiresIn));
    await _storage.delete(key: _keyToString(LocalStorageKeys.debugName));
    await _storage.delete(key: _keyToString(LocalStorageKeys.debugEmail));
    await _storage.delete(key: _keyToString(LocalStorageKeys.debugPassword));
    await _storage.delete(key: _keyToString(LocalStorageKeys.expiresIn));
    await _storage.delete(key: _keyToString(LocalStorageKeys.timedOut));
  }

  Future<void> clearAll() async => await _storage.deleteAll();

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _keyToString(LocalStorageKeys.accessToken));
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  Future<void> removeStorageValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> saveLoginResponse(Map<String, dynamic> data) async {
    await saveStorageValue(LocalStorageKeys.accessToken, data['jwt']);
    await saveStorageValue(LocalStorageKeys.userId, data['id']);
  }
}
