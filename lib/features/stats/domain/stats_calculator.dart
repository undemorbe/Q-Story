import 'dart:math' as math;

import '../../activity/domain/entities/activity.dart';
import '../../places/domain/entities/place.dart';
import '../../places/domain/entities/place_source.dart';
import 'stats_snapshot.dart';

/// Raw local data the statistics are derived from.
class StatsInput {
  const StatsInput({
    this.days = const [],
    this.hunts = const [],
    this.visits = const [],
    this.events = const [],
    this.exploredCells = 0,
    this.favorites = 0,
    this.userPlaces = 0,
    this.visitedYears = const {},
    this.dailyGoal = 8000,
    this.cellSizeM = 250,
  });

  final List<DayActivity> days;
  final List<Hunt> hunts;
  final List<Visit> visits;
  final List<ActivityEvent> events;
  final int exploredCells;
  final int favorites;
  final int userPlaces;

  /// placeId → year of the visited object/photo (when known).
  final Map<String, int> visitedYears;
  final int dailyGoal;
  final double cellSizeM;
}

/// Pure function from [StatsInput] to [StatsSnapshot].
abstract final class StatsCalculator {
  /// Rough walking energy cost per step for an average adult.
  static const double kcalPerStep = 0.04;

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  static StatsSnapshot compute(StatsInput input, DateTime now) {
    final today = _dateOnly(now);
    final dayMap = {for (final d in input.days) d.day: d};
    final todayAct = dayMap[DayActivity.keyOf(today)];

    // ─── Movement ──────────────────────────────────────────────────────
    var totalSteps = 0, goalDays = 0, activeSecs = 0;
    var totalDist = 0.0, longestDist = 0.0, maxSpeed = 0.0;
    DayPoint? best;
    final byHour = List<int>.filled(24, 0);
    final byWeekday = List<int>.filled(7, 0);
    for (final d in input.days) {
      totalSteps += d.steps;
      totalDist += d.distanceM;
      activeSecs += d.activeSeconds;
      maxSpeed = math.max(maxSpeed, d.maxSpeedMps);
      longestDist = math.max(longestDist, d.distanceM);
      if (input.dailyGoal > 0 && d.steps >= input.dailyGoal) goalDays++;
      if (d.steps > 0 && (best == null || d.steps > best.steps)) {
        best = DayPoint(d.date, d.steps, d.distanceM);
      }
      for (var h = 0; h < 24 && h < d.hourSteps.length; h++) {
        byHour[h] += d.hourSteps[h];
      }
      byWeekday[d.date.weekday - 1] += d.steps;
    }

    final last30 = List.generate(30, (i) {
      final date = today.subtract(Duration(days: 29 - i));
      final d = dayMap[DayActivity.keyOf(date)];
      return DayPoint(date, d?.steps ?? 0, d?.distanceM ?? 0);
    });

    (int, double) week(int weeksAgo) {
      var steps = 0;
      var dist = 0.0;
      for (var i = 0; i < 7; i++) {
        final d = dayMap[DayActivity.keyOf(today.subtract(Duration(days: weeksAgo * 7 + i)))];
        steps += d?.steps ?? 0;
        dist += d?.distanceM ?? 0;
      }
      return (steps, dist);
    }

    final thisWeekMove = week(0);
    final lastWeekMove = week(1);

    // A day is "active" if the user walked or discovered something.
    final activeDaySet = <DateTime>{
      for (final d in input.days)
        if (d.steps > 0 || d.distanceM > 0) _dateOnly(d.date),
      for (final v in input.visits) _dateOnly(v.at),
      for (final e in input.events)
        if (e.type != ActivityEventType.placesLoaded) _dateOnly(e.at),
    };
    final streaks = _streaks(activeDaySet, today);
    final walkingDays = input.days.where((d) => d.steps > 0).length;

    // ─── Discoveries ───────────────────────────────────────────────────
    final bySource = <PlaceSource, int>{};
    final byCategory = <PlaceCategory, int>{};
    final byMethod = <VisitMethod, int>{};
    final weekAgo = today.subtract(const Duration(days: 6));
    var thisWeek = 0;
    Visit? first, last;
    int? oldestYear;
    for (final v in input.visits) {
      bySource[v.source] = (bySource[v.source] ?? 0) + 1;
      byCategory[v.category] = (byCategory[v.category] ?? 0) + 1;
      byMethod[v.method] = (byMethod[v.method] ?? 0) + 1;
      if (!v.at.isBefore(weekAgo)) thisWeek++;
      if (first == null || v.at.isBefore(first.at)) first = v;
      if (last == null || v.at.isAfter(last.at)) last = v;
      final y = input.visitedYears[v.placeId];
      if (y != null && (oldestYear == null || y < oldestYear)) oldestYear = y;
    }

    // ─── Hunts ─────────────────────────────────────────────────────────
    final hunts = _hunts(input.hunts, now);

    // ─── Engagement ────────────────────────────────────────────────────
    int count(ActivityEventType t) => input.events.where((e) => e.type == t).length;
    Set<String> unique(ActivityEventType t) =>
        input.events.where((e) => e.type == t && e.placeId != null).map((e) => e.placeId!).toSet();
    final loaded = input.events
        .where((e) => e.type == ActivityEventType.placesLoaded)
        .fold<num>(0, (s, e) => s + (e.value ?? 0))
        .toInt();

    final cellKm2 = (input.cellSizeM * input.cellSizeM) / 1e6;
    final visits = input.visits.length;

    return StatsSnapshot(
      generatedAt: now,
      totalSteps: totalSteps,
      todaySteps: todayAct?.steps ?? 0,
      dailyGoal: input.dailyGoal,
      avgDailySteps: walkingDays == 0 ? 0 : totalSteps / walkingDays,
      bestDay: best,
      goalDays: goalDays,
      totalDistanceM: totalDist,
      todayDistanceM: todayAct?.distanceM ?? 0,
      longestDayDistanceM: longestDist,
      activeTime: Duration(seconds: activeSecs),
      maxSpeedMps: maxSpeed,
      caloriesKcal: totalSteps * kcalPerStep,
      currentStreak: streaks.$1,
      longestStreak: streaks.$2,
      activeDays: activeDaySet.length,
      last30: last30,
      stepsByHour: byHour,
      stepsByWeekday: byWeekday,
      visitsTotal: visits,
      visitsThisWeek: thisWeek,
      visitsBySource: bySource,
      visitsByCategory: byCategory,
      visitsByMethod: byMethod,
      firstVisit: first,
      lastVisit: last,
      oldestVisitedYear: oldestYear,
      hunts: hunts,
      scans: count(ActivityEventType.scan),
      uniqueScans: unique(ActivityEventType.scan).length,
      views: count(ActivityEventType.view),
      uniqueViews: unique(ActivityEventType.view).length,
      favorites: input.favorites,
      userPlaces: input.userPlaces,
      placesLoaded: loaded,
      exploredCells: input.exploredCells,
      exploredKm2: input.exploredCells * cellKm2,
      stepsPerDiscovery: visits == 0 ? null : totalSteps / visits,
      metersPerDiscovery: visits == 0 ? null : totalDist / visits,
      thisWeekSteps: thisWeekMove.$1,
      lastWeekSteps: lastWeekMove.$1,
      thisWeekDistanceM: thisWeekMove.$2,
      lastWeekDistanceM: lastWeekMove.$2,
    );
  }

