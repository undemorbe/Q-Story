import 'dart:math' as math;

/// Small, dependency-free geo helpers.
abstract final class Geo {
  static const double earthRadiusM = 6371008.8;

  static double _rad(double deg) => deg * math.pi / 180.0;

  /// Great-circle distance in metres between two WGS-84 points.
  static double distanceM(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * earthRadiusM * math.asin(math.min(1.0, math.sqrt(a)));
  }

  /// Initial bearing (0..360, clockwise from north) from point 1 to point 2.
  static double bearingDeg(double lat1, double lon1, double lat2, double lon2) {
    final y = math.sin(_rad(lon2 - lon1)) * math.cos(_rad(lat2));
    final x = math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
        math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(_rad(lon2 - lon1));
    final brng = math.atan2(y, x) * 180.0 / math.pi;
    return (brng + 360.0) % 360.0;
  }

  /// Key of a roughly [cellM]×[cellM] metre grid cell containing the point.
  /// Used to measure "explored area" without storing raw tracks forever.
  static String cellKey(double lat, double lon, {double cellM = 250}) {
    final latStep = cellM / 111320.0;
    final row = (lat / latStep).floor();
    final lonStep = cellM / (111320.0 * math.cos(_rad(row * latStep)).abs().clamp(0.01, 1.0));
    final col = (lon / lonStep).floor();
    return '$row:$col';
  }

  /// Rounds coordinates to a coarse tile key for caching nearby queries.
  static String tileKey(double lat, double lon, {int decimals = 2}) =>
      '${lat.toStringAsFixed(decimals)},${lon.toStringAsFixed(decimals)}';
}

/// Formats metres as "850 m" / "1.2 km".
String formatDistance(double meters, {String m = 'm', String km = 'km'}) {
  if (meters < 1000) return '${meters.round()} $m';
  final v = meters / 1000;
  return '${v.toStringAsFixed(v < 10 ? 2 : 1)} $km';
}

/// Formats a duration as "1 h 05 min" / "12 min" / "45 s".
String formatDuration(Duration d, {String h = 'h', String min = 'min', String s = 's'}) {
  if (d.inHours > 0) {
    return '${d.inHours} $h ${(d.inMinutes % 60).toString().padLeft(2, '0')} $min';
  }
  if (d.inMinutes > 0) return '${d.inMinutes} $min';
  return '${d.inSeconds} $s';
}

/// Signed percentage for a relative change: 0.254 → "+25%", -0.1 → "−10%".
String formatChange(double ratio) {
  final pct = (ratio * 100).round();
  if (pct == 0) return '±0%';
  return pct > 0 ? '+$pct%' : '\u2212${-pct}%';
}
