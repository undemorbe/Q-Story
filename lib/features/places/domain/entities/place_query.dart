import 'place.dart';
import 'place_source.dart';
import '../../../../core/errors/failures.dart';

/// Parameters of a "what is around this point" request.
class PlaceQuery {
  const PlaceQuery({
    required this.lat,
    required this.lon,
    this.radiusM = 2000,
    this.limitPerSource = 60,
    this.language = 'ru',
  });

  final double lat;
  final double lon;
  final int radiusM;
  final int limitPerSource;
  final String language;
}

/// Aggregated result of a fan-out query to several sources: whatever
/// succeeded plus per-source failures so the UI can explain partial data.
class NearbyPlaces {
  const NearbyPlaces({
    required this.places,
    this.failures = const {},
    this.fromCache = false,
  });

  final List<Place> places;
  final Map<PlaceSource, Failure> failures;
  final bool fromCache;

  Map<PlaceSource, int> get countBySource {
    final m = <PlaceSource, int>{};
    for (final p in places) {
      m[p.source] = (m[p.source] ?? 0) + 1;
    }
    return m;
  }
}
