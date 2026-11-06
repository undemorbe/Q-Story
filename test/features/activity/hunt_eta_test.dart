import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/activity/domain/services/hunt_eta.dart';

void main() {
  test('uses default walking speed and detour factor', () {
    final e = HuntEta.estimate(1000);
    expect(e.speedMps, HuntEta.defaultSpeedMps);
    // 1000 m × 1.25 / 1.3 m/s ≈ 962 s
    expect(e.duration.inSeconds, closeTo(962, 1));
    // 1250 m / 0.72 m ≈ 1736 steps
    expect(e.steps, closeTo(1736, 1));
  });

  test('uses the observed pace, clamped to a walking range', () {
    expect(HuntEta.estimate(100, observedSpeedMps: 1.8).speedMps, 1.8);
    expect(HuntEta.estimate(100, observedSpeedMps: 15).speedMps, HuntEta.maxSpeedMps);
    expect(HuntEta.estimate(100, observedSpeedMps: 0.1).speedMps, HuntEta.minSpeedMps);
  });

  test('longer steps → fewer of them', () {
    expect(HuntEta.estimate(500, stepLengthCm: 90).steps, lessThan(HuntEta.estimate(500, stepLengthCm: 60).steps));
  });

  test('already there or bad input', () {
    final e = HuntEta.estimate(0);
    expect(e.duration, Duration.zero);
    expect(e.steps, 0);
    expect(HuntEta.estimate(-5).steps, 0);
    expect(HuntEta.estimate(100, stepLengthCm: 0).steps, HuntEta.estimate(100).steps);
  });
}
