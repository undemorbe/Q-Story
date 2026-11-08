import 'package:dio/dio.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import 'place_source_client.dart';

/// Wikipedia articles with coordinates via the MediaWiki GeoSearch API.
///
/// Source ids look like `ru:12345` (page id) or `ru:Эрмитаж` (title).
class WikipediaClient implements PlaceSourceClient {
  WikipediaClient(this._dio);

  final Dio _dio;

  @override
  PlaceSource get source => PlaceSource.wikipedia;

  static const int _maxRadius = 10000;
  static const int _maxDescriptionChars = 8000;

  String _api(String lang) => 'https://$lang.wikipedia.org/w/api.php';

  @override
  Future<List<Place>> nearby(PlaceQuery query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _api(query.language),
      queryParameters: {
        'action': 'query',
        'format': 'json',
        'formatversion': '2',
        'generator': 'geosearch',
        'ggscoord': '${query.lat}|${query.lon}',
        'ggsradius': query.radiusM.clamp(10, _maxRadius),
        'ggslimit': query.limitPerSource.clamp(1, 100),
        'prop': 'coordinates|pageimages|extracts|info|description',
        'inprop': 'url',
        'exintro': '1',
        'explaintext': '1',
        'exsentences': '2',
        'exlimit': 'max',
        'piprop': 'thumbnail',
        'pithumbsize': '640',
        'colimit': 'max',
      },
    );
    return _parsePages(res.data, query.language);
  }

  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    final idx = sourceId.indexOf(':');
    final lang = idx > 0 ? sourceId.substring(0, idx) : language;
    final key = idx > 0 ? sourceId.substring(idx + 1) : sourceId;
    final isPageId = int.tryParse(key) != null;
    final res = await _dio.get<Map<String, dynamic>>(
      _api(lang),
      queryParameters: {
        'action': 'query',
        'format': 'json',
        'formatversion': '2',
        if (isPageId) 'pageids': key else 'titles': key,
        'redirects': '1',
        'prop': 'coordinates|pageimages|extracts|info|description',
        'inprop': 'url',
        'explaintext': '1',
        'piprop': 'thumbnail',
        'pithumbsize': '1024',
      },
    );
    final places = _parsePages(res.data, lang, detailed: true);
    return places.isEmpty ? null : places.first;
  }

  List<Place> _parsePages(Map<String, dynamic>? data, String lang, {bool detailed = false}) {
    final pages = (data?['query']?['pages'] as List?) ?? const [];
    final out = <Place>[];
    for (final raw in pages.whereType<Map>()) {
      if (raw['missing'] == true) continue;
      final coords = raw['coordinates'];
      final c = coords is List && coords.isNotEmpty ? coords.first as Map : null;
      final title = (raw['title'] as String?) ?? '';
      final extract = ((raw['extract'] as String?) ?? '').trim();
      final shortDesc = (raw['description'] as String?) ?? '';
      var full = extract;
      if (full.length > _maxDescriptionChars) {
        full = '${full.substring(0, _maxDescriptionChars)}…';
      }
      out.add(
        Place(
          source: PlaceSource.wikipedia,
          sourceId: '$lang:${raw['pageid']}',
          title: title,
          lat: (c?['lat'] as num?)?.toDouble() ?? 0,
          lon: (c?['lon'] as num?)?.toDouble() ?? 0,
          summary: detailed
              ? (shortDesc.isNotEmpty ? shortDesc : _firstSentence(extract))
              : (extract.isNotEmpty ? extract : shortDesc),
          description: detailed ? full : null,
          imageUrl: (raw['thumbnail'] as Map?)?['source'] as String?,
          url: raw['fullurl'] as String? ?? 'https://$lang.wikipedia.org/?curid=${raw['pageid']}',
          category: guessCategory('$title $shortDesc', fallback: PlaceCategory.article),
        ),
      );
    }
    return out;
  }

  static String _firstSentence(String text) {
    final i = text.indexOf('. ');
    return i > 0 && i < 300 ? text.substring(0, i + 1) : (text.length > 300 ? '${text.substring(0, 300)}…' : text);
  }
}
