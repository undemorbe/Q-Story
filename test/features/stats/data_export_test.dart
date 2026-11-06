import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/stats/domain/data_export.dart';

import '../../helpers/fakes.dart';

void main() {
  final now = DateTime.utc(2026, 11, 7, 15, 30);

  test('empty export is valid and versioned', () {
    final data = DataExport.build(now: now, appVersion: '1.0.0');
    expect(data['format'], 'qstory-export');
    expect(data['formatVersion'], DataExport.formatVersion);
    expect(data['exportedAt'], '2026-11-07T15:30:00.000Z');
    expect((data['app'] as Map)['version'], '1.0.0');
    expect(data['summary'], {
      'days': 0,
      'steps': 0,
      'distanceM': 0,
      'visits': 0,
      'hunts': 0,
      'favorites': 0,
      'userPlaces': 0,
    });
  });

  test('summary and sorting', () {
    final data = DataExport.build(
      now: now,
      appVersion: '1.0.0',
      days: [
        DayActivity(day: '2026-11-07', steps: 300, distanceM: 200.4),
        DayActivity(day: '2026-11-01', steps: 700, distanceM: 500.3),
      ],
      visits: [
        Visit.fromPlace(place('b'), VisitMethod.qr, DateTime(2026, 11, 7)),
        Visit.fromPlace(place('a'), VisitMethod.manual, DateTime(2026, 11, 1)),
      ],
      events: [
        ActivityEvent(type: ActivityEventType.view, at: DateTime(2026, 11, 7)),
        ActivityEvent(type: ActivityEventType.scan, at: DateTime(2026, 11, 2)),
      ],
      favorites: [place('f')],
      userPlaces: [place('u', source: PlaceSource.user)],
    );
    final summary = data['summary'] as Map;
    expect(summary['steps'], 1000);
    expect(summary['distanceM'], 701);
    expect(summary['visits'], 2);
    expect((data['days'] as List).map((d) => (d as Map)['day']), ['2026-11-01', '2026-11-07']);
    expect((data['visits'] as List).map((v) => (v as Map)['placeId']), ['osm:a', 'osm:b']);
    expect((data['events'] as List).map((e) => (e as Map)['type']), ['scan', 'view']);
    expect((data['userPlaces'] as List).single, containsPair('source', 'user'));
  });

  test('encode produces parseable, indented JSON', () {
    final text = DataExport.encode(DataExport.build(now: now, appVersion: '1.0.0', favorites: [place('x')]));
    expect(text, contains('\n  "format"'));
    final back = jsonDecode(text) as Map<String, dynamic>;
    expect((back['favorites'] as List).single['sourceId'], 'x');
  });

  test('entities survive export → JSON → fromJson', () {
    final v = Visit.fromPlace(place('a'), VisitMethod.geofence, DateTime(2026, 11, 1, 8));
    final text = DataExport.encode(DataExport.build(now: now, appVersion: '1', visits: [v]));
    final back = Visit.fromJson((jsonDecode(text)['visits'] as List).single as Map<String, Object?>);
    expect(back.toJson(), v.toJson());
  });

  test('file name is dated', () {
    expect(DataExport.fileName(DateTime(2026, 3, 8)), 'qstory-export-2026-03-08.json');
  });
}
