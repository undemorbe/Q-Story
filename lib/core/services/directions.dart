import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds "walk me there" links for the platform's map apps, most specific
/// first, ending with a web fallback that works everywhere.
abstract final class Directions {
  static List<Uri> uris({required double lat, required double lon, String? label, required TargetPlatform platform}) {
    final ll = '${_c(lat)},${_c(lon)}';
    final web = Uri.https('www.openstreetmap.org', '/directions', {'engine': 'fossgis_osrm_foot', 'route': ';$ll'});
    return switch (platform) {
      TargetPlatform.android => [
        // geo: hands off to whatever map app the user prefers.
        Uri.parse('geo:$ll?q=$ll${label == null ? '' : '(${Uri.encodeComponent(label)})'}'),
        web,
      ],
      TargetPlatform.iOS || TargetPlatform.macOS => [
        Uri.https('maps.apple.com', '/', {'daddr': ll, 'dirflg': 'w', 'q': ?label}),
        web,
      ],
      _ => [web],
    };
  }

  static String _c(double v) => v.toStringAsFixed(6);
}

typedef UrlOpener = Future<bool> Function(Uri uri);

Future<bool> _launchExternal(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// Tries each link in turn; returns false if no app could open any of them.
Future<bool> openDirections({
  required double lat,
  required double lon,
  String? label,
  TargetPlatform? platform,
  UrlOpener open = _launchExternal,
}) async {
  for (final uri in Directions.uris(lat: lat, lon: lon, label: label, platform: platform ?? defaultTargetPlatform)) {
    try {
      if (await open(uri)) return true;
    } catch (_) {
      // Not handled on this device — try the next one.
    }
  }
  return false;
}
