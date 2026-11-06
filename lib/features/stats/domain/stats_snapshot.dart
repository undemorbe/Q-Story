import '../../activity/domain/entities/activity.dart';
import '../../places/domain/entities/place.dart';
import '../../places/domain/entities/place_source.dart';

class DayPoint {
  const DayPoint(this.date, this.steps, this.distanceM);
  final DateTime date;
  final int steps;
  final double distanceM;
}

class HuntSummary {
  const HuntSummary({
    required this.total,
    required this.found,
    required this.abandoned,
    required this.active,
    required this.avgSteps,
    required this.avgDistanceM,
    required this.avgDuration,
    required this.totalSteps,
    this.avgDetourRatio,
    this.fewestSteps,
    this.mostSteps,
    this.fastest,
    this.longest,
    this.recent = const [],
  });

  final int total;
  final int found;
  final int abandoned;
  final int active;
  final double avgSteps;
  final double avgDistanceM;
  final Duration avgDuration;
  final int totalSteps;
  final double? avgDetourRatio;
  final Hunt? fewestSteps;
  final Hunt? mostSteps;
  final Hunt? fastest;
  final Hunt? longest;
  final List<Hunt> recent;

  double get successRate {
    final finished = found + abandoned;
    return finished == 0 ? 0 : found / finished;
  }
}

enum AchievementId {
  firstDiscovery,
  tenDiscoveries,
  fiftyDiscoveries,
  firstHunt,
  fiveHunts,
  straightShooter,
  tenKDay,
  hundredKTotal,
  marathon,
  explorer,
  scanner,
  allSources,
  weekStreak,
  timeTraveler,
  curator,
  cartographer,
}

class Achievement {
  const Achievement(this.id, this.progress, this.target);
  final AchievementId id;
  final num progress;
  final num target;
  bool get unlocked => progress >= target;
  double get ratio => target == 0 ? 1 : (progress / target).clamp(0, 1).toDouble();
}

/// Everything shown on the statistics page, computed locally.
class StatsSnapshot {
  StatsSnapshot({
    required this.generatedAt,
    required this.totalSteps,
    required this.todaySteps,
    required this.dailyGoal,
    required this.avgDailySteps,
    required this.bestDay,
    required this.goalDays,
    required this.totalDistanceM,
    required this.todayDistanceM,
    required this.longestDayDistanceM,
    required this.activeTime,
    required this.maxSpeedMps,
    required this.caloriesKcal,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
    required this.last30,
    required this.stepsByHour,
    required this.stepsByWeekday,
    required this.visitsTotal,
    required this.visitsThisWeek,
    required this.visitsBySource,
    required this.visitsByCategory,
    required this.visitsByMethod,
    required this.firstVisit,
    required this.lastVisit,
    required this.oldestVisitedYear,
    required this.hunts,
    required this.scans,
    required this.uniqueScans,
    required this.views,
    required this.uniqueViews,
    required this.favorites,
    required this.userPlaces,
    required this.placesLoaded,
    required this.exploredCells,
    required this.exploredKm2,
    required this.stepsPerDiscovery,
    required this.metersPerDiscovery,
    this.thisWeekSteps = 0,
    this.lastWeekSteps = 0,
    this.thisWeekDistanceM = 0,
    this.lastWeekDistanceM = 0,
  });

  final DateTime generatedAt;

  // Movement
  final int totalSteps;
  final int todaySteps;
  final int dailyGoal;
  final double avgDailySteps;
  final DayPoint? bestDay;
  final int goalDays;
  final double totalDistanceM;
  final double todayDistanceM;
  final double longestDayDistanceM;
  final Duration activeTime;
  final double maxSpeedMps;
  final double caloriesKcal;
  final int currentStreak;
  final int longestStreak;
  final int activeDays;
  final List<DayPoint> last30;
  final List<int> stepsByHour;

  /// Monday = index 0.
  final List<int> stepsByWeekday;

