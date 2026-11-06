import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/services/motion_sensors.dart';
import 'package:qstory/core/util/geo.dart';
import 'package:qstory/features/activity/domain/services/movement_accumulator.dart';

GeoFix fix(double lat, double lon, int sec, {double acc = 5}) =>
    GeoFix(lat: lat, lon: lon, time: DateTime(2026, 1, 1, 12).add(Duration(seconds: sec)), accuracyM: acc);

void main() {
  group('Geo', () {
    test('distance of 0.001° latitude ≈ 111 m', () {
      expect(Geo.distanceM(59.0, 30.0, 59.001, 30.0), closeTo(111.2, 0.5));
    });

    test('bearing north/east', () {
      expect(Geo.bearingDeg(0, 0, 1, 0), closeTo(0, 0.01));
      expect(Geo.bearingDeg(0, 0, 0, 1), closeTo(90, 0.01));
    });

    test('formatDistance', () {
      expect(formatDistance(850), '850 m');
      expect(formatDistance(1234), '1.23 km');
      expect(formatDistance(12345), '12.3 km');
    });

    test('cellKey stable within a cell', () {
      expect(Geo.cellKey(59.93430, 30.33510), Geo.cellKey(59.93431, 30.33511));
    });
  });

  group('MovementAccumulator', () {
    test('first fix is an anchor only', () {
      final a = MovementAccumulator();
      expect(a.addFix(fix(59.0, 30.0, 0)).moved, isFalse);
    });

    test('walking adds distance and active time', () {
      final a = MovementAccumulator()..addFix(fix(59.0, 30.0, 0));
      final d = a.addFix(fix(59.0001, 30.0, 10)); // ~11 m in 10 s
      expect(d.distanceM, closeTo(11.1, 0.3));
      expect(d.activeSeconds, 10);
      expect(d.speedMps, closeTo(1.1, 0.1));
    });

    test('jitter below threshold is ignored and does not move anchor', () {
      final a = MovementAccumulator()..addFix(fix(59.0, 30.0, 0));
      expect(a.addFix(fix(59.00001, 30.0, 5)).moved, isFalse); // ~1 m
      expect(a.anchor!.lat, 59.0);
    });

    test('inaccurate fixes are dropped', () {
      final a = MovementAccumulator()..addFix(fix(59.0, 30.0, 0));
      expect(a.addFix(fix(59.001, 30.0, 60, acc: 80)).moved, isFalse);
    });

    test('vehicle speed is not counted as walking', () {
      final a = MovementAccumulator()..addFix(fix(59.0, 30.0, 0));
      expect(a.addFix(fix(59.01, 30.0, 10)).moved, isFalse); // 1.1 km in 10 s
    });

    test('long gaps count distance but not active time', () {
      final a = MovementAccumulator()..addFix(fix(59.0, 30.0, 0));
      final d = a.addFix(fix(59.001, 30.0, 600));
      expect(d.moved, isTrue);
      expect(d.activeSeconds, 0);
    });

    test('step readings: baseline, delta, reboot, implausible jump', () {
      final a = MovementAccumulator();
      expect(a.addStepReading(1000), 0);
      expect(a.addStepReading(1040), 40);
      expect(a.addStepReading(15), 15); // reboot
      expect(a.addStepReading(100000), 0); // garbage
      expect(a.addStepReading(100010), 10);
    });
  });
}
