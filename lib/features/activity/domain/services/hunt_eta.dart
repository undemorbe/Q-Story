/// Rough "how long until I'm there" for a hunt.
class HuntEta {
  const HuntEta({required this.duration, required this.steps, required this.speedMps});

  /// Typical urban walking speed used until the user's own pace is known.
  static const double defaultSpeedMps = 1.3;
  static const double minSpeedMps = 0.7;
  static const double maxSpeedMps = 2.2;

  /// Streets are not straight lines; real walking distance is ~25 % longer.
  static const double detourFactor = 1.25;

  final Duration duration;
  final int steps;
  final double speedMps;

  /// [straightDistanceM] is the as-the-crow-flies distance to the target.
  /// [observedSpeedMps] (if any) is clamped to a plausible walking range so
  /// a car ride or a long stop doesn't produce absurd estimates.
  static HuntEta estimate(double straightDistanceM, {double? observedSpeedMps, int stepLengthCm = 72}) {
    final speed = (observedSpeedMps ?? defaultSpeedMps).clamp(minSpeedMps, maxSpeedMps).toDouble();
    final walk = straightDistanceM <= 0 ? 0.0 : straightDistanceM * detourFactor;
    final stepM = (stepLengthCm <= 0 ? 72 : stepLengthCm) / 100;
    return HuntEta(
      duration: Duration(seconds: (walk / speed).round()),
      steps: (walk / stepM).round(),
      speedMps: speed,
    );
  }
}
