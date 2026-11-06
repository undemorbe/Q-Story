import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';

/// Contract every external data provider implements.
///
/// Implementations throw on transport/format errors; the repository is
/// responsible for turning those into per-source failures.
abstract interface class PlaceSourceClient {
  PlaceSource get source;

  /// Places around [query] point.
  Future<List<Place>> nearby(PlaceQuery query);

  /// Full details of a single place by its source-specific id
  /// (the part after `<source>:` in [Place.id]). Returns null if not found.
  Future<Place?> fetch(String sourceId, {String language = 'ru'});
}

/// Keyword-based category guess for free-text titles/descriptions.
PlaceCategory guessCategory(String text, {PlaceCategory fallback = PlaceCategory.other}) {
  final t = text.toLowerCase();
  bool any(List<String> keys) => keys.any(t.contains);
  if (any([
    'церк',
    'собор',
    'храм',
    'часовн',
    'монастыр',
    'мечет',
    'синагог',
    'кирх',
    'church',
    'cathedral',
    'chapel',
    'monastery',
    'mosque'
  ])) {
    return PlaceCategory.religious;
  }
  if (any(['музей', 'museum'])) return PlaceCategory.museum;
  if (any(['крепост', 'бастион', 'кремл', 'форт', 'башн', 'fortress', 'castle', 'fort ', 'tower'])) {
    return PlaceCategory.fortification;
  }
  if (any(['курган', 'городищ', 'стоянк', 'археолог', 'archaeolog', 'barrow'])) {
    return PlaceCategory.archaeology;
  }
  if (any(['мемориал', 'могил', 'захоронен', 'доска', 'memorial', 'grave', 'plaque'])) {
    return PlaceCategory.memorial;
  }
  if (any(['памятник', 'монумент', 'скульптур', 'бюст', 'monument', 'statue', 'bust'])) {
    return PlaceCategory.monument;
  }
  if (any(
      ['дом', 'здани', 'особняк', 'усадьб', 'дворец', 'палат', 'house', 'building', 'palace', 'manor', 'mansion'])) {
    return PlaceCategory.building;
  }
  return fallback;
}

/// First 4-digit year found in [raw] (e.g. "1890-05-01", "~1750", "1924").
int? parseYear(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  final m = RegExp(r'(-?\d{3,4})').firstMatch(raw.toString());
  return m == null ? null : int.tryParse(m.group(1)!);
}

/// Strips HTML tags and decodes the handful of entities the APIs emit.
String stripHtml(String html) => html
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&laquo;', '«')
    .replaceAll('&raquo;', '»')
    .replaceAll('&mdash;', '—')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();
