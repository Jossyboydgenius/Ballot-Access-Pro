import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/locator.dart';

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
  final fSStorage = locator<FlutterSecureStorage>();

  Future<String?> getStorageValue(String key) async {
    String? value = await fSStorage.read(key: key);
    return value;
  }

  Future<void> saveStorageValue(String key, String value) async {
    return await fSStorage.write(key: key, value: value);
  }

  Future<void> clearAuthAll() async {
    await fSStorage.delete(key: LocalStorageKeys.accessToken);
    await fSStorage.delete(key: LocalStorageKeys.refreshToken);
    await fSStorage.delete(key: LocalStorageKeys.expiresIn);
    await fSStorage.delete(key: LocalStorageKeys.debugName);
    await fSStorage.delete(key: LocalStorageKeys.debugEmail);
    await fSStorage.delete(key: LocalStorageKeys.debugPassword);
    await fSStorage.delete(key: LocalStorageKeys.expiresIn);
    await fSStorage.delete(key: LocalStorageKeys.timedOut);
  }

  Future<void> clearAll() async => await fSStorage.deleteAll();
} 