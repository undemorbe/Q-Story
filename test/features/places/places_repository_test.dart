import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/core/util/result.dart';
import 'package:qstory/features/places/data/repositories/places_repository_impl.dart';
import 'package:qstory/features/places/data/sources/place_source_client.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_query.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

class FakeClient implements PlaceSourceClient {
  FakeClient(this.source, {this.places = const [], this.error, this.detail});
  @override
  final PlaceSource source;
  List<Place> places;
  Object? error;
  Place? detail;
  int nearbyCalls = 0;

  @override
  Future<List<Place>> nearby(PlaceQuery query) async {
    nearbyCalls++;
    if (error != null) throw error!;
    return places;
  }

  @override
  Future<Place?> fetch(String sourceId, {String language = 'ru'}) async {
    if (error != null) throw error!;
    return detail;
  }
}

Place place(PlaceSource s, String id, String title, double lat, double lon,
        {PlaceCategory c = PlaceCategory.monument, String? image}) =>
    Place(source: s, sourceId: id, title: title, lat: lat, lon: lon, category: c, imageUrl: image);

void main() {
  late AppDatabase db;
  late DateTime now;
  const q = PlaceQuery(lat: 59.0, lon: 30.0);

  setUp(() async {
    db = await AppDatabase.inMemory();
    now = DateTime(2026, 1, 1, 12);
  });
  tearDown(() => db.close());

  PlacesRepositoryImpl repo(List<PlaceSourceClient> clients) =>
      PlacesRepositoryImpl(database: db, clients: clients, clock: () => now);

  test('merges sources, sorts by distance, isolates failures', () async {
    final osm = FakeClient(PlaceSource.osm, places: [place(PlaceSource.osm, 'node/1', 'Далеко', 59.01, 30.0)]);
    final wiki =
        FakeClient(PlaceSource.wikipedia, places: [place(PlaceSource.wikipedia, 'ru:1', 'Близко', 59.001, 30.0)]);
    final broken = FakeClient(PlaceSource.pastvu, error: Exception('boom'));
    final r = await repo([osm, wiki, broken])
        .nearby(q, sources: {PlaceSource.osm, PlaceSource.wikipedia, PlaceSource.pastvu});
    expect(r.places.map((p) => p.title), ['Близко', 'Далеко']);
    expect(r.failures.keys, [PlaceSource.pastvu]);
    expect(r.failures[PlaceSource.pastvu], isA<UnknownFailure>());
  });

  test('disabled sources are not queried', () async {
    final osm = FakeClient(PlaceSource.osm, places: [place(PlaceSource.osm, 'node/1', 'A', 59, 30)]);
    final r = await repo([osm]).nearby(q, sources: {PlaceSource.wikipedia});
    expect(r.places, isEmpty);
    expect(osm.nearbyCalls, 0);
  });

  test('caches results within TTL and falls back to stale cache on error', () async {
    final osm = FakeClient(PlaceSource.osm, places: [place(PlaceSource.osm, 'node/1', 'A', 59, 30)]);
    final r = repo([osm]);
    await r.nearby(q, sources: {PlaceSource.osm});
    final cached = await r.nearby(q, sources: {PlaceSource.osm});
    expect(osm.nearbyCalls, 1);
    expect(cached.fromCache, isTrue);

    now = now.add(const Duration(days: 1)); // expire
    osm.error = Exception('offline');
    final stale = await r.nearby(q, sources: {PlaceSource.osm});
    expect(osm.nearbyCalls, 2);
    expect(stale.places, hasLength(1));
    expect(stale.fromCache, isTrue);
    expect(stale.failures, contains(PlaceSource.osm));
  });

  test('dedupe merges same object across sources, keeps richest, never merges photos', () {
    final list = PlacesRepositoryImpl.dedupe([
      place(PlaceSource.osm, 'node/1', 'Памятник Пушкину', 59.0, 30.0),
      place(PlaceSource.wikidata, 'Q1', 'памятник пушкину', 59.0001, 30.0, image: 'x'),
      place(PlaceSource.pastvu, '1', 'Фото', 59.0, 30.0, c: PlaceCategory.photo),
      place(PlaceSource.pastvu, '2', 'Фото', 59.0, 30.0, c: PlaceCategory.photo),
      place(PlaceSource.osm, 'node/9', 'Памятник Пушкину', 59.5, 30.0), // same name, far away
    ]);
    expect(list.map((p) => p.id), containsAll(['wikidata:Q1', 'pastvu:1', 'pastvu:2', 'osm:node/9']));
    expect(list.map((p) => p.id), isNot(contains('osm:node/1')));
  });

  test('user places are stored locally and returned for user source', () async {
    final r = repo([]);
    await r.saveUserPlace(place(PlaceSource.user, 'u1', 'Мой дом', 59.0, 30.0));
    final res = await r.nearby(q, sources: {PlaceSource.user});
    expect(res.places.single.title, 'Мой дом');
    expect((await r.details(PlaceSource.user, 'u1')).valueOrNull?.title, 'Мой дом');
    await r.deleteUserPlace('u1');
    expect(await r.userPlaces(), isEmpty);
  });

  test('details caches and serves cache when source fails', () async {
    final osm = FakeClient(PlaceSource.osm, detail: place(PlaceSource.osm, 'node/1', 'Подробно', 59, 30));
    final r = repo([osm]);
    expect((await r.details(PlaceSource.osm, 'node/1')).valueOrNull?.title, 'Подробно');
    osm.error = Exception('down');
    expect((await r.details(PlaceSource.osm, 'node/1')).valueOrNull?.title, 'Подробно');
    expect((await r.cached('osm:node/1'))?.title, 'Подробно');
  });

  test('details: not found and failure without cache', () async {
    final osm = FakeClient(PlaceSource.osm);
    expect((await repo([osm]).details(PlaceSource.osm, 'node/2')), isA<Err<Place>>());
    osm.error = Exception('x');
    final r = await repo([osm]).details(PlaceSource.osm, 'node/3');
    expect(r.failureOrNull, isA<UnknownFailure>());
  });
}
