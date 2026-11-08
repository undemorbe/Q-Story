// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TrackingStore on _TrackingStore, Store {
  Computed<bool>? _$stepsEstimatedNowComputed;

  @override
  bool get stepsEstimatedNow => (_$stepsEstimatedNowComputed ??= Computed<bool>(
    () => super.stepsEstimatedNow,
    name: '_TrackingStore.stepsEstimatedNow',
  )).value;
  Computed<LatLng?>? _$latLngComputed;

  @override
  LatLng? get latLng =>
      (_$latLngComputed ??= Computed<LatLng?>(() => super.latLng, name: '_TrackingStore.latLng')).value;
  Computed<double?>? _$distanceToTargetMComputed;

  @override
  double? get distanceToTargetM => (_$distanceToTargetMComputed ??= Computed<double?>(
    () => super.distanceToTargetM,
    name: '_TrackingStore.distanceToTargetM',
  )).value;
  Computed<double?>? _$walkingSpeedMpsComputed;

  @override
  double? get walkingSpeedMps => (_$walkingSpeedMpsComputed ??= Computed<double?>(
    () => super.walkingSpeedMps,
    name: '_TrackingStore.walkingSpeedMps',
  )).value;
  Computed<HuntEta?>? _$huntEtaComputed;

  @override
  HuntEta? get huntEta =>
      (_$huntEtaComputed ??= Computed<HuntEta?>(() => super.huntEta, name: '_TrackingStore.huntEta')).value;
  Computed<double?>? _$bearingToTargetDegComputed;

  @override
  double? get bearingToTargetDeg => (_$bearingToTargetDegComputed ??= Computed<double?>(
    () => super.bearingToTargetDeg,
    name: '_TrackingStore.bearingToTargetDeg',
  )).value;

  late final _$isTrackingAtom = Atom(name: '_TrackingStore.isTracking', context: context);

  @override
  bool get isTracking {
    _$isTrackingAtom.reportRead();
    return super.isTracking;
  }

  @override
  set isTracking(bool value) {
    _$isTrackingAtom.reportWrite(value, super.isTracking, () {
      super.isTracking = value;
    });
  }

  late final _$followUserAtom = Atom(name: '_TrackingStore.followUser', context: context);

  @override
  bool get followUser {
    _$followUserAtom.reportRead();
    return super.followUser;
  }

  @override
  set followUser(bool value) {
    _$followUserAtom.reportWrite(value, super.followUser, () {
      super.followUser = value;
    });
  }

  late final _$positionAtom = Atom(name: '_TrackingStore.position', context: context);

  @override
  GeoFix? get position {
    _$positionAtom.reportRead();
    return super.position;
  }

  @override
  set position(GeoFix? value) {
    _$positionAtom.reportWrite(value, super.position, () {
      super.position = value;
    });
  }

  late final _$accessAtom = Atom(name: '_TrackingStore.access', context: context);

  @override
  LocationAccess? get access {
    _$accessAtom.reportRead();
    return super.access;
  }

  @override
  set access(LocationAccess? value) {
    _$accessAtom.reportWrite(value, super.access, () {
      super.access = value;
    });
  }

  late final _$stepSensorAvailableAtom = Atom(name: '_TrackingStore.stepSensorAvailable', context: context);

  @override
  bool get stepSensorAvailable {
    _$stepSensorAvailableAtom.reportRead();
    return super.stepSensorAvailable;
  }

  @override
  set stepSensorAvailable(bool value) {
    _$stepSensorAvailableAtom.reportWrite(value, super.stepSensorAvailable, () {
      super.stepSensorAvailable = value;
    });
  }

  late final _$trackAtom = Atom(name: '_TrackingStore.track', context: context);

  @override
  ObservableList<LatLng> get track {
    _$trackAtom.reportRead();
    return super.track;
  }

  @override
  set track(ObservableList<LatLng> value) {
    _$trackAtom.reportWrite(value, super.track, () {
      super.track = value;
    });
  }

  late final _$sessionStartedAtAtom = Atom(name: '_TrackingStore.sessionStartedAt', context: context);

  @override
  DateTime? get sessionStartedAt {
    _$sessionStartedAtAtom.reportRead();
    return super.sessionStartedAt;
  }

  @override
  set sessionStartedAt(DateTime? value) {
    _$sessionStartedAtAtom.reportWrite(value, super.sessionStartedAt, () {
      super.sessionStartedAt = value;
    });
  }

  late final _$sessionDistanceMAtom = Atom(name: '_TrackingStore.sessionDistanceM', context: context);

  @override
  double get sessionDistanceM {
    _$sessionDistanceMAtom.reportRead();
    return super.sessionDistanceM;
  }

  @override
  set sessionDistanceM(double value) {
    _$sessionDistanceMAtom.reportWrite(value, super.sessionDistanceM, () {
      super.sessionDistanceM = value;
    });
  }

  late final _$sessionStepsAtom = Atom(name: '_TrackingStore.sessionSteps', context: context);

  @override
  int get sessionSteps {
    _$sessionStepsAtom.reportRead();
    return super.sessionSteps;
  }

  @override
  set sessionSteps(int value) {
    _$sessionStepsAtom.reportWrite(value, super.sessionSteps, () {
      super.sessionSteps = value;
    });
  }

  late final _$sessionActiveSecondsAtom = Atom(name: '_TrackingStore.sessionActiveSeconds', context: context);

  @override
  int get sessionActiveSeconds {
    _$sessionActiveSecondsAtom.reportRead();
    return super.sessionActiveSeconds;
  }

  @override
  set sessionActiveSeconds(int value) {
    _$sessionActiveSecondsAtom.reportWrite(value, super.sessionActiveSeconds, () {
      super.sessionActiveSeconds = value;
    });
  }

  late final _$todayStepsAtom = Atom(name: '_TrackingStore.todaySteps', context: context);

  @override
  int get todaySteps {
    _$todayStepsAtom.reportRead();
    return super.todaySteps;
  }

  @override
  set todaySteps(int value) {
    _$todayStepsAtom.reportWrite(value, super.todaySteps, () {
      super.todaySteps = value;
    });
  }

  late final _$todayDistanceMAtom = Atom(name: '_TrackingStore.todayDistanceM', context: context);

  @override
  double get todayDistanceM {
    _$todayDistanceMAtom.reportRead();
    return super.todayDistanceM;
  }

  @override
  set todayDistanceM(double value) {
    _$todayDistanceMAtom.reportWrite(value, super.todayDistanceM, () {
      super.todayDistanceM = value;
    });
  }

  late final _$activeHuntAtom = Atom(name: '_TrackingStore.activeHunt', context: context);

  @override
  Hunt? get activeHunt {
    _$activeHuntAtom.reportRead();
    return super.activeHunt;
  }

  @override
  set activeHunt(Hunt? value) {
    _$activeHuntAtom.reportWrite(value, super.activeHunt, () {
      super.activeHunt = value;
    });
  }

  late final _$lastFoundHuntAtom = Atom(name: '_TrackingStore.lastFoundHunt', context: context);

  @override
  Hunt? get lastFoundHunt {
    _$lastFoundHuntAtom.reportRead();
    return super.lastFoundHunt;
  }

  @override
  set lastFoundHunt(Hunt? value) {
    _$lastFoundHuntAtom.reportWrite(value, super.lastFoundHunt, () {
      super.lastFoundHunt = value;
    });
  }

  late final _$initAsyncAction = AsyncAction('_TrackingStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$startAsyncAction = AsyncAction('_TrackingStore.start', context: context);

  @override
  Future<LocationAccess> start() {
    return _$startAsyncAction.run(() => super.start());
  }

  late final _$stopAsyncAction = AsyncAction('_TrackingStore.stop', context: context);

  @override
  Future<void> stop() {
    return _$stopAsyncAction.run(() => super.stop());
  }

  late final _$locateOnceAsyncAction = AsyncAction('_TrackingStore.locateOnce', context: context);

  @override
  Future<GeoFix?> locateOnce() {
    return _$locateOnceAsyncAction.run(() => super.locateOnce());
  }

  late final _$startHuntAsyncAction = AsyncAction('_TrackingStore.startHunt', context: context);

  @override
  Future<void> startHunt(Place place) {
    return _$startHuntAsyncAction.run(() => super.startHunt(place));
  }

  late final _$finishHuntAsyncAction = AsyncAction('_TrackingStore.finishHunt', context: context);

  @override
  Future<Hunt?> finishHunt({required bool found}) {
    return _$finishHuntAsyncAction.run(() => super.finishHunt(found: found));
  }

  late final _$_TrackingStoreActionController = ActionController(name: '_TrackingStore', context: context);

  @override
  void setFollowUser(bool v) {
    final _$actionInfo = _$_TrackingStoreActionController.startAction(name: '_TrackingStore.setFollowUser');
    try {
      return super.setFollowUser(v);
    } finally {
      _$_TrackingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onFix(GeoFix fix) {
    final _$actionInfo = _$_TrackingStoreActionController.startAction(name: '_TrackingStore._onFix');
    try {
      return super._onFix(fix);
    } finally {
      _$_TrackingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onStepReading(int cumulative) {
    final _$actionInfo = _$_TrackingStoreActionController.startAction(name: '_TrackingStore._onStepReading');
    try {
      return super._onStepReading(cumulative);
    } finally {
      _$_TrackingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dismissFoundHunt() {
    final _$actionInfo = _$_TrackingStoreActionController.startAction(name: '_TrackingStore.dismissFoundHunt');
    try {
      return super.dismissFoundHunt();
    } finally {
      _$_TrackingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isTracking: ${isTracking},
followUser: ${followUser},
position: ${position},
access: ${access},
stepSensorAvailable: ${stepSensorAvailable},
track: ${track},
sessionStartedAt: ${sessionStartedAt},
sessionDistanceM: ${sessionDistanceM},
sessionSteps: ${sessionSteps},
sessionActiveSeconds: ${sessionActiveSeconds},
todaySteps: ${todaySteps},
todayDistanceM: ${todayDistanceM},
activeHunt: ${activeHunt},
lastFoundHunt: ${lastFoundHunt},
stepsEstimatedNow: ${stepsEstimatedNow},
latLng: ${latLng},
distanceToTargetM: ${distanceToTargetM},
walkingSpeedMps: ${walkingSpeedMps},
huntEta: ${huntEta},
bearingToTargetDeg: ${bearingToTargetDeg}
    ''';
  }
}
