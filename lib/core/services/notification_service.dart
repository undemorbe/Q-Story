import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _notificationScheduledKey = 'notification_scheduled';

  // Historical content for notifications with Russian theme
  static final List<Map<String, String>> _historicalContent = [
    {
      'title': 'Ну что, прогуляемся?',
      'body': 'Сегодня в 1854 году родился Оскар Уайльд. Давайте узнаем больше о его времени!',
    },
    {
      'title': 'По пути истории...',
      'body': 'В этот день в 1789 году началась Французская революция. Интересный факт о том времени!',
    },
    {
      'title': 'Время путешествий!',
      'body': 'Колумб открыл Америку в 1492 году. Что еще было интересного в эпоху великих географических открытий?',
    },
    {
      'title': 'Исторический момент',
      'body': 'Сегодня в 1969 году человек впервые ступил на Луну. Пора узнать больше о космической гонке!',
    },
    {
      'title': 'Прогулка в прошлое',
      'body': 'В этот день в 1917 году произошла Великая Октябрьская революция. Давайте изучим эпоху перемен!',
    },
    {
      'title': 'История ждет!',
      'body': 'Сегодня в 1945 году закончилась Вторая мировая война. Узнайте больше о послевоенном мире.',
    },
    {
      'title': 'Время открытий',
      'body': 'В этот день в 1879 году Эдисон изобрел лампочку. Пора узнать больше об эпохе индустриализации!',
    },
    {
      'title': 'Путешествие во времени',
      'body': 'Сегодня в 1776 году была подписана Декларация независимости США. Интересный факт о становлении нации!',
    },
  ];

  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Initialize plugin
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Request permissions
    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    // Android permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // On Android 13+, exact alarms require special handling
      await androidPlugin.requestExactAlarmsPermission();
    }
    
    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification payload
    }
  }

  static Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    
    if (enabled) {
      await scheduleDailyNotification();
    } else {
      await cancelAllNotifications();
    }
  }

  static Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_notificationTimeKey) ?? '09:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, 
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    
    // Reschedule if notifications are enabled
    if (await getNotificationEnabled()) {
      await scheduleDailyNotification();
    }
  }

  static Future<void> scheduleDailyNotification() async {
    final enabled = await getNotificationEnabled();
    if (!enabled) return;

    final notificationTime = await getNotificationTime();
    final random = Random();
    final content = _historicalContent[random.nextInt(_historicalContent.length)];
    
    // Create notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_history_channel',
      'Daily History',
      channelDescription: 'Daily historical facts and interesting events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
      subtitle: 'Исторический факт дня',
      threadIdentifier: 'daily_history',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for the next occurrence of the specified time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Convert to TZDateTime
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneIdentifier = timeZoneInfo.identifier;
    final location = tz.getLocation(timeZoneIdentifier);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
    
    await _notifications.zonedSchedule(
      id: 1, // Notification ID
      title: content['title']!,
      body: content['body']!,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_history',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationScheduledKey, true);
  }

  static Future<void> showTestNotification() async {
    final random = Random();
    final content = _historicalContent[random.nextInt(_historicalContent.length)];
    
    debugPrint('Showing test notification: ${content['title']}');
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test channel for notifications',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        id: 0,
        title: content['title']!,
        body: content['body']!,
        notificationDetails: platformDetails,
        payload: 'test_notification',
      );
      debugPrint('Notification shown successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationScheduledKey, false);
  }

  static Future<void> cancelDailyNotification() async {
    await _notifications.cancel(id: 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationScheduledKey, false);
  }
}
