import '../../../../core/services/motion_sensors.dart';
import '../../../../core/util/geo.dart';

/// Result of feeding one GPS fix.
class MovementDelta {
  const MovementDelta({this.distanceM = 0, this.activeSeconds = 0, this.speedMps = 0});
  final double distanceM;
  final int activeSeconds;
  final double speedMps;

  bool get moved => distanceM > 0;
  static const zero = MovementDelta();
}

/// Turns a noisy stream of GPS fixes and cumulative pedometer readings into
/// clean increments. Pure Dart, no I/O — fully unit tested.
class MovementAccumulator {
  MovementAccumulator({
    this.maxAccuracyM = 35,
    this.minStepM = 4,
    this.maxWalkingSpeedMps = 12, // > ~43 km/h means a vehicle, not walking
    this.maxGapSeconds = 90,
  });

  final double maxAccuracyM;
  final double minStepM;
  final double maxWalkingSpeedMps;
  final int maxGapSeconds;

  GeoFix? _anchor;
  int? _lastSteps;

  GeoFix? get anchor => _anchor;

  void reset() {
    _anchor = null;
    _lastSteps = null;
  }

  MovementDelta addFix(GeoFix fix) {
    if (fix.accuracyM > maxAccuracyM) return MovementDelta.zero;
    final a = _anchor;
    if (a == null) {
      _anchor = fix;
      return MovementDelta.zero;
    }
    final d = Geo.distanceM(a.lat, a.lon, fix.lat, fix.lon);
    final jitter = minStepM > fix.accuracyM * 0.5 ? minStepM : fix.accuracyM * 0.5;
    if (d < jitter) return MovementDelta.zero;

    final dt = fix.time.difference(a.time).inMilliseconds / 1000.0;
    _anchor = fix;
    if (dt <= 0) return MovementDelta.zero;
    final speed = d / dt;
    if (speed > maxWalkingSpeedMps) return MovementDelta.zero; // vehicle / GPS jump
    final active = dt <= maxGapSeconds ? dt.round() : 0;
    return MovementDelta(distanceM: d, activeSeconds: active, speedMps: speed);
  }

  /// [cumulative] is the device step counter (steps since boot).
  /// Returns the number of new steps since the previous reading.
  int addStepReading(int cumulative) {
    final last = _lastSteps;
    _lastSteps = cumulative;
    if (last == null) return 0;
    final delta = cumulative - last;
    if (delta < 0) return cumulative; // device rebooted, counter reset
    if (delta > 20000) return 0; // implausible jump, ignore
    return delta;
  }
}
