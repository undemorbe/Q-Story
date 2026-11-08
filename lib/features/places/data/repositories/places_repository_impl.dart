import 'dart:async';

import 'package:sembast/sembast.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/util/geo.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import '../../domain/repositories/places_repository.dart';
import '../sources/place_source_client.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl({
    required AppDatabase database,
    required List<PlaceSourceClient> clients,
    this.cacheTtl = const Duration(hours: 12),
    this.perSourceTimeout = const Duration(seconds: 35),
    DateTime Function()? clock,
  }) : _db = database.db,
       _clients = {for (final c in clients) c.source: c},
       _now = clock ?? DateTime.now;

  final Database _db;
  final Map<PlaceSource, PlaceSourceClient> _clients;
  final Duration cacheTtl;
  final Duration perSourceTimeout;
  final DateTime Function() _now;

  /// Duplicates closer than this with similar titles are merged.
  static const double _dupDistanceM = 35;

  String _nearbyKey(PlaceQuery q, PlaceSource s) => '${s.name}|${Geo.tileKey(q.lat, q.lon)}|${q.radiusM}|${q.language}';

  @override
  Future<NearbyPlaces> nearby(PlaceQuery query, {required Set<PlaceSource> sources}) async {
    final failures = <PlaceSource, Failure>{};
    final collected = <Place>[];
    var anyFromCache = false;

    Future<void> runSource(PlaceSource s) async {
      if (s == PlaceSource.user) {
        collected.addAll(await userPlaces());
        return;
      }
      final client = _clients[s];
      if (client == null) return;
      final key = _nearbyKey(query, s);
      final cachedRec = await AppDatabase.nearbyCache.record(key).get(_db);
      final fresh =
          cachedRec != null &&
          _now().difference(DateTime.fromMillisecondsSinceEpoch(cachedRec['at'] as int)) < cacheTtl;
      if (fresh) {
        collected.addAll(_decodeList(cachedRec['places']));
        anyFromCache = true;
        return;
      }
      try {
        final list = await client.nearby(query).timeout(perSourceTimeout);
        collected.addAll(list);
        await AppDatabase.nearbyCache.record(key).put(_db, {
          'at': _now().millisecondsSinceEpoch,
          'places': list.map((p) => p.toJson()).toList(),
        });
      } catch (e) {
        failures[s] = toFailure(e is TimeoutException ? const NetworkFailure('Timeout') : e);
        if (cachedRec != null) {
          collected.addAll(_decodeList(cachedRec['places']));
          anyFromCache = true;
        }
      }
    }

    await Future.wait(sources.map(runSource));

    final merged = dedupe(collected).where((p) => p.hasLocation).toList()
      ..sort(
        (a, b) => Geo.distanceM(
          query.lat,
          query.lon,
          a.lat,
          a.lon,
        ).compareTo(Geo.distanceM(query.lat, query.lon, b.lat, b.lon)),
      );
    return NearbyPlaces(places: merged, failures: failures, fromCache: anyFromCache);
  }

  List<Place> _decodeList(Object? raw) =>
      ((raw as List?) ?? const []).whereType<Map>().map((m) => Place.fromJson(Map<String, Object?>.from(m))).toList();

  /// Removes the same real-world object reported by several sources,
  /// keeping the richest record. Photos (PastVu) are never merged:
  /// many photos of one spot are distinct historical evidence.
  static List<Place> dedupe(List<Place> input) {
    final byId = <String, Place>{};
    for (final p in input) {
      byId[p.id] = p;
    }
    final result = <Place>[];
    for (final p in byId.values) {
      if (p.category == PlaceCategory.photo) {
        result.add(p);
        continue;
      }
      final idx = result.indexWhere(
        (q) =>
            q.category != PlaceCategory.photo &&
            q.source != p.source &&
            _normalize(q.title) == _normalize(p.title) &&
            Geo.distanceM(q.lat, q.lon, p.lat, p.lon) < _dupDistanceM,
      );
      if (idx == -1) {
        result.add(p);
      } else if (p.richness > result[idx].richness) {
        result[idx] = p;
      }
    }
    return result;
  }

  static String _normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]'), '');

  @override
  Future<Result<Place>> details(
    PlaceSource source,
    String sourceId, {
    String language = 'ru',
    bool preferCache = false,
  }) async {
    final id = '${source.name}:$sourceId';
    if (source == PlaceSource.user) {
      final p = await cached(id);
      return p == null ? const Err(NotFoundFailure()) : Ok(p);
    }
    final cachedPlace = await _cachedDetailed(id);
    if (preferCache && cachedPlace != null) return Ok(cachedPlace);
    final client = _clients[source];
    if (client == null) return Err(ValidationFailure('Source ${source.name} disabled'));
    try {
      final place = await client.fetch(sourceId, language: language).timeout(perSourceTimeout);
      if (place == null) return const Err(NotFoundFailure());
      await AppDatabase.placesCache.record(place.id).put(_db, {
        ...place.toJson(),
        '_detailed': true,
        '_at': _now().millisecondsSinceEpoch,
      });
      // A title lookup (wikipedia:ru:Title) also caches under the requested id.
      if (place.id != id) {
        await AppDatabase.placesCache.record(id).put(_db, {...place.toJson(), '_detailed': true});
      }
      return Ok(place);
    } catch (e) {
      if (cachedPlace != null) return Ok(cachedPlace);
      return Err(toFailure(e));
    }
  }

  Future<Place?> _cachedDetailed(String id) async {
    final rec = await AppDatabase.placesCache.record(id).get(_db);
    if (rec == null || rec['_detailed'] != true) return null;
    return Place.fromJson(rec);
  }

  @override
  Future<Place?> cached(String placeId) async {
    final user = await AppDatabase.userPlaces.record(placeId).get(_db);
    if (user != null) return Place.fromJson(user);
    final rec = await AppDatabase.placesCache.record(placeId).get(_db);
    return rec == null ? null : Place.fromJson(rec);
  }

  @override
  Future<void> remember(Place place) async {
    final existing = await AppDatabase.placesCache.record(place.id).get(_db);
    if (existing != null && existing['_detailed'] == true) return;
    await AppDatabase.placesCache.record(place.id).put(_db, place.toJson());
  }

  @override
  Future<List<Place>> userPlaces() async {
    final recs = await AppDatabase.userPlaces.find(_db);
    return recs.map((r) => Place.fromJson(r.value)).toList();
  }

  @override
  Future<void> saveUserPlace(Place place) => AppDatabase.userPlaces.record(place.id).put(_db, place.toJson());

  @override
  Future<void> deleteUserPlace(String sourceId) =>
      AppDatabase.userPlaces.record('${PlaceSource.user.name}:$sourceId').delete(_db);
}
