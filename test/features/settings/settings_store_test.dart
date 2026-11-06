import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/settings/presentation/stores/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(SettingsStore, AppPreferences)> make([Map<String, Object> init = const {}]) async {
  SharedPreferences.setMockInitialValues(init);
  final p = AppPreferences(await SharedPreferences.getInstance());
  return (SettingsStore(p), p);
}

void main() {
  test('loads saved values', () async {
    final (s, _) = await make({
      'locale': 'ru',
      'theme_mode': 'dark',
      'daily_step_goal': 10000,
      'step_length_cm': 65,
      'geofence_radius_m': 30,
      'search_radius_m': 800,
    });
    expect(s.locale, const Locale('ru'));
    expect(s.languageCode, 'ru');
    expect(s.themeMode, ThemeMode.dark);
    expect(s.dailyStepGoal, 10000);
    expect(s.stepLengthCm, 65);
    expect(s.geofenceRadiusM, 30);
    expect(s.searchRadiusM, 800);
  });

  test('without a saved locale picks ru or en', () async {
    final (s, _) = await make();
    expect(['ru', 'en'], contains(s.languageCode));
  });

  test('setters update state and persist', () async {
    final (s, p) = await make();
    await s.setLocale(const Locale('en'));
    await s.setThemeMode(ThemeMode.light);
    await s.setSearchRadiusM(2500);
    await s.setBackgroundTracking(true);
    await s.setAutoTracking(false);
    await s.setDailyStepGoal(6000);
    await s.setStepLengthCm(75);
    await s.setGeofenceRadiusM(60);
    expect(p.localeCode, 'en');
    expect(p.themeMode, ThemeMode.light);
    expect(p.searchRadiusM, 2500);
    expect(p.backgroundTracking, isTrue);
    expect(p.autoTracking, isFalse);
    expect(p.dailyStepGoal, 6000);
    expect(p.stepLengthCm, 75);
    expect(p.geofenceRadiusM, 60);
    expect(s.dailyStepGoal, 6000);
  });

  test('sources can be toggled, but user places stay on', () async {
    final (s, p) = await make();
    await s.toggleSource(PlaceSource.osm, false);
    expect(s.enabledSources, isNot(contains(PlaceSource.osm)));
    expect(p.enabledSources, isNot(contains(PlaceSource.osm)));
    await s.toggleSource(PlaceSource.user, false);
    expect(s.enabledSources, contains(PlaceSource.user));
    await s.toggleSource(PlaceSource.osm, true);
    expect(p.enabledSources, contains(PlaceSource.osm));
  });
}
