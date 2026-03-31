import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../features/qr_operations/data/repositories/qr_repository_impl.dart';
import '../../features/qr_operations/domain/repositories/qr_repository.dart';
import '../../features/qr_operations/presentation/stores/qr_store.dart';
import '../../features/qr_operations/domain/usecases/process_qr_usecase.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/stores/settings_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/stores/auth_store.dart';
import '../../features/favorites/presentation/stores/favorites_store.dart';
import '../../features/history/data/datasources/history_local_data_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/presentation/stores/history_store.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/presentation/stores/map_store.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data Sources
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: getIt(), localAuth: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<QrRepository>(() => QrRepositoryImpl());
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<MapRepository>(() => MapRepositoryImpl());

  // UseCases
  getIt.registerLazySingleton<ProcessQrUseCase>(
    () => ProcessQrUseCase(getIt()),
  );

  // Stores
  getIt.registerLazySingleton<QrStore>(() => QrStore(getIt()));
  getIt.registerLazySingleton<SettingsStore>(() => SettingsStore(getIt()));
  getIt.registerLazySingleton<AuthStore>(() => AuthStore(getIt()));
  getIt.registerLazySingleton<FavoritesStore>(() => FavoritesStore(getIt()));
  getIt.registerLazySingleton<HistoryStore>(() => HistoryStore(getIt()));
  getIt.registerLazySingleton<MapStore>(() => MapStore(getIt()));
}
