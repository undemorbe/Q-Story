import 'stats_snapshot.dart';

/// Something worth congratulating the user for.
sealed class Milestone {
  const Milestone();
}

final class GoalReached extends Milestone {
  const GoalReached(this.goal, this.dayKey);
  final int goal;
  final String dayKey;

  @override
  bool operator ==(Object other) => other is GoalReached && other.goal == goal && other.dayKey == dayKey;

  @override
  int get hashCode => Object.hash(goal, dayKey);
}

final class AchievementUnlocked extends Milestone {
  const AchievementUnlocked(this.id);
  final AchievementId id;

  @override
  bool operator ==(Object other) => other is AchievementUnlocked && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Pure rules deciding when to announce a milestone. Each one is announced
/// at most once: the daily goal once per day, an achievement once ever.
abstract final class Milestones {
  /// Returns [GoalReached] if today's goal was just met and has not yet been
  /// announced today.
  static GoalReached? checkGoal({
    required int todaySteps,
    required int goal,
    required String todayKey,
    required String? notifiedDay,
  }) {
    if (goal <= 0 || todaySteps < goal || notifiedDay == todayKey) return null;
    return GoalReached(goal, todayKey);
  }

  /// Achievements unlocked in [current] that are not in [seen].
  ///
  /// When [seen] is null (first run, or after a reset) nothing is announced:
  /// the caller should store the current set as the baseline instead, so
  /// achievements earned before this feature existed don't pop up at once.
  static List<AchievementUnlocked> newAchievements(List<Achievement> current, Set<String>? seen) {
    if (seen == null) return const [];
    return [
      for (final a in current)
        if (a.unlocked && !seen.contains(a.id.name)) AchievementUnlocked(a.id),
    ];
  }

  /// Names of all unlocked achievements, to persist as the new baseline.
  static Set<String> unlockedIds(List<Achievement> current) => {
    for (final a in current)
      if (a.unlocked) a.id.name,
  };
}
