import '../entities/place.dart';
import '../entities/place_source.dart';

/// Plain-text card used when the user shares a place with someone.
abstract final class PlaceShare {
  static const int maxSummaryLength = 280;

  static String text(Place p) {
    final summary = p.summary.trim();
    return [
      p.title,
      if (p.yearLabel != null) p.yearLabel!,
      if (summary.isNotEmpty) _clip(summary),
      if (p.url != null && p.url!.isNotEmpty) p.url! else if (p.hasLocation) osmLink(p.lat, p.lon),
      // User places only live on this device, so there is nothing to look up.
      if (p.source != PlaceSource.user) 'QStory: qstory:${p.id}',
    ].join('\n');
  }

  static String osmLink(double lat, double lon) {
    final la = lat.toStringAsFixed(6), lo = lon.toStringAsFixed(6);
    return 'https://www.openstreetmap.org/?mlat=$la&mlon=$lo#map=18/$la/$lo';
  }

  static String _clip(String s) =>
      s.length <= maxSummaryLength ? s : '${s.substring(0, maxSummaryLength - 1).trimRight()}…';
}
