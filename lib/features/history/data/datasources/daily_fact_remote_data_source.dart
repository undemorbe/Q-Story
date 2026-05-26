import 'package:dio/dio.dart';
import '../../domain/entities/daily_fact_entity.dart';

/// Fetches "On this day" historical events from Russian Wikipedia.
///
/// Endpoint: https://ru.wikipedia.org/api/rest_v1/feed/onthisday/events/{MM}/{DD}
/// No authentication required.
class DailyFactRemoteDataSource {
  final Dio _dio;

  DailyFactRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 12);
    _dio.options.receiveTimeout = const Duration(seconds: 12);
  }

  static const _baseUrl = 'https://ru.wikipedia.org/api/rest_v1/feed/onthisday';

  /// Year filter for Russian Empire and USSR (roughly).
  /// Empire: 1721-1917, Civil war: 1918-1922, USSR: 1922-1991.
  static const _minYear = 1700;
  static const _maxYear = 1991;

  Future<List<DailyFactEntity>> fetchEventsForDate(int month, int day) async {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    final url = '$_baseUrl/events/$mm/$dd';

    final response = await _dio.get<Map<String, dynamic>>(
      url,
      options: Options(
        headers: {
          'User-Agent': 'QStory/0.1 (Flutter; contact: app@qstory.local)',
          'Accept': 'application/json',
        },
      ),
    );

    final data = response.data;
    if (data == null) return [];

    final eventsRaw = (data['events'] as List?) ?? const [];
    final results = <DailyFactEntity>[];

    for (final e in eventsRaw) {
      if (e is! Map) continue;
      final year = (e['year'] as num?)?.toInt();
      final text = (e['text'] as String?)?.trim();
      if (year == null || text == null || text.isEmpty) continue;
      if (year < _minYear || year > _maxYear) continue;

      String? imageUrl;
      String? pageTitle;
      String? pageExtract;
      String? wikiUrl;
      final pages = (e['pages'] as List?) ?? const [];
      if (pages.isNotEmpty && pages.first is Map) {
        final p = pages.first as Map;
        final thumb = p['thumbnail'];
        if (thumb is Map) {
          imageUrl = thumb['source'] as String?;
        }
        // Prefer the larger original image if present.
        final orig = p['originalimage'];
        if (orig is Map) {
          imageUrl = (orig['source'] as String?) ?? imageUrl;
        }
        final titles = p['titles'];
        if (titles is Map) {
          pageTitle = (titles['normalized'] as String?) ??
              (titles['display'] as String?);
        }
        pageTitle ??= p['title'] as String?;
        pageExtract = p['extract'] as String?;
        final urls = p['content_urls'];
        if (urls is Map) {
          final desktop = urls['desktop'];
          if (desktop is Map) {
            wikiUrl = desktop['page'] as String?;
          }
        }
      }

      results.add(DailyFactEntity(
        year: year,
        text: text,
        imageUrl: imageUrl,
        pageTitle: pageTitle,
        pageExtract: pageExtract,
        wikipediaUrl: wikiUrl,
      ));
    }

    return results;
  }
}
