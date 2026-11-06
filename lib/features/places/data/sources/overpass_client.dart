import 'package:dio/dio.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import 'place_source_client.dart';

/// OpenStreetMap objects tagged `historic=*` (plus museums) via Overpass.
///
/// Public Overpass instances are frequently overloaded or region-blocked,
/// so the client walks through a list of mirrors until one answers.
class OverpassClient implements PlaceSourceClient {
  OverpassClient(this._dio, {List<String>? mirrors}) : mirrors = mirrors ?? defaultMirrors;

  final Dio _dio;
  final List<String> mirrors;

  static const defaultMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  /// Index of the last mirror that answered; tried first next time.
  int _preferred = 0;

  @override
  PlaceSource get source => PlaceSource.osm;

  String buildNearbyQuery(PlaceQuery q) {
    final around = '(around:${q.radiusM},${q.lat},${q.lon})';
    return '[out:json][timeout:25];('
        'nwr["historic"]["name"]$around;'
        'nwr["tourism"="museum"]["name"]$around;'
        ');out center tags ${q.limitPerSource};';
  }

  Future<List<Place>> _run(String ql) async {
    Object? lastError;
    for (var i = 0; i < mirrors.length; i++) {
      final idx = (_preferred + i) % mirrors.length;
      try {
        final res = await _dio.post<dynamic>(
          mirrors[idx],
          data: {'data': ql},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        final data = res.data;
        if (data is! Map) throw const FormatException('Overpass: not JSON');
        _preferred = idx;
        return ((data['elements'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => parseElement(Map<String, dynamic>.from(e)))
            .whereType<Place>()
            .toList();
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? StateError('No Overpass mirrors configured');
  }

  @override
  Future<List<Place>> nearby(PlaceQuery query) => _run(buildNearbyQuery(query));

  /// [sourceId] is `node/123`, `way/456` or `relation/789`.
  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    final m = RegExp(r'^(node|way|relation)/(\d+)$').firstMatch(sourceId);
    if (m == null) return null;
    final list = await _run('[out:json][timeout:25];${m.group(1)}(${m.group(2)});out center tags;');
    return list.isEmpty ? null : list.first;
  }

  static PlaceCategory _category(Map<String, dynamic> tags) {
    if (tags['tourism'] == 'museum') return PlaceCategory.museum;
    switch (tags['historic']) {
      case 'monument':
      case 'statue':
        return PlaceCategory.monument;
      case 'memorial':
      case 'tomb':
      case 'grave':
        return tags['memorial'] == 'statue' || tags['memorial'] == 'bust'
            ? PlaceCategory.monument
            : PlaceCategory.memorial;
      case 'castle':
      case 'fort':
      case 'city_gate':
      case 'citywalls':
      case 'tower':
      case 'battlefield':
        return PlaceCategory.fortification;
      case 'archaeological_site':
      case 'ruins':
        return PlaceCategory.archaeology;
      case 'church':
      case 'monastery':
      case 'wayside_shrine':
      case 'wayside_cross':
        return PlaceCategory.religious;
      case 'building':
      case 'manor':
      case 'house':
      case 'palace':
        return PlaceCategory.building;
    }
    return guessCategory('${tags['name'] ?? ''}');
  }

  Place? parseElement(Map<String, dynamic> e) {
    final tags = Map<String, dynamic>.from((e['tags'] as Map?) ?? const {});
    final name = (tags['name:ru'] ?? tags['name']) as String?;
    if (name == null || name.trim().isEmpty) return null;
    final center = e['center'] as Map?;
    final lat = (e['lat'] ?? center?['lat']) as num?;
    final lon = (e['lon'] ?? center?['lon']) as num?;
    if (lat == null || lon == null) return null;
    final type = e['type'] as String? ?? 'node';
    final id = e['id'];

    final subject = tags['memorial:subject'] ?? tags['subject'];
    final description = <String>[
      if (tags['description'] != null) tags['description'] as String,
      if (subject != null) 'Посвящено: $subject',
      if (tags['inscription'] != null) '«${tags['inscription']}»',
      if (tags['architect'] != null) 'Архитектор: ${tags['architect']}',
      if (tags['artist_name'] != null) 'Автор: ${tags['artist_name']}',
    ];
    final links = <String>[];
    final wiki = tags['wikipedia'] as String?;
    if (wiki != null && wiki.contains(':')) {
      final i = wiki.indexOf(':');
      links.add(
          'https://${wiki.substring(0, i)}.wikipedia.org/wiki/${Uri.encodeComponent(wiki.substring(i + 1).replaceAll(' ', '_'))}');
    }
    if (tags['wikidata'] != null) links.add('https://www.wikidata.org/wiki/${tags['wikidata']}');
    if (tags['website'] != null) links.add(tags['website'] as String);

    final historic = tags['historic'] as String?;
    return Place(
      source: PlaceSource.osm,
      sourceId: '$type/$id',
      title: name.trim(),
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      summary: description.isNotEmpty ? description.first : (historic ?? ''),
      description: description.isEmpty ? null : description.join('\n\n'),
      url: 'https://www.openstreetmap.org/$type/$id',
      category: _category(tags),
      yearStart: parseYear(tags['start_date']),
      author: (tags['architect'] ?? tags['artist_name']) as String?,
      links: links,
    );
  }
}
