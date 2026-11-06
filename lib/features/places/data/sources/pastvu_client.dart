import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import 'place_source_client.dart';

/// PastVu (https://pastvu.com) — a community of historians and local-lore
/// enthusiasts who publish dated, geotagged retro photographs.
///
/// Public JSON API: `GET /api2?method=<name>&params=<json>`.
class PastVuClient implements PlaceSourceClient {
  PastVuClient(this._dio, {this.baseUrl = 'https://pastvu.com'});

  final Dio _dio;
  final String baseUrl;

  @override
  PlaceSource get source => PlaceSource.pastvu;

  /// API hard-limits this to 30.
  static const int _maxLimit = 30;

  String imageUrl(String file, {String size = 'd'}) => '$baseUrl/_p/$size/$file';
  String pageUrl(Object cid) => '$baseUrl/p/$cid';

  Future<Map<String, dynamic>> _call(String method, Map<String, Object?> params) async {
    final res = await _dio.get<dynamic>(
      '$baseUrl/api2',
      queryParameters: {'method': method, 'params': jsonEncode(params)},
    );
    final data = res.data is String ? jsonDecode(res.data as String) : res.data;
    if (data is! Map || data['result'] is! Map) {
      throw FormatException('PastVu: unexpected response for $method');
    }
    return Map<String, dynamic>.from(data['result'] as Map);
  }

  @override
  Future<List<Place>> nearby(PlaceQuery query) async {
    final result = await _call('photo.giveNearestPhotos', {
      'geo': [query.lat, query.lon],
      'limit': query.limitPerSource.clamp(1, _maxLimit),
      'distance': query.radiusM,
    });
    final photos = (result['photos'] as List?) ?? const [];
    return photos.whereType<Map>().map((m) => parsePhoto(Map<String, dynamic>.from(m))).whereType<Place>().toList();
  }

  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    final cid = int.tryParse(sourceId);
    if (cid == null) return null;
    final result = await _call('photo.giveForPage', {'cid': cid});
    final photo = result['photo'];
    if (photo is! Map) return null;
    return parsePhoto(Map<String, dynamic>.from(photo), detailed: true);
  }

  Place? parsePhoto(Map<String, dynamic> m, {bool detailed = false}) {
    final cid = m['cid'];
    final geo = m['geo'];
    final file = m['file'] as String?;
    if (cid == null || geo is! List || geo.length < 2) return null;
    final title = (m['title'] as String?)?.trim() ?? '';
    final year = (m['year'] as num?)?.toInt();
    final year2 = (m['year2'] as num?)?.toInt();
    final desc = m['desc'] is String ? stripHtml(m['desc'] as String) : null;
    final src = m['source'] is String ? stripHtml(m['source'] as String) : null;
    final author = m['author'] as String?;
    final links = <String>[
      if (src != null && src.startsWith('http')) src,
    ];
    final parts = [
      if (desc != null && desc.isNotEmpty) desc,
      if (src != null && src.isNotEmpty && !src.startsWith('http')) 'Источник: $src',
    ];
    return Place(
      source: PlaceSource.pastvu,
      sourceId: '$cid',
      title: title.isEmpty ? 'PastVu #$cid' : title,
      lat: (geo[0] as num).toDouble(),
      lon: (geo[1] as num).toDouble(),
      summary: year != null ? 'Фото $year${year2 != null && year2 != year ? '–$year2' : ''} г.' : '',
      description: detailed && parts.isNotEmpty ? parts.join('\n\n') : null,
      imageUrl: file != null ? imageUrl(file) : null,
      url: pageUrl(cid),
      category: PlaceCategory.photo,
      yearStart: year,
      yearEnd: year2,
      author: author,
      links: links,
    );
  }
}
