import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/services/daily_reminder.dart';
import 'package:qstory/core/services/notification_service.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/features/history/data/repositories/interesting_facts_repository.dart';
import 'package:qstory/features/history/domain/interesting_fact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNotifier implements LocalNotifier {
  bool grant = true;
  int permissionRequests = 0;
  final scheduled = <int, ReminderPlan>{};
  final shown = <(int, String, String)>[];
  final cancelled = <int>[];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> schedule(ReminderPlan plan, {required String channelName, required String channelDescription}) async =>
      scheduled[plan.id] = plan;

  @override
  Future<void> show(int id, String title, String body, {required String channelName, String? url}) async =>
      shown.add((id, title, body));

  @override
  Future<void> cancel(Iterable<int> ids) async {
    cancelled.addAll(ids);
    ids.forEach(scheduled.remove);
  }
}

class FakeFacts implements InterestingFactsRepository {
  final requests = <String>[];
  List<InterestingFact> dyk = [];
  List<InterestingFact> near = [];
  List<InterestingFact> Function(int month, int day) otd = (m, d) => [];

  @override
  Future<List<InterestingFact>> didYouKnow(String lang) async {
    requests.add('dyk:$lang');
    return dyk;
  }

  @override
  Future<List<InterestingFact>> onThisDay(String lang, int month, int day) async {
    requests.add('otd:$lang:$month/$day');
    return otd(month, day);
  }

  @override
  Future<List<InterestingFact>> nearby() async {
    requests.add('nearby');
    return near;
  }
}

InterestingFact dyk(int i) => InterestingFact(
  id: 'dyk:$i',
  kind: FactKind.didYouKnow,
  text: 'Знаете ли вы интересный факт номер $i про город?',
  url: 'https://ru.m.wikipedia.org/wiki/A$i',
);

InterestingFact otd(int year, String text) =>
    InterestingFact(id: 'otd:$year', kind: FactKind.onThisDay, text: text, year: year);

