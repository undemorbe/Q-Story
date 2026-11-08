import '../../features/history/domain/entities/daily_fact_entity.dart';
import '../l10n/app_localizations.dart';

/// One scheduled local notification.
class ReminderPlan {
  const ReminderPlan({required this.id, required this.at, required this.title, required this.body});
  final int id;
  final DateTime at;
  final String title;
  final String body;

  @override
  String toString() => 'ReminderPlan($id, $at, $title)';
}

/// Pure planning of the daily reminder: which local times to fire at and
/// what to say. Days with a known "on this day" fact show that fact; the
/// rest get a rotating, honest nudge to go for a walk.
abstract final class DailyReminder {
  /// Notification ids used by the reminder: [baseId] … [baseId] + [days] - 1.
  static const baseId = 100;

  /// How many days ahead are scheduled. Every app start re-plans, so an
  /// active user always has a week queued.
  static const days = 7;

  /// The id used by the 1.0 repeating notification; cancelled on re-plan.
  static const legacyId = 1;

  static const _maxBody = 180;

  /// The next [count] local times at [hour]:[minute], starting today if that
  /// time is still ahead of [now].
  static List<DateTime> nextTimes(DateTime now, int hour, int minute, {int count = days}) {
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) first = DateTime(now.year, now.month, now.day + 1, hour, minute);
    // Calendar arithmetic (day + i) keeps the wall-clock time across DST.
    return [for (var i = 0; i < count; i++) DateTime(first.year, first.month, first.day + i, hour, minute)];
  }

  /// Builds the week of reminders. [facts] maps a date (`month * 100 + day`)
  /// to facts for that day; missing dates fall back to generic texts.
  static List<ReminderPlan> plan({
    required DateTime now,
    required int hour,
    required int minute,
    required AppLocalizations l,
    Map<int, List<DailyFactEntity>> facts = const {},
  }) {
    final times = nextTimes(now, hour, minute);
    return [for (var i = 0; i < times.length; i++) _one(baseId + i, times[i], l, facts[dateKey(times[i])])];
  }

  static int dateKey(DateTime d) => d.month * 100 + d.day;

  static ReminderPlan _one(int id, DateTime at, AppLocalizations l, List<DailyFactEntity>? facts) {
    if (facts != null && facts.isNotEmpty) {
      // Deterministic pick per day of year so re-planning doesn't flip texts.
      final f = facts[_dayOfYear(at) % facts.length];
      return ReminderPlan(id: id, at: at, title: l.reminderFactTitle('${f.year}'), body: clip(f.text));
    }
    final (title, body) = generic(l, _dayOfYear(at));
    return ReminderPlan(id: id, at: at, title: title, body: body);
  }

  /// One of five generic reminders, rotating by [n].
  static (String, String) generic(AppLocalizations l, int n) => switch (n % 5) {
    0 => (l.reminder1Title, l.reminder1Body),
    1 => (l.reminder2Title, l.reminder2Body),
    2 => (l.reminder3Title, l.reminder3Body),
    3 => (l.reminder4Title, l.reminder4Body),
    _ => (l.reminder5Title, l.reminder5Body),
  };

  static String clip(String s) {
    final t = s.trim();
    return t.length <= _maxBody ? t : '${t.substring(0, _maxBody - 1).trimRight()}…';
  }

  static int _dayOfYear(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(d.year)).inDays;
}
