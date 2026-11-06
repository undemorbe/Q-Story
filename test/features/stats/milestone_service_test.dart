import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/stats/domain/milestones.dart';
import 'package:qstory/features/stats/domain/stats_snapshot.dart';
import 'package:qstory/features/stats/presentation/stores/milestone_service.dart';

import '../../helpers/fakes.dart';
import 'stats_fixture.dart';

void main() {
  late StatsFixture f;
  late MilestoneService service;
  late List<Milestone> heard;

  setUp(() async {
    f = await StatsFixture.create(prefs: {'daily_step_goal': 100});
    service = MilestoneService(
      tracking: f.tracking,
      journal: f.env.journal,
      stats: f.stats,
      settings: f.env.settings,
      prefs: f.env.appPrefs,
      refreshDelayMs: 0,
    );
    heard = [];
    service.milestones.listen(heard.add);
  });
  tearDown(() async {
    service.dispose();
    await f.dispose();
  });

  Future<void> walk(int fromSteps, int toSteps) async {
    f.sensors.steps.add(fromSteps);
    await pumpEventQueue();
    f.sensors.steps.add(toSteps);
    await pumpEventQueue();
  }

  test('daily goal is announced once per day', () async {
    service.start();
    await f.tracking.start();
    await walk(1000, 1050);
    expect(heard, isEmpty);
    await walk(1050, 1150); // 150 ≥ 100
    await pumpEventQueue();
    expect(heard, [isA<GoalReached>()]);
    expect((heard.single as GoalReached).goal, 100);
    await walk(1150, 1300);
    await pumpEventQueue();
    expect(heard, hasLength(1));
    expect(f.env.appPrefs.goalNotifiedDay, DayActivity.keyOf(DateTime.now()));
  });

  test('first snapshot seeds achievements silently, later unlocks are announced', () async {
    // An achievement earned before the feature existed.
    await f.env.journal.recordVisit(place('a'), VisitMethod.manual);
    await f.stats.refresh();
    expect(await service.checkAchievements(f.stats.snapshot!), isEmpty);
    expect(f.env.appPrefs.seenAchievements, contains(AchievementId.firstDiscovery.name));

    // Earn a new one: a hunt found.
    final h = Hunt(
      id: 'h1',
      placeId: 'osm:b',
      placeTitle: 'B',
      targetLat: 0,
      targetLon: 0,
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      endedAt: DateTime.now(),
      status: HuntStatus.found,
    );
    await f.env.activity.saveHunt(h);
    await f.stats.refresh();
    final fresh = await service.checkAchievements(f.stats.snapshot!);
    expect(fresh, [const AchievementUnlocked(AchievementId.firstHunt)]);
    expect(await service.checkAchievements(f.stats.snapshot!), isEmpty);
  });

  test('journal changes refresh the statistics automatically', () async {
    service.start();
    expect(f.stats.snapshot, isNull);
    await f.env.journal.recordVisit(place('x'), VisitMethod.manual);
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(f.stats.snapshot, isNotNull);
    expect(f.stats.snapshot!.visitsTotal, 1);
  });

  test('reset forgets announcements', () async {
    await f.env.appPrefs.setGoalNotifiedDay('2026-01-01');
    await f.env.appPrefs.setSeenAchievements({'firstHunt'});
    await service.reset();
    expect(f.env.appPrefs.goalNotifiedDay, isNull);
    expect(f.env.appPrefs.seenAchievements, isNull);
  });

  test('start is idempotent and dispose stops listening', () async {
    service.start();
    service.start();
    expect(service.isStarted, isTrue);
    service.dispose();
    expect(service.isStarted, isFalse);
  });
}
