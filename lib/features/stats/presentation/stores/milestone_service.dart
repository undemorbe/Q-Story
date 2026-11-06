import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/milestones.dart';
import '../../domain/stats_snapshot.dart';
import 'stats_store.dart';

/// Watches live tracking and the statistics snapshot and emits
/// [Milestone]s (daily goal reached, achievement unlocked) exactly once.
///
/// Also keeps the statistics fresh: whenever something is logged in the
/// journal or a hunt changes state, the snapshot is recomputed.
class MilestoneService {
  MilestoneService({
    required TrackingStore tracking,
    required JournalStore journal,
    required StatsStore stats,
    required SettingsStore settings,
    required AppPreferences prefs,
    DateTime Function()? clock,
    int refreshDelayMs = 800,
  })  : _tracking = tracking,
        _journal = journal,
        _stats = stats,
        _settings = settings,
        _prefs = prefs,
        _now = clock ?? DateTime.now,
        _refreshDelayMs = refreshDelayMs;

  final TrackingStore _tracking;
  final JournalStore _journal;
  final StatsStore _stats;
  final SettingsStore _settings;
  final AppPreferences _prefs;
  final DateTime Function() _now;
  final int _refreshDelayMs;

  final _controller = StreamController<Milestone>.broadcast();
  final List<ReactionDisposer> _disposers = [];

  /// Milestones as they happen (listen once, e.g. in the app shell).
  Stream<Milestone> get milestones => _controller.stream;

  bool get isStarted => _disposers.isNotEmpty;

  void start() {
    if (isStarted) return;
    _disposers
      ..add(reaction((_) => _tracking.todaySteps, (_) => checkGoal()))
      ..add(reaction((_) => _journal.revision, (_) => _stats.refresh(), delay: _refreshDelayMs))
      ..add(reaction((_) => _tracking.activeHunt?.status, (_) => _stats.refresh(), delay: _refreshDelayMs))
      ..add(reaction((_) => _stats.snapshot, (StatsSnapshot? s) {
        if (s != null) checkAchievements(s);
      }));
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _disposers.clear();
    _controller.close();
  }

  /// Emits [GoalReached] when today's steps first reach the goal.
  Future<GoalReached?> checkGoal() async {
    final today = DayActivity.keyOf(_now());
    final m = Milestones.checkGoal(
      todaySteps: _tracking.todaySteps,
      goal: _settings.dailyStepGoal,
      todayKey: today,
      notifiedDay: _prefs.goalNotifiedDay,
    );
    if (m == null) return null;
    await _prefs.setGoalNotifiedDay(today);
    _emit(m);
    return m;
  }

  /// Emits [AchievementUnlocked] for each achievement not announced before.
  Future<List<AchievementUnlocked>> checkAchievements(StatsSnapshot s) async {
    final seen = _prefs.seenAchievements;
    final fresh = Milestones.newAchievements(s.achievements, seen);
    final unlocked = Milestones.unlockedIds(s.achievements);
    // Union with what was seen: an achievement whose progress temporarily
    // drops (e.g. a favourite removed) must not be announced again.
    final baseline = {...?seen, ...unlocked};
    if (seen == null || fresh.isNotEmpty) await _prefs.setSeenAchievements(baseline);
    fresh.forEach(_emit);
    return fresh;
  }

  /// Forgets what was announced (after the statistics are reset), so
  /// milestones earned from scratch are celebrated again.
  Future<void> reset() => _prefs.clearMilestones();

  void _emit(Milestone m) {
    if (!_controller.isClosed) _controller.add(m);
  }
}
