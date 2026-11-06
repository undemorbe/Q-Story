import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/stats/domain/milestones.dart';
import 'package:qstory/features/stats/domain/stats_snapshot.dart';

void main() {
  group('checkGoal', () {
    test('fires once the goal is met', () {
      expect(
        Milestones.checkGoal(todaySteps: 8000, goal: 8000, todayKey: '2026-11-07', notifiedDay: null),
        const GoalReached(8000, '2026-11-07'),
      );
    });

    test('silent below the goal', () {
      expect(Milestones.checkGoal(todaySteps: 7999, goal: 8000, todayKey: 'd', notifiedDay: null), isNull);
    });

    test('silent if already announced today, fires again on a new day', () {
      expect(Milestones.checkGoal(todaySteps: 9000, goal: 8000, todayKey: 'd2', notifiedDay: 'd2'), isNull);
      expect(Milestones.checkGoal(todaySteps: 9000, goal: 8000, todayKey: 'd3', notifiedDay: 'd2'), isNotNull);
    });

    test('a zero goal never fires', () {
      expect(Milestones.checkGoal(todaySteps: 10, goal: 0, todayKey: 'd', notifiedDay: null), isNull);
    });
  });

  group('newAchievements', () {
    final list = [
      const Achievement(AchievementId.firstHunt, 1, 1),
      const Achievement(AchievementId.marathon, 50, 42.195),
      const Achievement(AchievementId.scanner, 3, 10),
    ];

    test('first run seeds silently', () {
      expect(Milestones.newAchievements(list, null), isEmpty);
      expect(Milestones.unlockedIds(list), {'firstHunt', 'marathon'});
    });

    test('announces only unseen unlocked ones', () {
      expect(Milestones.newAchievements(list, {'firstHunt'}), [const AchievementUnlocked(AchievementId.marathon)]);
      expect(Milestones.newAchievements(list, {'firstHunt', 'marathon'}), isEmpty);
    });
  });

  test('value equality', () {
    expect(const GoalReached(1, 'a'), const GoalReached(1, 'a'));
    expect(const GoalReached(1, 'a').hashCode, const GoalReached(1, 'a').hashCode);
    expect(const AchievementUnlocked(AchievementId.curator), isNot(const AchievementUnlocked(AchievementId.scanner)));
  });
}
