// ignore_for_file: library_private_types_in_public_api

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../places/domain/entities/place_source.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  _SettingsStore(this._prefs) {
    final saved = _prefs.localeCode;
    if (saved != null) {
      locale = Locale(saved);
    } else {
      final device = ui.PlatformDispatcher.instance.locale.languageCode;
      locale = Locale(device == 'ru' ? 'ru' : 'en');
    }
    themeMode = _prefs.themeMode;
    enabledSources = ObservableSet.of(_prefs.enabledSources);
    searchRadiusM = _prefs.searchRadiusM;
    backgroundTracking = _prefs.backgroundTracking;
    autoTracking = _prefs.autoTracking;
    dailyStepGoal = _prefs.dailyStepGoal;
    stepLengthCm = _prefs.stepLengthCm;
    geofenceRadiusM = _prefs.geofenceRadiusM;
  }

  final AppPreferences _prefs;

  @observable
  Locale locale = const Locale('en');

  @observable
  ThemeMode themeMode = ThemeMode.system;

  @observable
  ObservableSet<PlaceSource> enabledSources = ObservableSet<PlaceSource>();

  @observable
  int searchRadiusM = 1500;

  @observable
  bool backgroundTracking = false;

  @observable
  bool autoTracking = true;

  @observable
  int dailyStepGoal = 8000;

  @observable
  int stepLengthCm = 72;

  @observable
  int geofenceRadiusM = 40;

  String get languageCode => locale.languageCode;

  @action
  Future<void> setLocale(Locale l) async {
    locale = l;
    await _prefs.setLocaleCode(l.languageCode);
  }

  @action
  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    await _prefs.setThemeMode(m);
  }

  @action
  Future<void> toggleSource(PlaceSource s, bool enabled) async {
    if (s == PlaceSource.user) return;
    if (enabled) {
      enabledSources.add(s);
    } else {
      enabledSources.remove(s);
    }
    await _prefs.setEnabledSources(enabledSources);
  }

  @action
  Future<void> setSearchRadiusM(int v) async {
    searchRadiusM = v;
    await _prefs.setSearchRadiusM(v);
  }

  @action
  Future<void> setBackgroundTracking(bool v) async {
    backgroundTracking = v;
    await _prefs.setBackgroundTracking(v);
  }

  @action
  Future<void> setAutoTracking(bool v) async {
    autoTracking = v;
    await _prefs.setAutoTracking(v);
  }

  @action
  Future<void> setDailyStepGoal(int v) async {
    dailyStepGoal = v;
    await _prefs.setDailyStepGoal(v);
  }

  @action
  Future<void> setStepLengthCm(int v) async {
    stepLengthCm = v;
    await _prefs.setStepLengthCm(v);
  }

  @action
  Future<void> setGeofenceRadiusM(int v) async {
    geofenceRadiusM = v;
    await _prefs.setGeofenceRadiusM(v);
  }
}