  // Discoveries
  final int visitsTotal;
  final int visitsThisWeek;
  final Map<PlaceSource, int> visitsBySource;
  final Map<PlaceCategory, int> visitsByCategory;
  final Map<VisitMethod, int> visitsByMethod;
  final Visit? firstVisit;
  final Visit? lastVisit;
  final int? oldestVisitedYear;

  final HuntSummary hunts;

  // Engagement
  final int scans;
  final int uniqueScans;
  final int views;
  final int uniqueViews;
  final int favorites;
  final int userPlaces;
  final int placesLoaded;

  // Exploration
  final int exploredCells;
  final double exploredKm2;
  final double? stepsPerDiscovery;
  final double? metersPerDiscovery;

  // Rolling 7-day windows: [today-6 … today] vs the 7 days before.
  final int thisWeekSteps;
  final int lastWeekSteps;
  final double thisWeekDistanceM;
  final double lastWeekDistanceM;

  /// Relative change of steps vs the previous 7 days (0.25 = +25 %),
  /// or null when there is nothing to compare with.
  double? get weekStepsChange => lastWeekSteps == 0 ? null : (thisWeekSteps - lastWeekSteps) / lastWeekSteps;

  /// Steps still missing to reach today's goal (0 once reached).
  int get stepsToGoal => dailyGoal <= 0 ? 0 : (dailyGoal - todaySteps).clamp(0, dailyGoal);

  late final List<Achievement> achievements = _computeAchievements();

  List<Achievement> _computeAchievements() {
    final bestDaySteps = bestDay?.steps ?? 0;
    final remoteSourcesVisited = visitsBySource.keys.where((k) => k.isRemote).length;
    final straight = hunts.recent.where((h) => h.status == HuntStatus.found && (h.detourRatio ?? 99) <= 1.3).length;
    final oldest = oldestVisitedYear;
    return [
      Achievement(AchievementId.firstDiscovery, visitsTotal, 1),
      Achievement(AchievementId.tenDiscoveries, visitsTotal, 10),
      Achievement(AchievementId.fiftyDiscoveries, visitsTotal, 50),
      Achievement(AchievementId.firstHunt, hunts.found, 1),
      Achievement(AchievementId.fiveHunts, hunts.found, 5),
      Achievement(AchievementId.straightShooter, straight, 1),
      Achievement(AchievementId.tenKDay, bestDaySteps, 10000),
      Achievement(AchievementId.hundredKTotal, totalSteps, 100000),
      Achievement(AchievementId.marathon, totalDistanceM / 1000, 42.195),
      Achievement(AchievementId.explorer, exploredKm2, 1),
      Achievement(AchievementId.scanner, scans, 10),
      Achievement(AchievementId.allSources, remoteSourcesVisited, PlaceSource.remote.length),
      Achievement(AchievementId.weekStreak, longestStreak, 7),
      Achievement(AchievementId.timeTraveler, oldest != null && oldest < 1917 ? 1 : 0, 1),
      Achievement(AchievementId.curator, favorites, 10),
      Achievement(AchievementId.cartographer, userPlaces, 3),
    ];
  }

  int get unlockedAchievements => achievements.where((a) => a.unlocked).length;

  double get todayGoalRatio => dailyGoal == 0 ? 0 : (todaySteps / dailyGoal).clamp(0, 1).toDouble();

  int? get mostActiveHour {
    var best = -1, bestV = 0;
    for (var i = 0; i < stepsByHour.length; i++) {
      if (stepsByHour[i] > bestV) {
        bestV = stepsByHour[i];
        best = i;
      }
    }
    return best < 0 ? null : best;
  }

  int? get mostActiveWeekday {
    var best = -1, bestV = 0;
    for (var i = 0; i < stepsByWeekday.length; i++) {
      if (stepsByWeekday[i] > bestV) {
        bestV = stepsByWeekday[i];
        best = i;
      }
    }
    return best < 0 ? null : best;
  }
}