  /// (current, longest) streak of consecutive active days.
  static (int, int) _streaks(Set<DateTime> days, DateTime today) {
    if (days.isEmpty) return (0, 0);
    final sorted = days.toList()..sort();
    var longest = 1, run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inHours;
      run = (gap >= 20 && gap <= 28) ? run + 1 : 1; // tolerate DST shifts
      longest = math.max(longest, run);
    }
    var current = 0;
    var cursor = days.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (days.contains(cursor)) {
      current++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return (current, longest);
  }

  static HuntSummary _hunts(List<Hunt> all, DateTime now) {
    final found = all.where((h) => h.status == HuntStatus.found).toList();
    final abandoned = all.where((h) => h.status == HuntStatus.abandoned).length;
    final active = all.where((h) => h.status == HuntStatus.active).length;
    double avg(Iterable<num> xs) => xs.isEmpty ? 0 : xs.fold<num>(0, (a, b) => a + b) / xs.length;
    final detours = found.map((h) => h.detourRatio).whereType<double>().toList();
    Hunt? pick(int Function(Hunt a, Hunt b) cmp) => found.isEmpty ? null : (found.toList()..sort(cmp)).first;
    final recent = all.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return HuntSummary(
      total: all.length,
      found: found.length,
      abandoned: abandoned,
      active: active,
      avgSteps: avg(found.map((h) => h.steps)),
      avgDistanceM: avg(found.map((h) => h.distanceM)).toDouble(),
      avgDuration: Duration(seconds: avg(found.map((h) => h.duration(now).inSeconds)).round()),
      totalSteps: all.fold(0, (s, h) => s + h.steps),
      avgDetourRatio: detours.isEmpty ? null : avg(detours).toDouble(),
      fewestSteps: pick((a, b) => a.steps.compareTo(b.steps)),
      mostSteps: pick((a, b) => b.steps.compareTo(a.steps)),
      fastest: pick((a, b) => a.duration(now).compareTo(b.duration(now))),
      longest: pick((a, b) => b.distanceM.compareTo(a.distanceM)),
      recent: recent.take(10).toList(),
    );
  }
}
