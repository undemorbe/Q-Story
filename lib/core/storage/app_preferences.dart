import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/places/domain/entities/place_source.dart';

/// Typed wrapper around [SharedPreferences] for small user settings.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kLocale = 'locale';
  static const _kTheme = 'theme_mode';
  static const _kOnboarding = 'has_seen_onboarding';
  static const _kSources = 'enabled_sources';
  static const _kRadius = 'search_radius_m';
  static const _kBackground = 'background_tracking';
  static const _kAutoTrack = 'auto_tracking';
  static const _kStepGoal = 'daily_step_goal';
  static const _kStepLength = 'step_length_cm';
  static const _kGeofence = 'geofence_radius_m';

  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String code) => _prefs.setString(_kLocale, code);

  ThemeMode get themeMode =>
      ThemeMode.values.firstWhere((m) => m.name == _prefs.getString(_kTheme), orElse: () => ThemeMode.system);
  Future<void> setThemeMode(ThemeMode m) => _prefs.setString(_kTheme, m.name);

  bool get hasSeenOnboarding => _prefs.getBool(_kOnboarding) ?? false;
  Future<void> setSeenOnboarding() => _prefs.setBool(_kOnboarding, true);

  Set<PlaceSource> get enabledSources {
    final raw = _prefs.getStringList(_kSources);
    if (raw == null) return PlaceSource.values.toSet();
    return raw.map(PlaceSource.parse).toSet()..add(PlaceSource.user);
  }

  Future<void> setEnabledSources(Set<PlaceSource> s) => _prefs.setStringList(_kSources, s.map((e) => e.name).toList());

  int get searchRadiusM => _prefs.getInt(_kRadius) ?? 1500;
  Future<void> setSearchRadiusM(int v) => _prefs.setInt(_kRadius, v);

  bool get backgroundTracking => _prefs.getBool(_kBackground) ?? false;
  Future<void> setBackgroundTracking(bool v) => _prefs.setBool(_kBackground, v);

  bool get autoTracking => _prefs.getBool(_kAutoTrack) ?? true;
  Future<void> setAutoTracking(bool v) => _prefs.setBool(_kAutoTrack, v);

  int get dailyStepGoal => _prefs.getInt(_kStepGoal) ?? 8000;
  Future<void> setDailyStepGoal(int v) => _prefs.setInt(_kStepGoal, v);

  int get stepLengthCm => _prefs.getInt(_kStepLength) ?? 72;
  Future<void> setStepLengthCm(int v) => _prefs.setInt(_kStepLength, v);

  int get geofenceRadiusM => _prefs.getInt(_kGeofence) ?? 40;
  Future<void> setGeofenceRadiusM(int v) => _prefs.setInt(_kGeofence, v);
}
