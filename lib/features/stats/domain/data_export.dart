import 'dart:convert';

import '../../activity/domain/entities/activity.dart';
import '../../places/domain/entities/place.dart';

/// Everything QStory knows about the user, as one portable JSON document.
/// Nothing leaves the device unless the user shares this file.
abstract final class DataExport {
  static const int formatVersion = 1;

  static Map<String, Object?> build({
    required DateTime now,
    required String appVersion,
    List<DayActivity> days = const [],
    List<Visit> visits = const [],
    List<Hunt> hunts = const [],
    List<ActivityEvent> events = const [],
    List<Place> favorites = const [],
    List<Place> userPlaces = const [],
  }) {
    int byDate<T>(T a, T b, DateTime Function(T) at) => at(a).compareTo(at(b));
    return {
      'format': 'qstory-export',
      'formatVersion': formatVersion,
      'app': {'name': 'QStory', 'version': appVersion},
      'exportedAt': now.toUtc().toIso8601String(),
      'summary': {
        'days': days.length,
        'steps': days.fold<int>(0, (s, d) => s + d.steps),
        'distanceM': days.fold<double>(0, (s, d) => s + d.distanceM).round(),
        'visits': visits.length,
        'hunts': hunts.length,
        'favorites': favorites.length,
        'userPlaces': userPlaces.length,
      },
      'days': ([...days]..sort((a, b) => a.day.compareTo(b.day))).map((d) => d.toJson()).toList(),
      'visits': ([...visits]..sort((a, b) => byDate(a, b, (Visit v) => v.at))).map((v) => v.toJson()).toList(),
      'hunts': ([...hunts]..sort((a, b) => byDate(a, b, (Hunt h) => h.startedAt))).map((h) => h.toJson()).toList(),
      'events': ([...events]..sort((a, b) => byDate(a, b, (ActivityEvent e) => e.at))).map((e) => e.toJson()).toList(),
      'favorites': favorites.map((p) => p.toJson()).toList(),
      'userPlaces': userPlaces.map((p) => p.toJson()).toList(),
    };
  }

  static String encode(Map<String, Object?> data) => const JsonEncoder.withIndent('  ').convert(data);

  /// e.g. `qstory-export-2026-11-07.json`
  static String fileName(DateTime now) =>
      'qstory-export-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';
}
