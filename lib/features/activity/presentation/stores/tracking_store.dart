// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/services/motion_sensors.dart';
import '../../../../core/util/geo.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/domain/entities/place_source.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/services/hunt_eta.dart';
import '../../domain/services/movement_accumulator.dart';
import 'journal_store.dart';

part 'tracking_store.g.dart';

/// Live location, continuous tracking, step counting and "hunts"
/// (searching for a chosen place until the user physically reaches it).
class TrackingStore = _TrackingStore with _$TrackingStore;

abstract class _TrackingStore with Store {
  _TrackingStore(
    this._sensors,
    this._repo,
    this._journal,
    this._settings, {
    DateTime Function()? clock,
    // ignore: unused_element_parameter — set via the mixin-application constructor in tests.
    this.flushInterval = const Duration(seconds: 20),
  }) : _now = clock ?? DateTime.now {
    _journal.addVisitListener(_onVisit);
  }

  final MotionSensors _sensors;
  final ActivityRepository _repo;
  final JournalStore _journal;
  final SettingsStore _settings;
  final DateTime Function() _now;
  final Duration flushInterval;
  final MovementAccumulator _acc = MovementAccumulator();
  bool _stepStreamActive = false;

  static const int _maxTrackPoints = 3000;

  StreamSubscription<GeoFix>? _posSub;
  StreamSubscription<int>? _stepSub;
  Timer? _flushTimer;
  DayActivity? _day;
  double _estimatedStepCarry = 0;
  Place? _targetPlace;
  bool _dirty = false;

  // ─── Observable state ──────────────────────────────────────────────────

  @observable
  bool isTracking = false;

  @observable
  bool followUser = true;

  @observable
  GeoFix? position;

  @observable
  LocationAccess? access;

  /// False until the first hardware step event arrives; while false steps
  /// are estimated from walked distance and the configured step length.
  @observable
  bool stepSensorAvailable = false;

  @observable
  ObservableList<LatLng> track = ObservableList<LatLng>();

  @observable
  DateTime? sessionStartedAt;

  @observable
  double sessionDistanceM = 0;

  @observable
  int sessionSteps = 0;

  /// True while tracking when steps are being estimated from distance
  /// because the step sensor has not reported (missing or denied).
  @computed
  bool get stepsEstimatedNow => isTracking && !stepSensorAvailable && sessionSteps > 0;

  /// Seconds of actual movement in this session (stops excluded).
  @observable
  int sessionActiveSeconds = 0;

  @observable
  int todaySteps = 0;

  @observable
  double todayDistanceM = 0;

  @observable
  Hunt? activeHunt;

  /// Last hunt that ended with the place being found (for a celebration UI).
  @observable
  Hunt? lastFoundHunt;

  @computed
  LatLng? get latLng => position == null ? null : LatLng(position!.lat, position!.lon);

  @computed
  double? get distanceToTargetM {
    final p = position, h = activeHunt;
    if (p == null || h == null) return null;
    return Geo.distanceM(p.lat, p.lon, h.targetLat, h.targetLon);
  }

  /// Average walking speed this session, once there is enough data.
  @computed
  double? get walkingSpeedMps => sessionActiveSeconds < 60 ? null : sessionDistanceM / sessionActiveSeconds;

  /// Time and steps still needed to reach the hunt target.
  @computed
  HuntEta? get huntEta {
    final d = distanceToTargetM;
    if (d == null) return null;
    return HuntEta.estimate(d, observedSpeedMps: walkingSpeedMps, stepLengthCm: _settings.stepLengthCm);
  }

