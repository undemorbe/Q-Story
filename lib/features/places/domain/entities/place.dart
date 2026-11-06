import 'place_source.dart';

/// Broad category used for filtering and statistics.
enum PlaceCategory {
  monument,
  memorial,
  building,
  religious,
  museum,
  archaeology,
  fortification,
  photo,
  article,
  other;

  static PlaceCategory parse(String? raw) => PlaceCategory.values.firstWhere(
        (c) => c.name == raw,
        orElse: () => PlaceCategory.other,
      );
}

/// A historical place coming from any [PlaceSource].
///
/// [id] is globally unique: `<source>:<sourceId>`, e.g. `wikipedia:ru:12345`,
/// `osm:node/477027518`, `pastvu:1133902`, `wikidata:Q382133`, `user:abc`.
class Place {
  const Place({
    required this.source,
    required this.sourceId,
    required this.title,
    required this.lat,
    required this.lon,
    this.summary = '',
    this.description,
    this.imageUrl,
    this.url,
    this.category = PlaceCategory.other,
    this.yearStart,
    this.yearEnd,
    this.author,
    this.links = const [],
  });

  final PlaceSource source;
  final String sourceId;
  final String title;
  final double lat;
  final double lon;
  final String summary;
  final String? description;
  final String? imageUrl;
  final String? url;
  final PlaceCategory category;
  final int? yearStart;
  final int? yearEnd;
  final String? author;
  final List<String> links;

  String get id => '${source.name}:$sourceId';

  bool get hasLocation => !(lat == 0 && lon == 0);

  /// "1924", "1890 — 1917" or null.
  String? get yearLabel {
    if (yearStart == null && yearEnd == null) return null;
    if (yearStart != null && yearEnd != null && yearStart != yearEnd) {
      return '$yearStart — $yearEnd';
    }
    return '${yearStart ?? yearEnd}';
  }

  /// Text used on the detail page: full description if known, else summary.
  String get body => (description != null && description!.trim().isNotEmpty) ? description! : summary;

  /// Rough "richness" score used to pick the best duplicate.
  int get richness =>
      (imageUrl != null ? 2 : 0) +
      (summary.isNotEmpty ? 1 : 0) +
      ((description?.length ?? 0) > 200 ? 2 : 0) +
      (yearStart != null ? 1 : 0);

  Place copyWith({
    String? title,
    double? lat,
    double? lon,
    String? summary,
    String? description,
    String? imageUrl,
    String? url,
    PlaceCategory? category,
    int? yearStart,
    int? yearEnd,
    String? author,
    List<String>? links,
  }) =>
      Place(
        source: source,
        sourceId: sourceId,
        title: title ?? this.title,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        summary: summary ?? this.summary,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        url: url ?? this.url,
        category: category ?? this.category,
        yearStart: yearStart ?? this.yearStart,
        yearEnd: yearEnd ?? this.yearEnd,
        author: author ?? this.author,
        links: links ?? this.links,
      );

  Map<String, Object?> toJson() => {
        'source': source.name,
        'sourceId': sourceId,
        'title': title,
        'lat': lat,
        'lon': lon,
        'summary': summary,
        'description': description,
        'imageUrl': imageUrl,
        'url': url,
        'category': category.name,
        'yearStart': yearStart,
        'yearEnd': yearEnd,
        'author': author,
        'links': links,
      };

  factory Place.fromJson(Map<String, Object?> json) => Place(
        source: PlaceSource.parse(json['source'] as String?),
        sourceId: json['sourceId'].toString(),
        title: (json['title'] as String?) ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0,
        summary: (json['summary'] as String?) ?? '',
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        url: json['url'] as String?,
        category: PlaceCategory.parse(json['category'] as String?),
        yearStart: (json['yearStart'] as num?)?.toInt(),
        yearEnd: (json['yearEnd'] as num?)?.toInt(),
        author: json['author'] as String?,
        links: ((json['links'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );

  @override
  bool operator ==(Object other) => other is Place && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Place($id, $title)';
}
