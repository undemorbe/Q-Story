import 'package:dio/dio.dart';

import '../../domain/interesting_fact.dart';

/// Curated "interesting facts" from Wikipedia (ru / en), no API key:
///
/// * **Did you know** — the main-page block, rendered via `action=parse`
///   exactly as readers see it (teasers written and reviewed by editors).
/// * **On this day / selected** — the REST feed's editor-selected
///   anniversaries, not the full list of every event on that date.
class WikiFactsClient {
  WikiFactsClient(this._dio);

  final Dio _dio;

  static const _dykTemplate = {'ru': 'Знаете ли вы', 'en': 'Did you know'};
  static const _mainPage = {'ru': 'Заглавная страница', 'en': 'Main Page'};

  static String langOf(String localeName) => localeName.startsWith('ru') ? 'ru' : 'en';

  Future<List<InterestingFact>> didYouKnow(String lang) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://$lang.wikipedia.org/w/api.php',
      queryParameters: {
        'action': 'parse',
        'text': '{{${_dykTemplate[lang]}}}',
        'title': _mainPage[lang],
        'contentmodel': 'wikitext',
        'prop': 'text',
        'disablelimitreport': '1',
        'format': 'json',
        'formatversion': '2',
      },
    );
    final html = res.data?['parse']?['text'];
    return html is String ? parseDidYouKnow(html, lang) : const [];
  }

  Future<List<InterestingFact>> onThisDay(String lang, int month, int day) async {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    final res = await _dio.get<Map<String, dynamic>>(
      'https://$lang.wikipedia.org/api/rest_v1/feed/onthisday/selected/$mm/$dd',
    );
    return parseOnThisDay(res.data, lang, month, day);
  }

  static final _li = RegExp(r'<li>(.*?)</li>', dotAll: true);
  static final _boldLink = RegExp(r'<b>(?:(?!</b>).)*?<a href="/wiki/([^"#?]+)"', dotAll: true);

  /// Items of the rendered "Did you know" block. Only list items that bold
  /// a link to an article are teasers; navigation links are skipped.
  static List<InterestingFact> parseDidYouKnow(String html, String lang) {
    final out = <InterestingFact>[];
    for (final m in _li.allMatches(html)) {
      final raw = m.group(1)!;
      final link = _boldLink.firstMatch(raw)?.group(1);
      if (link == null) continue;
      final article = _decode(link).replaceAll('_', ' ');
      if (article.contains(':')) continue; // Wikipedia:, Help:, Template:
      var text = unescape(raw.replaceAll(RegExp(r'<[^>]+>'), ''));
      final pictured = RegExp(r'\((на илл|на фото|pictured)', caseSensitive: false).hasMatch(text);
      if (lang == 'en') {
        // "... that X?" → "…that X?" so it still reads as "Did you know…"
        text = text.replaceFirst(RegExp(r'^\s*(\.\.\.|…)\s*'), '…');
      }
      text = FactCurator.clean(text);
      if (lang == 'en' && text.startsWith('…T')) text = '…t${text.substring(2)}';
      out.add(
        InterestingFact(
          id: 'dyk:$lang:$article',
          kind: FactKind.didYouKnow,
          text: text,
          title: article,
          url: 'https://$lang.m.wikipedia.org/wiki/$link',
          hasImage: pictured,
        ),
      );
    }
    return out;
  }

  static List<InterestingFact> parseOnThisDay(Map<String, dynamic>? data, String lang, int month, int day) {
    final selected = data?['selected'];
    final items = selected is List ? selected : const [];
    final out = <InterestingFact>[];
    for (final e in items.whereType<Map>()) {
      final year = (e['year'] as num?)?.toInt();
      final text = e['text'];
      if (year == null || text is! String) continue;
      final pages = ((e['pages'] as List?) ?? const []).whereType<Map>().toList();
      final first = pages.isEmpty ? null : pages.first;
      final title = (first?['titles'] as Map?)?['normalized'] as String? ?? first?['title'] as String?;
      final url = ((first?['content_urls'] as Map?)?['mobile'] as Map?)?['page'] as String?;
      out.add(
        InterestingFact(
          id: 'otd:$lang:${month * 100 + day}:$year:${title ?? text.hashCode}',
          kind: FactKind.onThisDay,
          text: FactCurator.clean(unescape(text)),
          title: title,
          year: year,
          url: url,
          hasImage: pages.any((p) => p['thumbnail'] != null),
        ),
      );
    }
    return out;
  }

  static String _decode(String s) {
    try {
      return Uri.decodeComponent(s);
    } on ArgumentError {
      return s;
    }
  }

  static String unescape(String s) => s
      .replaceAll('&#160;', ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)))
      .replaceAll('&amp;', '&');
}
