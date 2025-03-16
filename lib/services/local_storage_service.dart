import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageKeys {
  static String refreshToken = 'refreshToken';
  static String accessToken = 'accessToken';
  static String expiresIn = 'expiresIn';
  static String debugName = 'debugName';
  static String debugEmail = 'debugEmail';
  static String debugPassword = 'debugPassword';
  static String showedOnboarding = 'showedOnboarding';
  static String timedOut = 'timedOut';
  static String useBiometric = 'useBiometric';
}

class LocalStorageService {
  final FlutterSecureStorage _storage = locator<FlutterSecureStorage>();

  Future<String?> getStorageValue(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> saveStorageValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> clearAuthAll() async {
    await _storage.delete(key: LocalStorageKeys.accessToken);
    await _storage.delete(key: LocalStorageKeys.refreshToken);
    await _storage.delete(key: LocalStorageKeys.expiresIn);
    await _storage.delete(key: LocalStorageKeys.debugName);
    await _storage.delete(key: LocalStorageKeys.debugEmail);
    await _storage.delete(key: LocalStorageKeys.debugPassword);
    await _storage.delete(key: LocalStorageKeys.expiresIn);
    await _storage.delete(key: LocalStorageKeys.timedOut);
  }

  Future<void> clearAll() async => await _storage.deleteAll();

  Future<void> clearToken() async {
    await _storage.delete(key: LocalStorageKeys.accessToken);
  }

  Future<void> removeStorageValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}