/// External (or local) origin of a [Place].
///
/// All remote sources are public, key-less, community-maintained datasets.
enum PlaceSource {
  /// PastVu — community of history & local-lore enthusiasts publishing
  /// geotagged retro photos with dates and discussions.
  pastvu(
    title: 'PastVu',
    homepage: 'https://pastvu.com',
    license: 'Per-photo licence, see pastvu.com',
  ),

  /// Wikipedia articles with coordinates (GeoSearch API).
  wikipedia(
    title: 'Wikipedia',
    homepage: 'https://wikipedia.org',
    license: 'CC BY-SA 4.0',
  ),

  /// Wikidata items registered as Russian cultural heritage sites (P1483).
  wikidata(
    title: 'Wikidata',
    homepage: 'https://www.wikidata.org',
    license: 'CC0',
  ),

  /// OpenStreetMap objects tagged `historic=*` (Overpass API).
  osm(
    title: 'OpenStreetMap',
    homepage: 'https://www.openstreetmap.org',
    license: 'ODbL 1.0',
  ),

  /// Places created by the user; stored on device only.
  user(
    title: 'My places',
    homepage: '',
    license: '',
  );

  const PlaceSource({
    required this.title,
    required this.homepage,
    required this.license,
  });

  final String title;
  final String homepage;
  final String license;

  bool get isRemote => this != PlaceSource.user;

  static PlaceSource parse(String? raw) => PlaceSource.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => PlaceSource.user,
      );

  static List<PlaceSource> get remote => PlaceSource.values.where((s) => s.isRemote).toList();
}
