import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../services/api/api.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/petitioner_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/work_service.dart';
import '../services/audio_service.dart';
import '../services/fcm_service.dart';
import '../ui/views/petitioner/bloc/profile_bloc.dart';
import '../ui/views/petitioner/bloc/personal_information_bloc.dart';

final locator = GetIt.instance;

Future<void> setUpLocator(AppFlavorConfig config) async {
  await _registerExternalDependencies(config);
  _registerServices();
  await _registerRepositories();
  await _setUpServices();
  locator.registerFactory(() => ProfileBloc());
  locator.registerFactory(() => PersonalInformationBloc());
}

void registerController() {}

void _registerServices() {
  locator.registerLazySingleton<Api>(() => Api());
  locator
      .registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton(() => PetitionerService());
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  locator.registerLazySingleton<SyncService>(() => SyncService());
  locator.registerLazySingleton<WorkService>(() => WorkService());
  locator.registerLazySingleton<AudioService>(() => AudioService());
  locator.registerLazySingleton<FCMService>(() => FCMService());
}

Future<void> _registerExternalDependencies(AppFlavorConfig config) async {
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}

Future<void> _setUpServices() async {
  // Initialize database by accessing it (this will trigger initialization)
  await DatabaseService.database; // This will initialize the database

  // Initialize sync service
  final syncService = locator<SyncService>();
  syncService.initialize(); // This method returns void, not Future
}

Future<void> _registerRepositories() async {
  // Register repositories if needed
}
