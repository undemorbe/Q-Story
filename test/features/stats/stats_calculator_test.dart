import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/stats/domain/stats_calculator.dart';
import 'package:qstory/features/stats/domain/stats_snapshot.dart';

void main() {
  final now = DateTime(2026, 11, 6, 18); // Friday

  DayActivity day(int daysAgo, int steps, {double dist = 0, int hour = 12}) {
    final d = DayActivity(day: DayActivity.keyOf(now.subtract(Duration(days: daysAgo))), steps: steps, distanceM: dist);
    d.hourSteps[hour] = steps;
    return d;
  }

  Visit visit(String id, PlaceSource s, int daysAgo, {VisitMethod m = VisitMethod.manual}) => Visit(
        placeId: '${s.name}:$id',
        title: id,
        source: s,
        category: PlaceCategory.monument,
        lat: 0,
        lon: 0,
        at: now.subtract(Duration(days: daysAgo)),
        method: m,
      );

  Hunt hunt(String id, HuntStatus st, int steps, double dist, int minutes, {double? start}) => Hunt(
        id: id,
        placeId: 'osm:$id',
        placeTitle: id,
        targetLat: 0,
        targetLon: 0,
        startedAt: now.subtract(Duration(minutes: minutes)),
        endedAt: st == HuntStatus.active ? null : now,
        status: st,
        steps: steps,
        distanceM: dist,
        startDistanceM: start,
      );

  test('empty input produces zeros, no crash', () {
    final s = StatsCalculator.compute(const StatsInput(), now);
    expect(s.totalSteps, 0);
    expect(s.currentStreak, 0);
    expect(s.last30, hasLength(30));
    expect(s.hunts.successRate, 0);
    expect(s.stepsPerDiscovery, isNull);
    expect(s.mostActiveHour, isNull);
    expect(s.unlockedAchievements, 0);
  });

  test('movement aggregates, goal days, best day, streaks', () {
    final s = StatsCalculator.compute(
      StatsInput(
        dailyGoal: 5000,
        days: [day(0, 6000, dist: 4000, hour: 9), day(1, 3000, dist: 2000), day(2, 12000, dist: 9000), day(5, 100)],
      ),
      now,
    );
    expect(s.totalSteps, 21100);
    expect(s.todaySteps, 6000);
    expect(s.goalDays, 2);
    expect(s.bestDay!.steps, 12000);
    expect(s.currentStreak, 3);
    expect(s.longestStreak, 3);
    expect(s.totalDistanceM, 15000);
    expect(s.longestDayDistanceM, 9000);
    expect(s.avgDailySteps, closeTo(21100 / 4, 0.01));
    expect(s.last30.last.steps, 6000);
    expect(s.stepsByHour[12], 15100);
    expect(s.mostActiveHour, 12);
    expect(s.caloriesKcal, closeTo(21100 * StatsCalculator.kcalPerStep, 0.01));
    // Achievement "10,000 steps in a day" unlocked by day(2)
    expect(s.achievements.firstWhere((a) => a.id == AchievementId.tenKDay).unlocked, isTrue);
  });

  test('current streak counts from yesterday if today is idle', () {
    final s = StatsCalculator.compute(StatsInput(days: [day(1, 10), day(2, 10)]), now);
    expect(s.currentStreak, 2);
  });

  test('discoveries breakdowns, per-discovery effort, oldest year', () {
    final s = StatsCalculator.compute(
      StatsInput(
        days: [day(0, 2000, dist: 1500)],
        visits: [
          visit('a', PlaceSource.osm, 0, m: VisitMethod.geofence),
          visit('b', PlaceSource.pastvu, 1, m: VisitMethod.qr),
          visit('c', PlaceSource.osm, 20),
        ],
        visitedYears: {'pastvu:b': 1903},
      ),
      now,
    );
    expect(s.visitsTotal, 3);
    expect(s.visitsThisWeek, 2);
    expect(s.visitsBySource[PlaceSource.osm], 2);
    expect(s.visitsByMethod[VisitMethod.qr], 1);
    expect(s.firstVisit!.title, 'c');
    expect(s.lastVisit!.title, 'a');
    expect(s.stepsPerDiscovery, closeTo(2000 / 3, 0.01));
    expect(s.oldestVisitedYear, 1903);
    expect(s.achievements.firstWhere((a) => a.id == AchievementId.timeTraveler).unlocked, isTrue);
  });

  test('hunts: success rate, averages, records, detour', () {
    final s = StatsCalculator.compute(
      StatsInput(hunts: [
        hunt('h1', HuntStatus.found, 1000, 800, 10, start: 700),
        hunt('h2', HuntStatus.found, 3000, 2000, 30, start: 1000),
        hunt('h3', HuntStatus.abandoned, 500, 300, 5),
        hunt('h4', HuntStatus.active, 50, 40, 1),
      ]),
      now,
    );
    final h = s.hunts;
    expect(h.total, 4);
    expect(h.found, 2);
    expect(h.active, 1);
    expect(h.successRate, closeTo(2 / 3, 1e-9));
    expect(h.avgSteps, 2000);
    expect(h.avgDistanceM, 1400);
    expect(h.avgDuration, const Duration(minutes: 20));
    expect(h.fewestSteps!.id, 'h1');
    expect(h.mostSteps!.id, 'h2');
    expect(h.fastest!.id, 'h1');
    expect(h.avgDetourRatio, closeTo((800 / 700 + 2.0) / 2, 1e-9));
    expect(h.totalSteps, 4550);
    expect(s.achievements.firstWhere((a) => a.id == AchievementId.straightShooter).unlocked, isTrue);
  });

  test('events: scans, unique views, places loaded', () {
    ActivityEvent e(ActivityEventType t, {String? id, num? v}) =>
        ActivityEvent(type: t, at: now, placeId: id, value: v);
    final s = StatsCalculator.compute(
      StatsInput(events: [
        e(ActivityEventType.scan, id: 'a'),
        e(ActivityEventType.scan, id: 'a'),
        e(ActivityEventType.view, id: 'a'),
        e(ActivityEventType.view, id: 'b'),
        e(ActivityEventType.placesLoaded, v: 40),
        e(ActivityEventType.placesLoaded, v: 2),
      ], exploredCells: 32),
      now,
    );
    expect(s.scans, 2);
    expect(s.uniqueScans, 1);
    expect(s.uniqueViews, 2);
    expect(s.placesLoaded, 42);
    expect(s.exploredKm2, closeTo(2.0, 1e-9)); // 32 × 0.0625 km²
    expect(s.activeDays, 1);
  });
}
