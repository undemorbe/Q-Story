import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/services/motion_sensors.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/features/activity/presentation/stores/tracking_store.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/settings/presentation/stores/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSensors implements MotionSensors {
  final pos = StreamController<GeoFix>.broadcast();
  final steps = StreamController<int>.broadcast();
  LocationAccess access = LocationAccess.granted;
  bool stepAccess = true;
  bool? lastBackground;

  @override
  Future<LocationAccess> ensureLocationAccess() async => access;
  @override
  Future<GeoFix?> currentFix() async => null;
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
  Future<void> openAppSettings() async {}
  @override
  Future<void> openLocationSettings() async {}
}

void main() {
  late AppDatabase db;
  late ActivityRepositoryImpl repo;
  late JournalStore journal;
  late SettingsStore settings;
  late FakeSensors sensors;
  late TrackingStore store;
  var t = DateTime(2026, 11, 6, 10);

  GeoFix fix(double lat, double lon) => GeoFix(lat: lat, lon: lon, time: t, accuracyM: 5);

  Future<void> emit(GeoFix f) async {
    sensors.pos.add(f);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    t = DateTime(2026, 11, 6, 10);
    db = await AppDatabase.inMemory();
    repo = ActivityRepositoryImpl(db);
    journal = JournalStore(repo, clock: () => t);
    settings = SettingsStore(AppPreferences(await SharedPreferences.getInstance()));
    sensors = FakeSensors();
    store = TrackingStore(sensors, repo, journal, settings, clock: () => t, flushInterval: const Duration(hours: 1));
    await journal.init();
    await store.init();
  });

  tearDown(() async {
    await store.stop();
    await db.close();
  });

  test('does not start without location permission', () async {
    sensors.access = LocationAccess.denied;
    expect(await store.start(), LocationAccess.denied);
    expect(store.isTracking, isFalse);
  });

  test('accumulates distance and real steps, persists the day', () async {
    await store.start();
    await emit(fix(59.0, 30.0));
    t = t.add(const Duration(seconds: 20));
    await emit(fix(59.0002, 30.0)); // ~22 m
    sensors.steps.add(5000); // baseline
    await Future<void>.delayed(Duration.zero);
    sensors.steps.add(5030);
    await Future<void>.delayed(Duration.zero);

    expect(store.sessionDistanceM, closeTo(22.2, 0.5));
    expect(store.track, hasLength(1));
    expect(store.stepSensorAvailable, isTrue);
    expect(store.todaySteps, 30);
    await store.stop();
    final day = await repo.day(DayActivity.keyOf(t));
    expect(day.steps, 30);
    expect(day.hourSteps[10], 30);
    expect(day.distanceM, closeTo(22.2, 0.5));
    expect(await repo.exploredCellCount(), 1);
  });

  test('estimates steps from distance when no step sensor', () async {
    sensors.stepAccess = false;
    await settings.setStepLengthCm(80);
    await store.start();
    await emit(fix(59.0, 30.0));
    t = t.add(const Duration(seconds: 60));
    await emit(fix(59.0008, 30.0)); // ~89 m → ~111 steps
    expect(store.stepSensorAvailable, isFalse);
    expect(store.todaySteps, inInclusiveRange(108, 113));
  });

  test('hunt: counts steps & distance and completes on geofence arrival', () async {
    const target = Place(source: PlaceSource.osm, sourceId: 'node/1', title: 'Памятник', lat: 59.001, lon: 30.0);
    await settings.setGeofenceRadiusM(10);
    await store.start();
    await emit(fix(59.0, 30.0));
    await store.startHunt(target);
    expect(store.activeHunt, isNotNull);
    expect(store.distanceToTargetM, closeTo(111, 1));
    sensors.steps.add(100);
    await Future<void>.delayed(Duration.zero);

    for (var i = 1; i <= 4; i++) {
      t = t.add(const Duration(seconds: 25));
      sensors.steps.add(100 + 35 * i);
      await Future<void>.delayed(Duration.zero);
      await emit(fix(59.0 + 0.00025 * i, 30.0));
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(store.activeHunt, isNull);
    final found = store.lastFoundHunt!;
    expect(found.status, HuntStatus.found);
    expect(found.steps, 140);
    expect(found.distanceM, closeTo(111, 2));
    expect(found.detourRatio, closeTo(1.0, 0.05));
    expect(journal.isVisited('osm:node/1'), isTrue);
    final visits = await repo.visits();
    expect(visits.single.method, VisitMethod.geofence);
    final hunts = await repo.hunts();
    expect(hunts.single.status, HuntStatus.found);
  });

  test('scanning the target (visit from elsewhere) finishes the hunt', () async {
    const target = Place(source: PlaceSource.pastvu, sourceId: '7', title: 'Фото', lat: 60, lon: 31);
    await store.start();
    await store.startHunt(target);
    await journal.recordVisit(target, VisitMethod.qr);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(store.activeHunt, isNull);
    expect(store.lastFoundHunt?.placeId, 'pastvu:7');
  });

  test('giving up marks the hunt abandoned and keeps it in history', () async {
    const target = Place(source: PlaceSource.osm, sourceId: 'node/2', title: 'X', lat: 60, lon: 31);
    await store.startHunt(target);
    final h = await store.finishHunt(found: false);
    expect(h!.status, HuntStatus.abandoned);
    expect((await repo.hunts()).single.status, HuntStatus.abandoned);
    expect(await repo.activeHunt(), isNull);
  });

  test('active hunt survives restart', () async {
    const target = Place(source: PlaceSource.osm, sourceId: 'node/3', title: 'Y', lat: 60, lon: 31);
    await store.startHunt(target);
    await store.stop();
    final again = TrackingStore(sensors, repo, journal, settings, clock: () => t);
    await again.init();
    expect(again.activeHunt?.placeId, 'osm:node/3');
  });

  test('background setting is passed to the position stream', () async {
    await settings.setBackgroundTracking(true);
    await store.start();
    expect(sensors.lastBackground, isTrue);
  });

  test('day rollover resets today counters', () async {
    sensors.stepAccess = true;
    await store.start();
    sensors.steps.add(10);
    await Future<void>.delayed(Duration.zero);
    sensors.steps.add(60);
    await Future<void>.delayed(Duration.zero);
    expect(store.todaySteps, 50);
    t = DateTime(2026, 11, 7, 0, 5);
    sensors.steps.add(70);
    await Future<void>.delayed(Duration.zero);
    expect(store.todaySteps, 10);
    await store.stop();
    expect((await repo.day('2026-11-06')).steps, 50);
    expect((await repo.day('2026-11-07')).steps, 10);
  });
}
