import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:url_launcher/url_launcher.dart';

import '../../features/history/data/datasources/wiki_facts_client.dart';
import '../../features/history/data/repositories/interesting_facts_repository.dart';
import '../../features/history/domain/interesting_fact.dart';
import '../l10n/app_localizations.dart';
import '../storage/app_preferences.dart';
import 'daily_reminder.dart';

/// Thin wrapper over the platform notification plugin, so the scheduling
/// logic can be tested without it.
abstract class LocalNotifier {
  Future<void> init();

  /// Asks the OS for permission to post notifications. True if granted.
  Future<bool> requestPermission();
  Future<void> schedule(ReminderPlan plan, {required String channelName, required String channelDescription});
  Future<void> show(int id, String title, String body, {required String channelName, String? url});
  Future<void> cancel(Iterable<int> ids);
}

/// Optional daily reminder: off until the user turns it on (which is when
/// the OS permission is requested), scheduled with inexact alarms so no
/// special "exact alarm" permission is needed.
///
/// Each reminder carries a curated fact (Wikipedia "Did you know", the
/// editor-selected "On this day", or a place near where the user walks);
/// tapping it opens the article.
class NotificationService {
  NotificationService(this._prefs, this._facts, this._notifier, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppPreferences _prefs;
  final InterestingFactsRepository _facts;
  final LocalNotifier _notifier;
  final DateTime Function() _clock;

  /// App starts re-plan at most this often (each plan costs ~8 requests).
  static const replanEvery = Duration(hours: 12);

  /// Delivered facts are remembered this long, so none repeats within it.
  static const memory = Duration(days: 365);

  bool get enabled => _prefs.notificationsEnabled;
  TimeOfDay get time => _prefs.notificationTime;

  Future<void> init() => _notifier.init();

  /// Turns the reminder on or off. Enabling asks for permission first and
  /// returns false (staying off) if it is refused.
  Future<bool> setEnabled(bool value, AppLocalizations l) async {
    if (value && !await _notifier.requestPermission()) return false;
    await _prefs.setNotificationsEnabled(value);
    await reschedule(l, force: true);
    return true;
  }

  Future<void> setTime(TimeOfDay t, AppLocalizations l) async {
    await _prefs.setNotificationTime(t);
    await reschedule(l, force: true);
  }

  static List<int> get _ids => [
    DailyReminder.legacyId,
    for (var i = 0; i < DailyReminder.days; i++) DailyReminder.baseId + i,
  ];

  /// Re-plans the coming week. On app start ([force] false) this is skipped
  /// if the same settings were planned less than [replanEvery] ago; changes
  /// of time, switch or language pass [force].
  Future<void> reschedule(AppLocalizations l, {bool force = false}) async {
    final now = _clock();
    final t = time;
    final lang = WikiFactsClient.langOf(l.localeName);
    final key = '$lang|${t.hour}:${t.minute}';
    final last = _prefs.reminderPlannedAt;
    if (enabled && !force && _prefs.reminderPlanKey == key && last != null && now.difference(last) < replanEvery) {
      return;
    }

    await _notifier.cancel(_ids);
    if (!enabled) {
      await _prefs.clearReminderPlan();
      return;
    }

    // Only reminders whose time has passed count as delivered.
    final delivered = <String>[];
    for (final e in _prefs.reminderFactLog) {
      final sep = e.indexOf('|');
      final at = sep > 0 ? int.tryParse(e.substring(0, sep)) : null;
      if (at == null) continue;
      final age = now.difference(DateTime.fromMillisecondsSinceEpoch(at));
      if (!age.isNegative && age < memory) delivered.add(e);
    }
    final used = {for (final e in delivered) e.substring(e.indexOf('|') + 1)};

    final times = DailyReminder.nextTimes(now, t.hour, t.minute);
    final dyk = _facts.didYouKnow(lang);
    final nearby = _facts.nearby();
    final days = Future.wait([for (final at in times) _facts.onThisDay(lang, at.month, at.day)]);
    final onThisDay = await days;
    final pool = FactPool(
      didYouKnow: await dyk,
      nearby: await nearby,
      onThisDay: {for (var i = 0; i < times.length; i++) DailyReminder.dateKey(times[i]): onThisDay[i]},
      used: used,
    );

    final plans = DailyReminder.plan(now: now, hour: t.hour, minute: t.minute, l: l, facts: pool);
    for (final p in plans) {
      await _notifier.schedule(p, channelName: l.reminderChannel, channelDescription: l.reminderChannelDesc);
    }
    await _prefs.setReminderFactLog([
      ...delivered,
      for (final p in plans)
        if (p.factId != null) '${p.at.millisecondsSinceEpoch}|${p.factId}',
    ]);
    await _prefs.setReminderPlanned(now, key);
  }

  /// Shows a reminder right away: the best current "Did you know" fact, or
  /// a generic nudge when offline.
  Future<void> showTest(AppLocalizations l) async {
    final facts = FactCurator.rank(await _facts.didYouKnow(WikiFactsClient.langOf(l.localeName)));
    final f = facts.isEmpty ? null : facts[_clock().second % facts.length];
    final (title, body) = f == null ? DailyReminder.generic(l, _clock().day) : DailyReminder.present(l, f);
    await _notifier.show(0, title, body, channelName: l.reminderChannel, url: f?.url);
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
      onDidReceiveNotificationResponse: (r) => openPayload(r.payload),
    );
    // The app was cold-started by tapping a reminder.
    final launch = await _p.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) await openPayload(launch!.notificationResponse?.payload);
  }

  /// Opens the article a reminder was about. Only https links are followed.
  static Future<void> openPayload(String? payload) async {
    final uri = payload == null ? null : Uri.tryParse(payload);
    if (uri == null || uri.scheme != 'https') return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Cannot open $uri: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    final android = _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _p.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    return true;
  }

  NotificationDetails _details(String channelName, String body, [String? description]) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      channelName,
      channelDescription: description,
      // Facts are a sentence or two: show all of it when expanded.
      styleInformation: BigTextStyleInformation(body),
    ),
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
      notificationDetails: _details(channelName, plan.body, channelDescription),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: plan.url,
    );
  }

  @override
  Future<void> show(int id, String title, String body, {required String channelName, String? url}) =>
      _p.show(id: id, title: title, body: body, notificationDetails: _details(channelName, body), payload: url);

  @override
  Future<void> cancel(Iterable<int> ids) async {
    for (final id in ids) {
      await _p.cancel(id: id);
    }
  }
}
