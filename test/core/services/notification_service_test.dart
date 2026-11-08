import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/services/daily_reminder.dart';
import 'package:qstory/core/services/notification_service.dart';
import 'package:qstory/core/storage/app_preferences.dart';
import 'package:qstory/core/util/result.dart';
import 'package:qstory/features/history/domain/entities/daily_fact_entity.dart';
import 'package:qstory/features/history/domain/repositories/daily_fact_repository.dart';
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
  Future<void> show(int id, String title, String body, {required String channelName}) async =>
      shown.add((id, title, body));

  @override
  Future<void> cancel(Iterable<int> ids) async {
    cancelled.addAll(ids);
    ids.forEach(scheduled.remove);
  }
}

class FakeFacts implements DailyFactRepository {
  final requests = <(int, int)>[];
  Result<List<DailyFactEntity>> Function(int month, int day) answer = (m, d) =>
      Ok([DailyFactEntity(year: 1900 + d, text: 'Event on $d.$m')]);

  @override
  Future<Result<List<DailyFactEntity>>> getFactsForDate(int month, int day) async {
    requests.add((month, day));
    return answer(month, day);
  }
}

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

    test('uses a fact for its own date only', () {
      final facts = {
        DailyReminder.dateKey(DateTime(2026, 3, 8)): [const DailyFactEntity(year: 1917, text: 'Something happened')],
      };
      final p = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: facts);
      expect(p[0].title, isNot(contains('1917')));
      expect(p[1].title, ru.reminderFactTitle('1917'));
      expect(p[1].body, 'Something happened');
      expect(p[2].title, isNot(contains('1917')));
    });

    test('the pick is stable across re-plans', () {
      final facts = {
        DailyReminder.dateKey(DateTime(2026, 3, 7)): [
          for (var y = 1800; y < 1810; y++) DailyFactEntity(year: y, text: 'e$y'),
        ],
      };
      final a = DailyReminder.plan(now: now, hour: 18, minute: 0, l: ru, facts: facts);
      final b = DailyReminder.plan(now: now.add(const Duration(hours: 1)), hour: 18, minute: 0, l: ru, facts: facts);
      expect(a.first.body, b.first.body);
    });

    test('generic texts cover five variants', () {
      final titles = {for (var i = 0; i < 10; i++) DailyReminder.generic(en, i).$1};
      expect(titles, hasLength(5));
    });

    test('clip keeps short text and shortens long text with an ellipsis', () {
      expect(DailyReminder.clip('  short  '), 'short');
      final long = DailyReminder.clip('x' * 500);
      expect(long.length, lessThanOrEqualTo(180));
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

    test('in Russian the first days carry real facts', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(ru);
      expect(facts.requests, hasLength(NotificationService.factDays));
      expect(facts.requests.first, (3, 7));
      expect(notifier.scheduled[DailyReminder.baseId]!.title, ru.reminderFactTitle('1907'));
      expect(notifier.scheduled[DailyReminder.baseId + NotificationService.factDays]!.title, isNot(contains('году')));
    });

    test('in English no facts are fetched', () async {
      await make({'notifications_enabled': true});
      await service.reschedule(en);
      expect(facts.requests, isEmpty);
      expect(notifier.scheduled, hasLength(DailyReminder.days));
    });

    test('a failing fact source falls back to generic texts', () async {
      await make({'notifications_enabled': true});
      facts.answer = (m, d) => const Err(NetworkFailure());
      await service.reschedule(ru);
      expect(notifier.scheduled, hasLength(DailyReminder.days));
      expect(notifier.scheduled.values.every((p) => p.body.isNotEmpty), isTrue);
    });

    test('test notification uses a generic text', () async {
      await make();
      await service.showTest(en);
      expect(notifier.shown.single.$1, 0);
      expect(notifier.shown.single.$2, isNotEmpty);
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
