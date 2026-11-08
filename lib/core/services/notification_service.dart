import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/history/domain/entities/daily_fact_entity.dart';
import '../../features/history/domain/repositories/daily_fact_repository.dart';
import '../l10n/app_localizations.dart';
import '../storage/app_preferences.dart';
import '../util/result.dart';
import 'daily_reminder.dart';

/// Thin wrapper over the platform notification plugin, so the scheduling
/// logic can be tested without it.
abstract class LocalNotifier {
  Future<void> init();

  /// Asks the OS for permission to post notifications. True if granted.
  Future<bool> requestPermission();
  Future<void> schedule(ReminderPlan plan, {required String channelName, required String channelDescription});
  Future<void> show(int id, String title, String body, {required String channelName});
  Future<void> cancel(Iterable<int> ids);
}

/// Optional daily reminder: off until the user turns it on (which is when
/// the OS permission is requested), scheduled with inexact alarms so no
/// special "exact alarm" permission is needed.
class NotificationService {
  NotificationService(this._prefs, this._facts, this._notifier, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppPreferences _prefs;
  final DailyFactRepository _facts;
  final LocalNotifier _notifier;
  final DateTime Function() _clock;

  /// How many upcoming days get a real "on this day" fact (one request each).
  static const factDays = 2;

  bool get enabled => _prefs.notificationsEnabled;
  TimeOfDay get time => _prefs.notificationTime;

  Future<void> init() => _notifier.init();

  /// Turns the reminder on or off. Enabling asks for permission first and
  /// returns false (staying off) if it is refused.
  Future<bool> setEnabled(bool value, AppLocalizations l) async {
    if (value && !await _notifier.requestPermission()) return false;
    await _prefs.setNotificationsEnabled(value);
    await reschedule(l);
    return true;
  }

  Future<void> setTime(TimeOfDay t, AppLocalizations l) async {
    await _prefs.setNotificationTime(t);
    await reschedule(l);
  }

  /// Cancels and re-plans the coming week. Call on start and whenever the
  /// time, the switch or the language changes.
  Future<void> reschedule(AppLocalizations l) async {
    await _notifier.cancel([
      DailyReminder.legacyId,
      for (var i = 0; i < DailyReminder.days; i++) DailyReminder.baseId + i,
    ]);
    if (!enabled) return;
    final now = _clock();
    final t = time;
    final times = DailyReminder.nextTimes(now, t.hour, t.minute);
    final facts = <int, List<DailyFactEntity>>{};
    // Facts come from Russian Wikipedia; other languages get generic texts.
    if (l.localeName.startsWith('ru')) {
      for (final at in times.take(factDays)) {
        final r = await _facts.getFactsForDate(at.month, at.day);
        if (r case Ok(:final value) when value.isNotEmpty) facts[DailyReminder.dateKey(at)] = value;
      }
    }
    for (final p in DailyReminder.plan(now: now, hour: t.hour, minute: t.minute, l: l, facts: facts)) {
      await _notifier.schedule(p, channelName: l.reminderChannel, channelDescription: l.reminderChannelDesc);
    }
  }

  Future<void> showTest(AppLocalizations l) async {
    final (title, body) = DailyReminder.generic(l, _clock().day);
    await _notifier.show(0, title, body, channelName: l.reminderChannel);
  }
}

/// [LocalNotifier] backed by flutter_local_notifications.
class PluginNotifier implements LocalNotifier {
  PluginNotifier([FlutterLocalNotificationsPlugin? plugin]) : _p = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _p;
  static const _channelId = 'daily_reminder';
  tz.Location? _location;

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      _location = tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier);
    } catch (e) {
      debugPrint('Timezone lookup failed, using UTC: $e');
      _location = tz.UTC;
    }
    await _p.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested only when the user enables reminders.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _p.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    return true;
  }

  NotificationDetails _details(String channelName, [String? description]) => NotificationDetails(
    android: AndroidNotificationDetails(_channelId, channelName, channelDescription: description),
    iOS: const DarwinNotificationDetails(threadIdentifier: _channelId),
  );

  @override
  Future<void> schedule(ReminderPlan plan, {required String channelName, required String channelDescription}) {
    final loc = _location ?? tz.UTC;
    final at = tz.TZDateTime(loc, plan.at.year, plan.at.month, plan.at.day, plan.at.hour, plan.at.minute);
    return _p.zonedSchedule(
      id: plan.id,
      title: plan.title,
      body: plan.body,
      scheduledDate: at,
      notificationDetails: _details(channelName, channelDescription),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> show(int id, String title, String body, {required String channelName}) =>
      _p.show(id: id, title: title, body: body, notificationDetails: _details(channelName));

  @override
  Future<void> cancel(Iterable<int> ids) async {
    for (final id in ids) {
      await _p.cancel(id: id);
    }
  }
}