  @computed
  double? get bearingToTargetDeg {
    final p = position, h = activeHunt;
    if (p == null || h == null) return null;
    return Geo.bearingDeg(p.lat, p.lon, h.targetLat, h.targetLon);
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  @action
  Future<void> init() async {
    _day = await _repo.day(DayActivity.keyOf(_now()));
    todaySteps = _day!.steps;
    todayDistanceM = _day!.distanceM;
    activeHunt = await _repo.activeHunt();
  }

  /// Requests permissions and starts continuous tracking.
  @action
  Future<LocationAccess> start() async {
    if (isTracking) return LocationAccess.granted;
    final a = await _sensors.ensureLocationAccess();
    access = a;
    if (a != LocationAccess.granted) return a;

    isTracking = true;
    sessionStartedAt = _now();
    sessionDistanceM = 0;
    sessionSteps = 0;
    sessionActiveSeconds = 0;
    track.clear();
    _acc.reset();

    _posSub = _sensors.positions(background: _settings.backgroundTracking).listen(_onFix, onError: (_) {});

    _stepStreamActive = await _sensors.ensureStepAccess();
    if (_stepStreamActive) {
      _stepSub = _sensors.stepCount().listen(
        _onStepReading,
        onError: (_) => runInAction(() {
          _stepStreamActive = false;
          stepSensorAvailable = false;
        }),
      );
    }

    _flushTimer = Timer.periodic(flushInterval, (_) => flush());

    final fix = await _sensors.currentFix();
    if (fix != null && position == null) _onFix(fix);
    return a;
  }

  @action
  Future<void> stop() async {
    await _posSub?.cancel();
    await _stepSub?.cancel();
    _stepStreamActive = false;
    _posSub = null;
    _stepSub = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    isTracking = false;
    await flush();
  }

  /// Re-subscribes with new settings (e.g. background mode toggled).
  Future<void> restart() async {
    if (!isTracking) return;
    await stop();
    await start();
  }

  @action
  void setFollowUser(bool v) => followUser = v;

  /// One-shot position (used when tracking is off).
  @action
  Future<GeoFix?> locateOnce() async {
    final a = await _sensors.ensureLocationAccess();
    access = a;
    if (a != LocationAccess.granted) return null;
    final fix = await _sensors.currentFix();
    if (fix != null) position = fix;
    return fix;
  }

  Future<void> openLocationSettings() => _sensors.openLocationSettings();
  Future<void> openAppSettings() => _sensors.openAppSettings();

  // ─── Sensor handlers ───────────────────────────────────────────────────

  @action
  void _onFix(GeoFix fix) {
    position = fix;
    _rollDayIfNeeded();
    final delta = _acc.addFix(fix);
    if (delta.moved) {
      track.add(LatLng(fix.lat, fix.lon));
      if (track.length > _maxTrackPoints) track.removeAt(0);
      sessionDistanceM += delta.distanceM;
      todayDistanceM += delta.distanceM;
      final day = _day!;
      day.distanceM += delta.distanceM;
      day.activeSeconds += delta.activeSeconds;
      sessionActiveSeconds += delta.activeSeconds;
      if (delta.speedMps > day.maxSpeedMps) day.maxSpeedMps = delta.speedMps;
      final h = activeHunt;
      if (h != null) activeHunt = h.copyWith(distanceM: h.distanceM + delta.distanceM);

      // Estimate from distance only when no pedometer stream is running;
      // otherwise the sensor's first reading would double-count those steps.
      if (!_stepStreamActive) {
        _estimatedStepCarry += delta.distanceM * 100 / _settings.stepLengthCm;
        final whole = _estimatedStepCarry.floor();
        _estimatedStepCarry -= whole;
        _addSteps(whole, estimated: true);
      }
      _repo.addExploredCell(Geo.cellKey(fix.lat, fix.lon));
      _dirty = true;
    }
    _checkGeofence();
  }

  @action
  void _onStepReading(int cumulative) {
    stepSensorAvailable = true;
    _rollDayIfNeeded();
    _addSteps(_acc.addStepReading(cumulative));
  }

  void _addSteps(int n, {bool estimated = false}) {
    if (n <= 0) return;
    final day = _day!;
    day.steps += n;
    day.hourSteps[_now().hour] += n;
    todaySteps = day.steps;
    sessionSteps += n;
    final h = activeHunt;
    if (h != null) {
      activeHunt = h.copyWith(steps: h.steps + n, stepsEstimated: h.stepsEstimated || estimated);
    }
    _dirty = true;
  }

  void _rollDayIfNeeded() {
    final key = DayActivity.keyOf(_now());
    if (_day == null) {
      _day = DayActivity(day: key);
    } else if (_day!.day != key) {
      final old = _day!;
      _repo.saveDay(old);
      _day = DayActivity(day: key);
      todaySteps = 0;
      todayDistanceM = 0;
    }
  }

  /// Persists the current day and active hunt.
  Future<void> flush() async {
    if (!_dirty) return;
    _dirty = false;
    final day = _day;
    if (day != null) await _repo.saveDay(day);
    final h = activeHunt;
    if (h != null) await _repo.saveHunt(h);
  }

  // ─── Hunts ─────────────────────────────────────────────────────────────

  @action
  Future<void> startHunt(Place place) async {
    if (activeHunt != null) await finishHunt(found: false);
    final p = position;
    final hunt = Hunt(
      id: 'h${_now().microsecondsSinceEpoch}',
      placeId: place.id,
      placeTitle: place.title,
      targetLat: place.lat,
      targetLon: place.lon,
      startedAt: _now(),
      startDistanceM: p == null ? null : Geo.distanceM(p.lat, p.lon, place.lat, place.lon),
      stepsEstimated: !stepSensorAvailable,
    );
    _targetPlace = place;
    activeHunt = hunt;
    lastFoundHunt = null;
    await _repo.saveHunt(hunt);
    await _journal.log(ActivityEventType.huntStart, place: place);
    if (!isTracking) await start();
    _checkGeofence();
  }

  @action
  Future<Hunt?> finishHunt({required bool found}) async {
    final h = activeHunt;
    if (h == null) return null;
    final done = h.copyWith(status: found ? HuntStatus.found : HuntStatus.abandoned, endedAt: _now());
    activeHunt = null;
    _targetPlace = null;
    if (found) lastFoundHunt = done;
    await _repo.saveHunt(done);
    await _journal.log(found ? ActivityEventType.huntFound : ActivityEventType.huntAbandon, value: done.steps);
    await flush();
    return done;
  }

  @action
  void dismissFoundHunt() => lastFoundHunt = null;

  bool _completing = false;

  void _checkGeofence() {
    final h = activeHunt;
    final d = distanceToTargetM;
    if (h == null || d == null || _completing) return;
    if (d > _settings.geofenceRadiusM) return;
    _completing = true;
    final place = _targetPlace ?? _placeFromHunt(h);
    _journal
        .recordVisit(place, VisitMethod.geofence)
        .then((isNew) async {
          // If it was already visited, the visit listener did not fire.
          if (!isNew && activeHunt?.id == h.id) await finishHunt(found: true);
        })
        .whenComplete(() => _completing = false);
  }

  static Place _placeFromHunt(Hunt h) {
    final i = h.placeId.indexOf(':');
    return Place(
      source: PlaceSource.parse(i > 0 ? h.placeId.substring(0, i) : null),
      sourceId: i > 0 ? h.placeId.substring(i + 1) : h.placeId,
      title: h.placeTitle,
      lat: h.targetLat,
      lon: h.targetLon,
    );
  }

  void _onVisit(Visit v) {
    if (activeHunt?.placeId == v.placeId) finishHunt(found: true);
  }

  Future<void> dispose() => stop();
}
