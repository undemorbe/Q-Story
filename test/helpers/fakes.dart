import 'dart:async';
import 'dart:typed_data';

import 'package:qstory/core/services/mail_launcher.dart';
import 'package:qstory/core/services/motion_sensors.dart';
import 'package:qstory/core/services/share_service.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/features/places/data/repositories/places_repository_impl.dart';
import 'package:qstory/features/places/data/sources/place_source_client.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_query.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/settings/presentation/stores/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scriptable location + pedometer.
class FakeSensors implements MotionSensors {
  final pos = StreamController<GeoFix>.broadcast();
  final steps = StreamController<int>.broadcast();
  LocationAccess access = LocationAccess.granted;
  bool stepAccess = true;
  bool? lastBackground;
  GeoFix? oneShot;
  int openedAppSettings = 0;
  int openedLocationSettings = 0;

  @override
  Future<LocationAccess> ensureLocationAccess() async => access;
  @override
  Future<GeoFix?> currentFix() async => oneShot;
  @override
  Stream<GeoFix> positions({required bool background, int distanceFilterM = 5}) {
    lastBackground = background;
    return pos.stream;
  }

  @override
  Future<bool> ensureStepAccess() async => stepAccess;
  @override
  Stream<int> stepCount() => steps.stream;
  @override
  Future<void> openAppSettings() async => openedAppSettings++;
  @override
  Future<void> openLocationSettings() async => openedLocationSettings++;
}

/// Place source returning canned data.
class FakeClient implements PlaceSourceClient {
  FakeClient(this.source, {this.places = const [], this.error, this.detail});
  @override
  final PlaceSource source;
  List<Place> places;
  Object? error;
  Place? detail;
  int nearbyCalls = 0;
  int fetchCalls = 0;
  PlaceQuery? lastQuery;

  @override
  Future<List<Place>> nearby(PlaceQuery query) async {
    nearbyCalls++;
    lastQuery = query;
    if (error != null) throw error!;
    return places;
  }

  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    fetchCalls++;
    if (error != null) throw error!;
    return detail;
  }
}

class FakeShare implements ShareService {
  final texts = <(String, String?)>[];
  final files = <(Uint8List, String, String)>[];
  bool fail = false;

  @override
  Future<void> shareText(String text, {String? subject}) async {
    if (fail) throw Exception('share failed');
    texts.add((text, subject));
  }

  @override
  Future<void> shareFile(Uint8List bytes, {required String fileName, required String mimeType, String? subject}) async {
    if (fail) throw Exception('share failed');
    files.add((bytes, fileName, mimeType));
  }
}

class FakeMail implements MailLauncher {
  final sent = <(String, String, String)>[];
  bool available = true;

  @override
  Future<bool> compose({required String to, required String subject, required String body}) async {
    if (!available) return false;
    sent.add((to, subject, body));
    return true;
  }
}

Place place(
  String id, {
  PlaceSource source = PlaceSource.osm,
  String? title,
  double lat = 59.0,
  double lon = 30.0,
  PlaceCategory category = PlaceCategory.monument,
  String summary = '',
  String? imageUrl,
  String? url,
  int? year,
}) => Place(
  source: source,
  sourceId: id,
  title: title ?? 'Place $id',
  lat: lat,
  lon: lon,
  category: category,
  summary: summary,
  imageUrl: imageUrl,
  url: url,
  yearStart: year,
);

/// In-memory database, prefs and the basic stores, wired like the app.
class TestEnv {
  TestEnv._(this.db, this.prefs, this.appPrefs, this.activity, this.journal, this.settings);

  final AppDatabase db;
  final SharedPreferences prefs;
  final AppPreferences appPrefs;
  final ActivityRepositoryImpl activity;
  final JournalStore journal;
  final SettingsStore settings;

  static Future<TestEnv> create({Map<String, Object> prefs = const {}, DateTime Function()? clock}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    final db = await AppDatabase.inMemory();
    final activity = ActivityRepositoryImpl(db);
    final journal = JournalStore(activity, clock: clock);
    await journal.init();
    final appPrefs = AppPreferences(sp);
    return TestEnv._(db, sp, appPrefs, activity, journal, SettingsStore(appPrefs));
  }

  PlacesRepositoryImpl placesRepo(List<PlaceSourceClient> clients, {DateTime Function()? clock}) =>
      PlacesRepositoryImpl(database: db, clients: clients, clock: clock);

  Future<void> dispose() => db.close();
}
