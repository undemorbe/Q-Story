import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

void main() {
  final t0 = DateTime(2026, 11, 7, 9, 30);

  test('Visit.fromPlace copies identity and JSON round-trips', () {
    const p = Place(
        source: PlaceSource.wikidata, sourceId: 'Q1', title: 'Дума', lat: 1, lon: 2, category: PlaceCategory.building);
    final v = Visit.fromPlace(p, VisitMethod.qr, t0);
    expect(v.placeId, 'wikidata:Q1');
    expect(v.category, PlaceCategory.building);
    final back = Visit.fromJson(v.toJson());
    expect(back.toJson(), v.toJson());
    expect(back.at, t0);
    expect(back.method, VisitMethod.qr);
  });

  group('Hunt', () {
    Hunt hunt({double dist = 0, double? start, DateTime? end}) => Hunt(
          id: 'h',
          placeId: 'osm:1',
          placeTitle: 'X',
          targetLat: 1,
          targetLon: 2,
          startedAt: t0,
          endedAt: end,
          distanceM: dist,
          startDistanceM: start,
        );

    test('duration uses end time or now', () {
      expect(hunt(end: t0.add(const Duration(minutes: 7))).duration(DateTime(2030)), const Duration(minutes: 7));
      expect(hunt().duration(t0.add(const Duration(seconds: 30))), const Duration(seconds: 30));
    });

    test('detourRatio needs a meaningful start distance and some walking', () {
      expect(hunt(dist: 300, start: 200).detourRatio, 1.5);
      expect(hunt(dist: 300, start: 10).detourRatio, isNull);
      expect(hunt(dist: 0, start: 200).detourRatio, isNull);
      expect(hunt(dist: 300).detourRatio, isNull);
    });

    test('copyWith and JSON round-trip', () {
      final h = hunt(dist: 120, start: 100).copyWith(
        status: HuntStatus.found,
        steps: 170,
        endedAt: t0.add(const Duration(minutes: 3)),
        stepsEstimated: true,
      );
      final back = Hunt.fromJson(h.toJson());
      expect(back.toJson(), h.toJson());
      expect(back.status, HuntStatus.found);
      expect(back.stepsEstimated, isTrue);
    });

    test('unknown status in storage is treated as abandoned', () {
      final j = hunt().toJson()..['status'] = 'paused';
      expect(Hunt.fromJson(j).status, HuntStatus.abandoned);
    });
  });

  group('DayActivity', () {
    test('keyOf pads month and day', () {
      expect(DayActivity.keyOf(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    });

    test('date parses the key back', () {
      expect(DayActivity(day: '2026-03-08').date, DateTime(2026, 3, 8));
    });

    test('has 24 hour buckets and round-trips', () {
      final d = DayActivity(day: '2026-11-07', steps: 100, distanceM: 70.5, activeSeconds: 60, maxSpeedMps: 1.4);
      expect(d.hourSteps, hasLength(24));
      d.hourSteps[9] = 100;
      final back = DayActivity.fromJson(d.toJson());
      expect(back.toJson(), d.toJson());
      expect(back.hourSteps[9], 100);
    });
  });

  test('ActivityEvent round-trips with optional fields', () {
    final e = ActivityEvent(type: ActivityEventType.scan, at: t0, placeId: 'osm:1', source: PlaceSource.osm, value: 3);
    final back = ActivityEvent.fromJson(e.toJson());
    expect(back.toJson(), e.toJson());
    final bare = ActivityEvent.fromJson(ActivityEvent(type: ActivityEventType.huntStart, at: t0).toJson());
    expect(bare.placeId, isNull);
    expect(bare.source, isNull);
  });
}
