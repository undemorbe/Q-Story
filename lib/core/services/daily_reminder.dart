import '../../features/history/domain/interesting_fact.dart';
import '../l10n/app_localizations.dart';

/// One scheduled local notification.
class ReminderPlan {
  const ReminderPlan({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    this.factId,
    this.url,
  });
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// The [InterestingFact.id] shown, null for a generic nudge.
  final String? factId;

  /// Opened when the notification is tapped.
  final String? url;

  @override
  String toString() => 'ReminderPlan($id, $at, $title)';
}

/// Candidate facts for the coming week.
class FactPool {
  const FactPool({this.didYouKnow = const [], this.onThisDay = const {}, this.nearby = const [], this.used = const {}});

  final List<InterestingFact> didYouKnow;

  /// Keyed by [DailyReminder.dateKey]: an anniversary only fits its own date.
  final Map<int, List<InterestingFact>> onThisDay;
  final List<InterestingFact> nearby;

  /// Ids already delivered earlier; never repeated.
  final Set<String> used;
}

/// Pure planning of the daily reminder: which local times to fire at and
/// what to say. Each day prefers a different kind of fact (rotation keeps
/// the week varied) and falls back to the other kinds, then to a generic
/// nudge to go for a walk. No fact is used twice.
abstract final class DailyReminder {
  /// Notification ids used by the reminder: [baseId] … [baseId] + [days] - 1.
  static const baseId = 100;

  /// How many days ahead are scheduled. Every app start re-plans, so an
  /// active user always has a week queued.
  static const days = 7;

  /// The id used by the 1.0 repeating notification; cancelled on re-plan.
  static const legacyId = 1;

  static const _maxBody = 240;

  /// The next [count] local times at [hour]:[minute], starting today if that
  /// time is still ahead of [now].
  static List<DateTime> nextTimes(DateTime now, int hour, int minute, {int count = days}) {
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) first = DateTime(now.year, now.month, now.day + 1, hour, minute);
    // Calendar arithmetic (day + i) keeps the wall-clock time across DST.
    return [for (var i = 0; i < count; i++) DateTime(first.year, first.month, first.day + i, hour, minute)];
  }

  /// Builds the week of reminders from [facts].
  static List<ReminderPlan> plan({
    required DateTime now,
    required int hour,
    required int minute,
    required AppLocalizations l,
    FactPool facts = const FactPool(),
  }) {
    final taken = {...facts.used};
    final out = <ReminderPlan>[];
    final times = nextTimes(now, hour, minute);
    for (var i = 0; i < times.length; i++) {
      final at = times[i];
      final fact = pick(facts, at, taken);
      if (fact != null) taken.add(fact.id);
      out.add(_one(baseId + i, at, l, fact));
    }
    return out;
  }

  static const _rotation = [FactKind.didYouKnow, FactKind.onThisDay, FactKind.nearby];

  /// Best unused fact for the day [at]: kinds are tried starting from one
  /// that rotates by day of year.
  static InterestingFact? pick(FactPool facts, DateTime at, Set<String> taken) {
    final start = _dayOfYear(at) % _rotation.length;
    for (var k = 0; k < _rotation.length; k++) {
      final kind = _rotation[(start + k) % _rotation.length];
      final list = switch (kind) {
        FactKind.didYouKnow => facts.didYouKnow,
        FactKind.onThisDay => facts.onThisDay[dateKey(at)] ?? const <InterestingFact>[],
        FactKind.nearby => facts.nearby,
      };
      final ranked = FactCurator.rank(list, used: taken);
      if (ranked.isNotEmpty) return ranked.first;
    }
    return null;
  }

  static int dateKey(DateTime d) => d.month * 100 + d.day;

  static ReminderPlan _one(int id, DateTime at, AppLocalizations l, InterestingFact? f) {
    if (f == null) {
      final (title, body) = generic(l, _dayOfYear(at));
      return ReminderPlan(id: id, at: at, title: title, body: body);
    }
    final (title, body) = present(l, f);
    return ReminderPlan(id: id, at: at, title: title, body: body, factId: f.id, url: f.url);
  }

  /// Notification title and body for a fact.
  static (String, String) present(AppLocalizations l, InterestingFact f) => switch (f.kind) {
    FactKind.didYouKnow => (l.reminderDykTitle, clip(f.text)),
    FactKind.onThisDay when f.year != null => (l.reminderFactTitle('${f.year}'), clip(f.text)),
    FactKind.onThisDay => (l.reminderDykTitle, clip(f.text)),
    FactKind.nearby => (l.reminderNearbyTitle(f.title ?? ''), clip(f.text)),
  };

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
