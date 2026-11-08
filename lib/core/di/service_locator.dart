import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/presentation/stores/journal_store.dart';
import '../../features/activity/presentation/stores/tracking_store.dart';
import '../../features/favorites/presentation/stores/favorites_store.dart';
import '../../features/history/data/datasources/daily_fact_remote_data_source.dart';
import '../../features/history/data/repositories/daily_fact_repository_impl.dart';
import '../../features/history/domain/repositories/daily_fact_repository.dart';
import '../../features/history/presentation/stores/daily_fact_store.dart';
import '../../features/places/data/repositories/places_repository_impl.dart';
import '../../features/places/data/sources/overpass_client.dart';
import '../../features/places/data/sources/pastvu_client.dart';
import '../../features/places/data/sources/wikidata_client.dart';
import '../../features/places/data/sources/wikipedia_client.dart';
import '../../features/places/domain/repositories/places_repository.dart';
import '../../features/places/presentation/stores/places_store.dart';
import '../../features/scanner/domain/scan_resolver.dart';
import '../../features/settings/presentation/stores/settings_store.dart';
import '../../features/stats/presentation/stores/milestone_service.dart';
import '../../features/stats/presentation/stores/stats_store.dart';
import '../network/http_client.dart';
import '../services/email_service.dart';
import '../services/mail_launcher.dart';
import '../services/motion_sensors.dart';
import '../services/notification_service.dart';
import '../services/report_service.dart';
import '../services/share_service.dart';
import '../storage/app_database.dart';
import '../storage/app_preferences.dart';

final getIt = GetIt.instance;

/// Wires the whole object graph. Everything is local except the HTTP
/// clients for public open-data APIs; there is no app backend.
Future<void> setupServiceLocator({
  AppDatabase? database,
  SharedPreferences? preferences,
  MotionSensors? sensors,
  Dio? dio,
  ShareService? share,
  MailLauncher? mail,
  LocalNotifier? notifier,
}) async {
  // ─── Infrastructure ────────────────────────────────────────────────
  final prefs = preferences ?? await SharedPreferences.getInstance();
  final db = database ?? await AppDatabase.open();
  final http = dio ?? createHttpClient();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<AppPreferences>(AppPreferences(prefs))
    ..registerSingleton<AppDatabase>(db)
    ..registerSingleton<Dio>(http)
    ..registerSingleton<MotionSensors>(sensors ?? DeviceMotionSensors())
    ..registerSingleton<ValueNotifier<int>>(ValueNotifier<int>(0), instanceName: 'currentTab')
    ..registerLazySingleton<MailLauncher>(() => mail ?? UrlMailLauncher())
    ..registerLazySingleton<ShareService>(() => share ?? const SystemShareService())
    ..registerLazySingleton<EmailService>(() => EmailService(getIt()))
    ..registerLazySingleton<ReportService>(() => ReportService(getIt()));

  // ─── Repositories ──────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<PlacesRepository>(
      () => PlacesRepositoryImpl(
        database: db,
        clients: [PastVuClient(http), WikipediaClient(http), WikidataClient(http), OverpassClient(http)],
      ),
    )
    ..registerLazySingleton<ActivityRepository>(() => ActivityRepositoryImpl(db))
    ..registerLazySingleton<DailyFactRemoteDataSource>(() => DailyFactRemoteDataSource(dio: http))
    ..registerLazySingleton<DailyFactRepository>(() => DailyFactRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<ScanResolver>(() => ScanResolver(getIt()))
    ..registerLazySingleton<NotificationService>(
      () => NotificationService(getIt(), getIt(), notifier ?? PluginNotifier()),
    );

  // ─── Stores ────────────────────────────────────────────────────────
  getIt
    ..registerSingleton<SettingsStore>(SettingsStore(getIt()))
    ..registerSingleton<JournalStore>(JournalStore(getIt()))
    ..registerSingleton<FavoritesStore>(FavoritesStore(db, getIt()))
    ..registerSingleton<TrackingStore>(TrackingStore(getIt(), getIt(), getIt(), getIt()))
    ..registerLazySingleton<PlacesStore>(() => PlacesStore(getIt(), getIt(), getIt()))
    ..registerLazySingleton<StatsStore>(() => StatsStore(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()))
    ..registerLazySingleton<DailyFactStore>(() => DailyFactStore(getIt()))
    ..registerLazySingleton<MilestoneService>(
      () => MilestoneService(tracking: getIt(), journal: getIt(), stats: getIt(), settings: getIt(), prefs: getIt()),
    );

  await Future.wait([getIt<JournalStore>().init(), getIt<FavoritesStore>().load(), getIt<TrackingStore>().init()]);
  getIt<MilestoneService>().start();
}
