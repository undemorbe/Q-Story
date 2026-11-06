// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$localeAtom = Atom(name: '_SettingsStore.locale', context: context);

  @override
  Locale get locale {
    _$localeAtom.reportRead();
    return super.locale;
  }

  @override
  set locale(Locale value) {
    _$localeAtom.reportWrite(value, super.locale, () {
      super.locale = value;
    });
  }

  late final _$themeModeAtom = Atom(name: '_SettingsStore.themeMode', context: context);

  @override
  ThemeMode get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeMode value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$enabledSourcesAtom = Atom(name: '_SettingsStore.enabledSources', context: context);

  @override
  ObservableSet<PlaceSource> get enabledSources {
    _$enabledSourcesAtom.reportRead();
    return super.enabledSources;
  }

  @override
  set enabledSources(ObservableSet<PlaceSource> value) {
    _$enabledSourcesAtom.reportWrite(value, super.enabledSources, () {
      super.enabledSources = value;
    });
  }

  late final _$searchRadiusMAtom = Atom(name: '_SettingsStore.searchRadiusM', context: context);

  @override
  int get searchRadiusM {
    _$searchRadiusMAtom.reportRead();
    return super.searchRadiusM;
  }

  @override
  set searchRadiusM(int value) {
    _$searchRadiusMAtom.reportWrite(value, super.searchRadiusM, () {
      super.searchRadiusM = value;
    });
  }

  late final _$backgroundTrackingAtom = Atom(name: '_SettingsStore.backgroundTracking', context: context);

  @override
  bool get backgroundTracking {
    _$backgroundTrackingAtom.reportRead();
    return super.backgroundTracking;
  }

  @override
  set backgroundTracking(bool value) {
    _$backgroundTrackingAtom.reportWrite(value, super.backgroundTracking, () {
      super.backgroundTracking = value;
    });
  }

  late final _$autoTrackingAtom = Atom(name: '_SettingsStore.autoTracking', context: context);

  @override
  bool get autoTracking {
    _$autoTrackingAtom.reportRead();
    return super.autoTracking;
  }

  @override
  set autoTracking(bool value) {
    _$autoTrackingAtom.reportWrite(value, super.autoTracking, () {
      super.autoTracking = value;
    });
  }

  late final _$dailyStepGoalAtom = Atom(name: '_SettingsStore.dailyStepGoal', context: context);

  @override
  int get dailyStepGoal {
    _$dailyStepGoalAtom.reportRead();
    return super.dailyStepGoal;
  }

  @override
  set dailyStepGoal(int value) {
    _$dailyStepGoalAtom.reportWrite(value, super.dailyStepGoal, () {
      super.dailyStepGoal = value;
    });
  }

  late final _$stepLengthCmAtom = Atom(name: '_SettingsStore.stepLengthCm', context: context);

  @override
  int get stepLengthCm {
    _$stepLengthCmAtom.reportRead();
    return super.stepLengthCm;
  }

  @override
  set stepLengthCm(int value) {
    _$stepLengthCmAtom.reportWrite(value, super.stepLengthCm, () {
      super.stepLengthCm = value;
    });
  }

  late final _$geofenceRadiusMAtom = Atom(name: '_SettingsStore.geofenceRadiusM', context: context);

  @override
  int get geofenceRadiusM {
    _$geofenceRadiusMAtom.reportRead();
    return super.geofenceRadiusM;
  }

  @override
  set geofenceRadiusM(int value) {
    _$geofenceRadiusMAtom.reportWrite(value, super.geofenceRadiusM, () {
      super.geofenceRadiusM = value;
    });
  }

  late final _$setLocaleAsyncAction = AsyncAction('_SettingsStore.setLocale', context: context);

  @override
  Future<void> setLocale(Locale l) {
    return _$setLocaleAsyncAction.run(() => super.setLocale(l));
  }

  late final _$setThemeModeAsyncAction = AsyncAction('_SettingsStore.setThemeMode', context: context);

  @override
  Future<void> setThemeMode(ThemeMode m) {
    return _$setThemeModeAsyncAction.run(() => super.setThemeMode(m));
  }

  late final _$toggleSourceAsyncAction = AsyncAction('_SettingsStore.toggleSource', context: context);

  @override
  Future<void> toggleSource(PlaceSource s, bool enabled) {
    return _$toggleSourceAsyncAction.run(() => super.toggleSource(s, enabled));
  }

  late final _$setSearchRadiusMAsyncAction = AsyncAction('_SettingsStore.setSearchRadiusM', context: context);

  @override
  Future<void> setSearchRadiusM(int v) {
    return _$setSearchRadiusMAsyncAction.run(() => super.setSearchRadiusM(v));
  }

  late final _$setBackgroundTrackingAsyncAction = AsyncAction('_SettingsStore.setBackgroundTracking', context: context);

  @override
  Future<void> setBackgroundTracking(bool v) {
    return _$setBackgroundTrackingAsyncAction.run(() => super.setBackgroundTracking(v));
  }

  late final _$setAutoTrackingAsyncAction = AsyncAction('_SettingsStore.setAutoTracking', context: context);

  @override
  Future<void> setAutoTracking(bool v) {
    return _$setAutoTrackingAsyncAction.run(() => super.setAutoTracking(v));
  }

  late final _$setDailyStepGoalAsyncAction = AsyncAction('_SettingsStore.setDailyStepGoal', context: context);

  @override
  Future<void> setDailyStepGoal(int v) {
    return _$setDailyStepGoalAsyncAction.run(() => super.setDailyStepGoal(v));
  }

  late final _$setStepLengthCmAsyncAction = AsyncAction('_SettingsStore.setStepLengthCm', context: context);

  @override
  Future<void> setStepLengthCm(int v) {
    return _$setStepLengthCmAsyncAction.run(() => super.setStepLengthCm(v));
  }

  late final _$setGeofenceRadiusMAsyncAction = AsyncAction('_SettingsStore.setGeofenceRadiusM', context: context);

  @override
  Future<void> setGeofenceRadiusM(int v) {
    return _$setGeofenceRadiusMAsyncAction.run(() => super.setGeofenceRadiusM(v));
  }

  @override
  String toString() {
    return '''
locale: ${locale},
themeMode: ${themeMode},
enabledSources: ${enabledSources},
searchRadiusM: ${searchRadiusM},
backgroundTracking: ${backgroundTracking},
autoTracking: ${autoTracking},
dailyStepGoal: ${dailyStepGoal},
stepLengthCm: ${stepLengthCm},
geofenceRadiusM: ${geofenceRadiusM}
    ''';
  }
}
