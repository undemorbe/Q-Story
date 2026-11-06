import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppPreferences> prefs([Map<String, Object> init = const {}]) async {
  SharedPreferences.setMockInitialValues(init);
  return AppPreferences(await SharedPreferences.getInstance());
}

void main() {
  test('defaults', () async {
    final p = await prefs();
    expect(p.localeCode, isNull);
    expect(p.themeMode, ThemeMode.system);
    expect(p.hasSeenOnboarding, isFalse);
    expect(p.enabledSources, PlaceSource.values.toSet());
    expect(p.searchRadiusM, 1500);
    expect(p.backgroundTracking, isFalse);
    expect(p.autoTracking, isTrue);
    expect(p.dailyStepGoal, 8000);
    expect(p.stepLengthCm, 72);
    expect(p.geofenceRadiusM, 40);
    expect(p.goalNotifiedDay, isNull);
    expect(p.seenAchievements, isNull);
  });

  test('values round-trip', () async {
    final p = await prefs();
    await p.setLocaleCode('ru');
    await p.setThemeMode(ThemeMode.dark);
    await p.setSeenOnboarding();
    await p.setSearchRadiusM(3000);
    await p.setBackgroundTracking(true);
    await p.setAutoTracking(false);
    await p.setDailyStepGoal(12000);
    await p.setStepLengthCm(80);
    await p.setGeofenceRadiusM(25);
    expect(p.localeCode, 'ru');
    expect(p.themeMode, ThemeMode.dark);
    expect(p.hasSeenOnboarding, isTrue);
    expect(p.searchRadiusM, 3000);
    expect(p.backgroundTracking, isTrue);
    expect(p.autoTracking, isFalse);
    expect(p.dailyStepGoal, 12000);
    expect(p.stepLengthCm, 80);
    expect(p.geofenceRadiusM, 25);
  });

  test('unknown theme value falls back to system', () async {
    final p = await prefs({'theme_mode': 'sepia'});
    expect(p.themeMode, ThemeMode.system);
  });

  test('user places can never be disabled', () async {
    final p = await prefs();
    await p.setEnabledSources({PlaceSource.osm});
    expect(p.enabledSources, {PlaceSource.osm, PlaceSource.user});
  });

  test('milestone bookkeeping persists and clears', () async {
    final p = await prefs();
    await p.setGoalNotifiedDay('2026-11-07');
    await p.setSeenAchievements({'marathon', 'firstHunt'});
    expect(p.goalNotifiedDay, '2026-11-07');
    expect(p.seenAchievements, {'marathon', 'firstHunt'});
    await p.clearMilestones();
    expect(p.goalNotifiedDay, isNull);
    expect(p.seenAchievements, isNull);
  });
}
