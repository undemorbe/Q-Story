import '../../../../core/util/result.dart';
import '../entities/place.dart';
import '../entities/place_query.dart';
import '../entities/place_source.dart';

abstract interface class PlacesRepository {
  /// Fans out [query] to every source in [sources] in parallel, merges and
  /// de-duplicates results, sorts them by distance. Falls back to the local
  /// cache when every source fails. [forceRefresh] skips the fresh-cache
  /// shortcut and always asks the network (cache is still a fallback).
  Future<NearbyPlaces> nearby(PlaceQuery query, {required Set<PlaceSource> sources, bool forceRefresh = false});

  /// Full details of a single place. Uses cache first when [preferCache].
  Future<Result<Place>> details(PlaceSource source, String sourceId, {String language, bool preferCache});

  /// Last known copy of a place from any source (cache, user places).
  Future<Place?> cached(String placeId);

  /// Stores a place in the cache (e.g. an inline QR place).
  Future<void> remember(Place place);

  // ─── User places (local only) ────────────────────────────────────────────
  Future<List<Place>> userPlaces();

  /// Places from the most recently loaded map area (from the local cache,
  /// no network), closest to that area's centre first.
  Future<List<Place>> recentlyLoaded({int limit = 60});
  Future<void> saveUserPlace(Place place);
  Future<void> deleteUserPlace(String sourceId);
}
