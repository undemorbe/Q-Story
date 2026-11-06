import 'package:dio/dio.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import 'place_source_client.dart';

/// Wikidata items that are registered Russian cultural heritage sites
/// (property P1483, "kulturnoe-nasledie.ru ID"), queried with SPARQL.
class WikidataClient implements PlaceSourceClient {
  WikidataClient(this._dio, {this.endpoint = 'https://query.wikidata.org/sparql'});

  final Dio _dio;
  final String endpoint;

  @override
  PlaceSource get source => PlaceSource.wikidata;

  static String _select(String lang) => '''
SELECT ?item ?itemLabel ?itemDescription ?coord ?image ?inception ?heritage ?article WHERE {
  %PATTERN%
  OPTIONAL { ?item wdt:P1483 ?heritage . }
  OPTIONAL { ?item wdt:P18 ?image . }
  OPTIONAL { ?item wdt:P571 ?inception . }
  OPTIONAL { ?article schema:about ?item ; schema:isPartOf <https://$lang.wikipedia.org/> . }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "$lang,en,ru". }
}''';

  String buildNearbyQuery(PlaceQuery q) {
    final pattern = '''
SERVICE wikibase:around {
    ?item wdt:P625 ?coord .
    bd:serviceParam wikibase:center "Point(${q.lon} ${q.lat})"^^geo:wktLiteral .
    bd:serviceParam wikibase:radius "${(q.radiusM / 1000).toStringAsFixed(2)}" .
  }
  ?item wdt:P1483 ?h .''';
    return '${_select(q.language).replaceFirst('%PATTERN%', pattern)}\nLIMIT ${q.limitPerSource * 2}';
  }

  String buildItemQuery(String qid, String lang) {
    final pattern = 'VALUES ?item { wd:$qid } ?item wdt:P625 ?coord .';
    return '${_select(lang).replaceFirst('%PATTERN%', pattern)}\nLIMIT 5';
  }

  Future<List<Place>> _run(String sparql, {int? limit}) async {
    final res = await _dio.get<dynamic>(
      endpoint,
      queryParameters: {'query': sparql, 'format': 'json'},
      options: Options(headers: {'Accept': 'application/sparql-results+json'}),
    );
    final data = res.data;
    if (data is! Map) throw const FormatException('Wikidata: unexpected response');
    final bindings = (data['results']?['bindings'] as List?) ?? const [];
    final byId = <String, Place>{};
    for (final b in bindings.whereType<Map>()) {
      final place = parseBinding(b);
      if (place == null) continue;
      final prev = byId[place.sourceId];
      if (prev == null || place.richness > prev.richness) byId[place.sourceId] = place;
      if (limit != null && byId.length >= limit) break;
    }
    return byId.values.toList();
  }

  @override
  Future<List<Place>> nearby(PlaceQuery query) => _run(buildNearbyQuery(query), limit: query.limitPerSource);

  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    if (!RegExp(r'^Q\d+$').hasMatch(sourceId)) return null;
    final list = await _run(buildItemQuery(sourceId, language));
    return list.isEmpty ? null : list.first;
  }

  static String? _v(Map b, String key) => (b[key] as Map?)?['value'] as String?;

  Place? parseBinding(Map b) {
    final item = _v(b, 'item');
    final coord = _v(b, 'coord');
    if (item == null || coord == null) return null;
    final m = RegExp(r'Point\(([-\d.]+) ([-\d.]+)\)').firstMatch(coord);
    if (m == null) return null;
    final qid = item.split('/').last;
    final label = _v(b, 'itemLabel') ?? qid;
    final desc = _v(b, 'itemDescription') ?? '';
    final image = _v(b, 'image');
    final heritage = _v(b, 'heritage');
    final article = _v(b, 'article');
    return Place(
      source: PlaceSource.wikidata,
      sourceId: qid,
      title: label,
      lon: double.parse(m.group(1)!),
      lat: double.parse(m.group(2)!),
      summary: desc,
      description: [
        if (desc.isNotEmpty) desc,
        if (heritage != null) 'Объект культурного наследия, № ЕГРОКН $heritage',
      ].join('\n\n'),
      imageUrl: image == null ? null : '${image.replaceFirst('http://', 'https://')}?width=800',
      url: 'https://www.wikidata.org/wiki/$qid',
      category: guessCategory('$label $desc', fallback: PlaceCategory.building),
      yearStart: parseYear(_v(b, 'inception')),
      links: [if (article != null) article],
    );
  }
}
