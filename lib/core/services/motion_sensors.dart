import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// A single GPS fix, decoupled from the geolocator type for testability.
class GeoFix {
  const GeoFix({
    required this.lat,
    required this.lon,
    required this.time,
    this.accuracyM = 0,
    this.speedMps = 0,
    this.headingDeg,
  });

  final double lat;
  final double lon;
  final DateTime time;
  final double accuracyM;
  final double speedMps;
  final double? headingDeg;
}

enum LocationAccess { granted, denied, deniedForever, serviceDisabled }

/// Platform sensors used by tracking. Swap with a fake in tests.
abstract interface class MotionSensors {
  Future<LocationAccess> ensureLocationAccess();

  /// One-shot position (null on failure).
  Future<GeoFix?> currentFix();

  /// Continuous positions. When [background] is true, Android runs a
  /// foreground service with a persistent notification and iOS keeps
  /// receiving updates while the app is in the background.
  Stream<GeoFix> positions({required bool background, int distanceFilterM = 5});

  /// Ask for step-counter access (Android ACTIVITY_RECOGNITION / iOS Motion).
  Future<bool> ensureStepAccess();

  /// Cumulative step count since device boot.
  Stream<int> stepCount();

  Future<void> openLocationSettings();
  Future<void> openAppSettings();
}

class DeviceMotionSensors implements MotionSensors {
  @override
  Future<LocationAccess> ensureLocationAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceDisabled;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return switch (p) {
      LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.denied,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      LocationPermission.whileInUse || LocationPermission.always => LocationAccess.granted,
    };
  }

  @override
  Future<GeoFix?> currentFix() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return _toFix(p);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        return last == null ? null : _toFix(last);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Stream<GeoFix> positions({required bool background, int distanceFilterM = 5}) {
    final LocationSettings settings;
    if (!kIsWeb && Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilterM,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: background
            ? const ForegroundNotificationConfig(
                notificationTitle: 'QStory',
                notificationText: 'Записываем прогулку и шаги',
                notificationChannelName: 'Трекинг прогулки',
                setOngoing: true,
                enableWakeLock: true,
              )
            : null,
      );
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilterM,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: !background,
        allowBackgroundLocationUpdates: background,
        showBackgroundLocationIndicator: background,
      );
    } else {
      settings = LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: distanceFilterM);
    }
    return Geolocator.getPositionStream(locationSettings: settings).map(_toFix);
  }

  @override
  Future<bool> ensureStepAccess() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final s = await Permission.activityRecognition.request();
      return s.isGranted;
    }
    if (Platform.isIOS) {
      final s = await Permission.sensors.request();
      return s.isGranted || s.isLimited;
    }
    return false;
  }

  @override
  Stream<int> stepCount() => Pedometer.stepCountStream.map((e) => e.steps);

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  static GeoFix _toFix(Position p) => GeoFix(
        lat: p.latitude,
        lon: p.longitude,
        time: p.timestamp,
        accuracyM: p.accuracy,
        speedMps: p.speed < 0 ? 0 : p.speed,
        headingDeg: p.heading < 0 ? null : p.heading,
      );
}
