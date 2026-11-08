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
  static const _kGoalNotified = 'goal_notified_day';
  static const _kSeenAchievements = 'seen_achievements';
  static const _kNotifEnabled = 'notifications_enabled';
  static const _kNotifTime = 'notification_time';

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

  /// Day key (yyyy-MM-dd) on which the "daily goal reached" toast was shown.
  String? get goalNotifiedDay => _prefs.getString(_kGoalNotified);
  Future<void> setGoalNotifiedDay(String day) => _prefs.setString(_kGoalNotified, day);

  /// Achievements already announced; null until the first check seeds it.
  Set<String>? get seenAchievements => _prefs.getStringList(_kSeenAchievements)?.toSet();
  Future<void> setSeenAchievements(Set<String> ids) => _prefs.setStringList(_kSeenAchievements, ids.toList()..sort());

  /// Clears the milestone bookkeeping (used when statistics are reset).
  Future<void> clearMilestones() async {
    await _prefs.remove(_kGoalNotified);
    await _prefs.remove(_kSeenAchievements);
  }

  /// Daily reminder switch. Off by default: the OS permission is asked
  /// only when the user turns it on.
  bool get notificationsEnabled => _prefs.getBool(_kNotifEnabled) ?? false;
  Future<void> setNotificationsEnabled(bool v) => _prefs.setBool(_kNotifEnabled, v);

  /// Daily reminder time, stored as `HH:mm`; 18:00 by default.
  TimeOfDay get notificationTime {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(_prefs.getString(_kNotifTime) ?? '');
    final h = int.tryParse(m?.group(1) ?? '');
    final min = int.tryParse(m?.group(2) ?? '');
    if (h == null || min == null || h > 23 || min > 59) return const TimeOfDay(hour: 18, minute: 0);
    return TimeOfDay(hour: h, minute: min);
  }

  Future<void> setNotificationTime(TimeOfDay t) =>
      _prefs.setString(_kNotifTime, '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
}
