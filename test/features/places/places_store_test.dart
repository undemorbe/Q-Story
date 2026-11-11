import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/places/presentation/stores/places_store.dart';

import '../../helpers/fakes.dart';

void main() {
  late TestEnv env;
  late FakeClient osm;
  late FakeClient wiki;
  late PlacesStore store;

  final monument = place('node/1', title: 'Памятник Петру', lat: 59.9343, lon: 30.3351);
  final church = place(
    'ru:2',
    source: PlaceSource.wikipedia,
    title: 'Церковь',
    category: PlaceCategory.religious,
    summary: 'Храм XVIII века',
    lat: 59.9353,
    lon: 30.3351,
  );

  setUp(() async {
    env = await TestEnv.create();
    osm = FakeClient(PlaceSource.osm, places: [monument]);
    wiki = FakeClient(PlaceSource.wikipedia, places: [church]);
    store = PlacesStore(env.placesRepo([osm, wiki]), env.journal, env.settings);
  });
  tearDown(() => env.dispose());

  test('loadAround queries sources with settings and logs the result', () async {
    await env.settings.setSearchRadiusM(2500);
    await store.loadAround(59.9343, 30.3351);
    expect(store.places, hasLength(2));
    expect(osm.lastQuery!.radiusM, 2500);
    expect(osm.lastQuery!.language, env.settings.languageCode);
    final events = await env.activity.events();
    expect(events.single.type, ActivityEventType.placesLoaded);
    expect(events.single.value, 2);
  });

  test('does not reload for small moves unless forced', () async {
    await store.loadAround(59.9343, 30.3351);
    await store.loadAround(59.9353, 30.3351); // ~110 m
    expect(osm.nearbyCalls, 1);
    await store.loadAround(59.9353, 30.3351, force: true);
    expect(osm.nearbyCalls, 2);
    await store.loadAround(59.95, 30.3351); // ~1.7 km
    expect(osm.nearbyCalls, 3);
  });

  test('shouldReload', () {
    expect(store.shouldReload(1, 1), isTrue);
  });

  test('disabled sources are skipped and failures are exposed', () async {
    await env.settings.toggleSource(PlaceSource.wikipedia, false);
    osm.error = Exception('down');
    await store.loadAround(59.9, 30.3);
    expect(wiki.nearbyCalls, 0);
    expect(store.failures.keys, [PlaceSource.osm]);
    expect(store.failures[PlaceSource.osm], isA<UnknownFailure>());
  });

  group('filters', () {
    setUp(() => store.loadAround(59.9343, 30.3351));

    test('by source and category', () {
      store.toggleSourceFilter(PlaceSource.osm);
      expect(store.filtered.map((p) => p.id), [monument.id]);
      store.toggleSourceFilter(PlaceSource.osm);
      expect(store.filtered, hasLength(2));
      store.setCategoryFilter(PlaceCategory.religious);
      expect(store.filtered.single.id, church.id);
    });

    test('search matches title and summary, case-insensitive', () {
      store.setSearchQuery('ПЕТР');
      expect(store.filtered.single.id, monument.id);
      store.setSearchQuery('xviii');
      expect(store.filtered.single.id, church.id);
      store.setSearchQuery('   ');
      expect(store.filtered, hasLength(2));
    });

    test('visited / not visited', () async {
      await env.journal.recordVisit(monument, VisitMethod.manual);
      store.setVisitFilter(VisitFilter.visited);
      expect(store.filtered.single.id, monument.id);
      store.setVisitFilter(VisitFilter.notVisited);
      expect(store.filtered.single.id, church.id);
      expect(store.isVisited(monument.id), isTrue);
    });

    test('activeFilterCount and reset', () {
      store.setVisitFilter(VisitFilter.visited);
      store.toggleSourceFilter(PlaceSource.osm);
      store.setCategoryFilter(PlaceCategory.monument);
      store.setSearchQuery('a');
      expect(store.activeFilterCount, 4);
      store.resetFilters();
      expect(store.activeFilterCount, 0);
      expect(store.filtered, hasLength(2));
    });

    test('availableCategories and countBySource', () {
      expect(store.availableCategories, [PlaceCategory.monument, PlaceCategory.religious]);
      expect(store.countBySource, {PlaceSource.osm: 1, PlaceSource.wikipedia: 1});
    });
  });

  test('nearestWithin picks the closest place inside the radius', () async {
    await store.loadAround(59.9343, 30.3351);
    expect(store.nearestWithin(59.9344, 30.3351, 40)?.id, monument.id);
    expect(store.nearestWithin(59.9352, 30.3351, 40)?.id, church.id);
    expect(store.nearestWithin(59.94, 30.3351, 40), isNull);
  });

  test('user places are added, logged and deleted', () async {
    final mine = place('u1', source: PlaceSource.user, title: 'Мой дом');
    await store.addUserPlace(mine);
    expect(store.places.first.id, mine.id);
    expect((await env.activity.events()).last.type, ActivityEventType.userPlaceCreated);
    await store.deleteUserPlace(mine);
    expect(store.places.where((p) => p.id == mine.id), isEmpty);
  });

  test('a newer loadAround wins over a slower older one', () async {
    final gate = Completer<void>();
    final moscow = place('node/9', title: 'Новое', lat: 55.75, lon: 37.61);
    osm.handler = (q) async {
      if (q.lat > 59) {
        await gate.future;
        return [monument];
      }
      return [moscow];
    };
    final first = store.loadAround(59.9343, 30.3351);
    await store.loadAround(55.75, 37.61);
    expect(store.places.map((p) => p.id), contains('osm:node/9'));
    gate.complete();
    await first;
    expect(store.places.map((p) => p.id), contains('osm:node/9'));
    expect(store.places.map((p) => p.id), isNot(contains(monument.id)));
    expect(store.isLoading, isFalse);
  });

  test('creating a user place enables the user source and survives reloads', () async {
    await env.settings.toggleSource(PlaceSource.user, false);
    store.toggleSourceFilter(PlaceSource.osm);
    final mine = place('u2', source: PlaceSource.user, title: 'Колодец', lat: 59.9343, lon: 30.3351);
    await store.addUserPlace(mine);
    expect(env.settings.enabledSources, contains(PlaceSource.user));
    expect(store.filtered.map((p) => p.id), contains(mine.id));
    await store.loadAround(59.9343, 30.3351, force: true);
    expect(store.places.where((p) => p.id == mine.id), hasLength(1));
  });

  test('details and resolve go through the repository', () async {
    osm.detail = monument.copyWith(description: 'Полное описание');
    final r = await store.details(monument);
    expect(r.valueOrNull?.description, 'Полное описание');
    final r2 = await store.resolve(PlaceSource.osm, 'node/1');
    expect(r2.isOk, isTrue);
  });
}