InterestingFact near(int i) => InterestingFact(
  id: 'place:$i',
  kind: FactKind.nearby,
  text: 'Старинная усадьба номер $i построена в XIX веке.',
  title: 'Усадьба $i',
);

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final en = lookupAppLocalizations(const Locale('en'));
  // Saturday, 10:00 local.
  final now = DateTime(2026, 3, 7, 10);

  group('DailyReminder.nextTimes', () {
    test('starts today when the time is still ahead', () {
      final t = DailyReminder.nextTimes(now, 18, 30);
      expect(t, hasLength(DailyReminder.days));
      expect(t.first, DateTime(2026, 3, 7, 18, 30));
      expect(t[1], DateTime(2026, 3, 8, 18, 30));
    });

    test('starts tomorrow when the time has passed or is now', () {
      expect(DailyReminder.nextTimes(now, 9, 0).first, DateTime(2026, 3, 8, 9));
      expect(DailyReminder.nextTimes(now, 10, 0).first, DateTime(2026, 3, 8, 10));
    });

    test('crosses month and year ends keeping the wall-clock time', () {
      final t = DailyReminder.nextTimes(DateTime(2026, 12, 30, 20), 8, 15, count: 4);
      expect(t, [
        DateTime(2026, 12, 31, 8, 15),
        DateTime(2027, 1, 1, 8, 15),
        DateTime(2027, 1, 2, 8, 15),
        DateTime(2027, 1, 3, 8, 15),
      ]);
    });

    test('times are strictly increasing, one per calendar day', () {
      final t = DailyReminder.nextTimes(DateTime(2026, 3, 28, 23, 59), 0, 0, count: 10);
      for (var i = 1; i < t.length; i++) {
        expect(t[i].isAfter(t[i - 1]), isTrue);
        expect(t[i].hour, 0);
      }
      expect(t.map((d) => d.day).toSet(), hasLength(10));
    });
  });

  group('DailyReminder.plan', () {
    test('ids are consecutive from baseId', () {
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: en);
      expect(p.map((e) => e.id), [for (var i = 0; i < DailyReminder.days; i++) DailyReminder.baseId + i]);
    });

    test('without facts every day has a generic, non-empty text', () {
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: en);
      for (final r in p) {
        expect(r.title, isNotEmpty);
        expect(r.body, isNotEmpty);
      }
      // Texts rotate: consecutive days differ.
      expect(p[0].title, isNot(p[1].title));
    });

    test('an anniversary is used on its own date only', () {
      final pool = FactPool(
        onThisDay: {
          DailyReminder.dateKey(DateTime(2026, 3, 8)): [otd(1917, 'Открылся первый городской трамвай в Москве.')],
        },
      );
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: pool);
      final i = p.indexWhere((r) => r.factId == 'otd:1917');
      expect(p[i].at.day, 8);
      expect(p[i].title, ru.reminderFactTitle('1917'));
      expect(p[i].body, 'Открылся первый городской трамвай в Москве.');
      expect(p.where((r) => r.factId != null), hasLength(1));
    });

    test('kinds rotate by day and fall back to each other', () {
      final pool = FactPool(didYouKnow: [for (var i = 0; i < 10; i++) dyk(i)], nearby: [near(1), near(2), near(3)]);
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: pool);
      expect(p.every((r) => r.factId != null), isTrue);
      final kinds = p.map((r) => r.factId!.split(':').first).toSet();
      expect(kinds, {'dyk', 'place'});
      final nearbyDay = p.firstWhere((r) => r.factId!.startsWith('place:'));
      expect(nearbyDay.title, ru.reminderNearbyTitle('Усадьба 1'));
      final dykDay = p.firstWhere((r) => r.factId!.startsWith('dyk:'));
      expect(dykDay.title, ru.reminderDykTitle);
      expect(dykDay.url, startsWith('https://'));
    });

    test('no fact repeats within the week or from earlier weeks', () {
      final pool = FactPool(didYouKnow: [dyk(1), dyk(2), dyk(3)], used: {'dyk:1'});
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: en, facts: pool);
      final ids = [for (final r in p) ?r.factId];
      expect(ids.toSet(), {'dyk:2', 'dyk:3'});
      expect(ids, hasLength(2));
      // The rest of the week is generic.
      expect(p.where((r) => r.factId == null), hasLength(DailyReminder.days - 2));
    });

    test('grim facts are never sent', () {
      final pool = FactPool(
        didYouKnow: [
          const InterestingFact(
            id: 'bad',
            kind: FactKind.didYouKnow,
            text: 'В результате катастрофы погибли сотни людей.',
          ),
        ],
      );
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: pool);
      expect(p.every((r) => r.factId == null), isTrue);
    });

    test('the pick is stable across re-plans', () {
      final pool = FactPool(didYouKnow: [for (var i = 0; i < 10; i++) dyk(i)]);
      final a = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: pool);
      final b = DailyReminder.plan(now: now.add(const Duration(hours: 1)), hour: 18, minute: 0, l: ru, facts: pool);
      expect(a.map((r) => r.body), b.map((r) => r.body));
    });

    test('an anniversary without a year still has a title', () {
      final f = const InterestingFact(id: 'x', kind: FactKind.onThisDay, text: 'Что-то случилось однажды.');
      expect(DailyReminder.present(en, f).$1, en.reminderDykTitle);
    });

    test('generic texts cover five variants', () {
      final titles = {for (var i = 0; i < 10; i++) DailyReminder.generic(en, i).$1};
      expect(titles, hasLength(5));
    });

    test('clip keeps short text and shortens long text with an ellipsis', () {
      expect(DailyReminder.clip('  short  '), 'short');
      final long = DailyReminder.clip('x' * 500);
      expect(long.length, 240);
      expect(long, endsWith('…'));
    });
  });

  group('NotificationService', () {
    late AppPreferences prefs;
    late FakeNotifier notifier;
    late FakeFacts facts;
    late NotificationService service;

    Future<void> make([Map<String, Object> initial = const {}]) async {
      SharedPreferences.setMockInitialValues(initial);
      prefs = AppPreferences(await SharedPreferences.getInstance());
      notifier = FakeNotifier();
      facts = FakeFacts();
      service = NotificationService(prefs, facts, notifier, clock: () => now);
    }

    test('is off by default and schedules nothing', () async {
      await make();
      expect(service.enabled, isFalse);
      await service.reschedule(en);
      expect(notifier.scheduled, isEmpty);
      expect(notifier.permissionRequests, 0);
      // Old and current ids are always cleared.
      expect(notifier.cancelled, contains(DailyReminder.legacyId));
      expect(notifier.cancelled, contains(DailyReminder.baseId));
    });

    test('enabling asks for permission and schedules a week', () async {
      await make();
      expect(await service.setEnabled(true, en), isTrue);
      expect(notifier.permissionRequests, 1);
      expect(service.enabled, isTrue);
      expect(notifier.scheduled, hasLength(DailyReminder.days));
      // Default time is 18:00.
      expect(notifier.scheduled[DailyReminder.baseId]!.at, DateTime(2026, 3, 7, 18));
    });

    test('a refused permission keeps reminders off', () async {
      await make();
      notifier.grant = false;
      expect(await service.setEnabled(true, en), isFalse);
      expect(service.enabled, isFalse);
      expect(notifier.scheduled, isEmpty);
    });

    test('disabling cancels everything without asking', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(en);
      expect(notifier.scheduled, isNotEmpty);
      expect(await service.setEnabled(false, en), isTrue);
      expect(notifier.permissionRequests, 0);
      expect(notifier.scheduled, isEmpty);
    });

    test('changing the time re-plans at the new time', () async {
      await make({'notifications_enabled': true});
      await service.setTime(const TimeOfDay(hour: 7, minute: 45), en);
      expect(service.time, const TimeOfDay(hour: 7, minute: 45));
      expect(notifier.scheduled[DailyReminder.baseId]!.at, DateTime(2026, 3, 8, 7, 45));
    });

    test('plans from all sources in the app language', () async {
      await make({'notifications_enabled': true});
      facts.dyk = [dyk(1), dyk(2)];
      facts.otd = (m, d) => [otd(1900 + d, 'Событие $d.$m: открылся первый городской музей.')];
      facts.near = [near(1)];
      await service.reschedule(ru);
      expect(facts.requests, containsAll(['dyk:ru', 'nearby', 'otd:ru:3/7', 'otd:ru:3/13']));
      expect(facts.requests.where((r) => r.startsWith('otd')), hasLength(DailyReminder.days));
      final plans = notifier.scheduled.values.toList();
      expect(plans, hasLength(DailyReminder.days));
      expect(plans.where((p) => p.factId != null).length, greaterThanOrEqualTo(4));
      expect(prefs.reminderFactLog, hasLength(plans.where((p) => p.factId != null).length));

      await service.reschedule(en, force: true);
      expect(facts.requests, contains('dyk:en'));
    });

    test('app starts re-plan at most every 12 hours unless forced', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(en);
      final n = facts.requests.length;
      await service.reschedule(en);
      expect(facts.requests, hasLength(n));
      await service.reschedule(en, force: true);
      expect(facts.requests.length, greaterThan(n));
      // A different language is a different plan.
      final m = facts.requests.length;
      await service.reschedule(ru);
      expect(facts.requests.length, greaterThan(m));
    });

    test('delivered facts are not sent again, planned-but-unsent ones may be', () async {
      final past = now.subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      final future = now.add(const Duration(days: 1)).millisecondsSinceEpoch;
      final ancient = now.subtract(const Duration(days: 400)).millisecondsSinceEpoch;
      await make({
        'notifications_enabled': true,
        'reminder_fact_log': ['$past|dyk:1', '$future|dyk:2', '$ancient|dyk:3', 'garbage'],
      });
      facts.dyk = [dyk(1), dyk(2), dyk(3)];
      await service.reschedule(en);
      final sent = {for (final p in notifier.scheduled.values) ?p.factId};
      expect(sent, {'dyk:2', 'dyk:3'});
      expect(prefs.reminderFactLog.where((e) => e.endsWith('|dyk:1')), hasLength(1));
      expect(prefs.reminderFactLog, isNot(contains('garbage')));
    });

    test('no facts available falls back to generic texts', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(ru);
      expect(notifier.scheduled, hasLength(DailyReminder.days));
      expect(notifier.scheduled.values.every((p) => p.body.isNotEmpty && p.factId == null), isTrue);
    });

    test('disabling forgets the plan so re-enabling plans immediately', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(en);
      await service.setEnabled(false, en);
      expect(prefs.reminderPlannedAt, isNull);
    });

    test('test notification uses a generic text when offline', () async {
      await make();
      await service.showTest(en);
      expect(notifier.shown.single.$1, 0);
      expect(notifier.shown.single.$2, isNotEmpty);
    });

    test('test notification shows a "Did you know" fact when there is one', () async {
      await make();
      facts.dyk = [dyk(7)];
      await service.showTest(ru);
      expect(notifier.shown.single.$2, ru.reminderDykTitle);
      expect(notifier.shown.single.$3, dyk(7).text);
    });
  });

  group('AppPreferences notification time', () {
    Future<AppPreferences> prefsWith(Map<String, Object> v) async {
      SharedPreferences.setMockInitialValues(v);
      return AppPreferences(await SharedPreferences.getInstance());
    }

    test('round-trips and pads', () async {
      final p = await prefsWith({});
      await p.setNotificationTime(const TimeOfDay(hour: 7, minute: 5));
      expect(p.notificationTime, const TimeOfDay(hour: 7, minute: 5));
    });

    test('garbage falls back to 18:00', () async {
      for (final bad in ['', 'abc', '25:00', '10:75', '1:2']) {
        final p = await prefsWith({'notification_time': bad});
        expect(p.notificationTime, const TimeOfDay(hour: 18, minute: 0), reason: bad);
      }
    });

    test('reads the 1.0 format', () async {
      final p = await prefsWith({'notification_time': '09:00'});
      expect(p.notificationTime, const TimeOfDay(hour: 9, minute: 0));
    });
  });
}
