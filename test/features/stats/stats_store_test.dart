import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/constants/app_info.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

import '../../helpers/fakes.dart';
import 'stats_fixture.dart';

void main() {
  late StatsFixture f;
  setUp(() async => f = await StatsFixture.create(prefs: {'daily_step_goal': 5000}));
  tearDown(() => f.dispose());

  test('refresh builds a snapshot from local data', () async {
    final today = DayActivity.keyOf(DateTime.now());
    await f.env.activity.saveDay(DayActivity(day: today, steps: 6000, distanceM: 4200));
    final p = place('ru:1', source: PlaceSource.wikipedia, year: 1850);
    await f.places.remember(p);
    await f.env.journal.recordVisit(p, VisitMethod.qr);
    await f.favorites.toggle(p);
    await f.places.saveUserPlace(place('u1', source: PlaceSource.user));
    await f.env.activity.addExploredCell('1:1');

    expect(f.stats.snapshot, isNull);
    await f.stats.refresh();
    final s = f.stats.snapshot!;
    expect(f.stats.isLoading, isFalse);
    expect(s.todaySteps, 6000);
    expect(s.dailyGoal, 5000);
    expect(s.stepsToGoal, 0);
    expect(s.visitsTotal, 1);
    expect(s.visitsByMethod[VisitMethod.qr], 1);
    expect(s.favorites, 1);
    expect(s.userPlaces, 1);
    expect(s.exploredCells, 1);
    expect(s.oldestVisitedYear, 1850);
    expect(s.thisWeekSteps, 6000);
  });

  test('exportJson contains everything that is stored', () async {
    final p = place('node/1');
    await f.env.journal.recordVisit(p, VisitMethod.manual);
    await f.favorites.toggle(p);
    final json = jsonDecode(await f.stats.exportJson(now: DateTime.utc(2026, 11, 7))) as Map<String, dynamic>;
    expect(json['app']['version'], AppInfo.version);
    expect(json['visits'], hasLength(1));
    expect(json['favorites'], hasLength(1));
    expect((json['events'] as List).length, greaterThanOrEqualTo(2)); // visit + favorite
  });

  test('resetAll clears statistics but keeps favourites', () async {
    final p = place('node/1');
    await f.env.journal.recordVisit(p, VisitMethod.manual);
    await f.favorites.toggle(p);
    await f.stats.resetAll();
    final s = f.stats.snapshot!;
    expect(s.visitsTotal, 0);
    expect(f.env.journal.isVisited(p.id), isFalse);
    expect(f.favorites.items, hasLength(1));
  });
}
