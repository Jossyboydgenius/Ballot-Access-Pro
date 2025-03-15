import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../services/api/api.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

final locator = GetIt.instance;

Future<void> setUpLocator(AppFlavorConfig config) async {
  await _registerExternalDependencies(config);
  _registerServices();
  _registerRepositories();
  _setUpServices();
}

void registerController() {}

void _registerServices() {
  locator.registerLazySingleton<Api>(() => Api());
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
}

Future<void> _registerExternalDependencies(AppFlavorConfig config) async {
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}

void _setUpServices() {}

Future<void> _registerRepositories() async {}