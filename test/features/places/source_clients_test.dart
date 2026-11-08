import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/data/sources/overpass_client.dart';
import 'package:qstory/features/places/data/sources/pastvu_client.dart';
import 'package:qstory/features/places/data/sources/place_source_client.dart';
import 'package:qstory/features/places/data/sources/wikidata_client.dart';
import 'package:qstory/features/places/data/sources/wikipedia_client.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_query.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

import '../../helpers/fake_http.dart';

const q = PlaceQuery(lat: 59.9343, lon: 30.3351, radiusM: 1000, limitPerSource: 10);

void main() {
  group('helpers', () {
    test('guessCategory', () {
      expect(guessCategory('Казанский собор'), PlaceCategory.religious);
      expect(guessCategory('Памятник Пушкину'), PlaceCategory.monument);
      expect(guessCategory('Дом Зингера'), PlaceCategory.building);
      expect(guessCategory('Петропавловская крепость'), PlaceCategory.fortification);
      expect(guessCategory('Мост', fallback: PlaceCategory.article), PlaceCategory.article);
    });

    test('parseYear', () {
      expect(parseYear('1890-05-01'), 1890);
      expect(parseYear('~1750'), 1750);
      expect(parseYear(1924), 1924);
      expect(parseYear(null), isNull);
      expect(parseYear('no year'), isNull);
    });

    test('stripHtml', () {
      expect(stripHtml('a<br>b &laquo;c&raquo; <a href="x">link</a>'), 'a\nb «c» link');
    });
  });

  group('PastVuClient', () {
    test('nearby maps photos and clamps limit to 30', () async {
      final dio = fakeDio(
        (o) => {
          'result': {
            'photos': [
              {
                'cid': 1133902,
                'file': '2/t/6/x.jpg',
                'title': 'Невский',
                'geo': [59.93, 30.33],
                'year': 1924,
              },
              {'cid': 2, 'title': 'no geo'},
            ],
          },
        },
      );
      final list = await PastVuClient(dio).nearby(const PlaceQuery(lat: 1, lon: 2, limitPerSource: 100));
      expect(list, hasLength(1));
      final p = list.single;
      expect(p.id, 'pastvu:1133902');
      expect(p.imageUrl, 'https://pastvu.com/_p/d/2/t/6/x.jpg');
      expect(p.url, 'https://pastvu.com/p/1133902');
      expect(p.category, PlaceCategory.photo);
      expect(p.yearStart, 1924);
      final adapter = dio.httpClientAdapter as FakeAdapter;
      expect(adapter.requests.single.queryParameters['params'], contains('"limit":30'));
    });

    test('fetch parses description, author and source link', () async {
      final dio = fakeDio(
        (o) => {
          'result': {
            'photo': {
              'cid': 5,
              'file': 'a.jpg',
              'title': 'T',
              'geo': [1.0, 2.0],
              'year': 1900,
              'year2': 1905,
              'author': 'В.Булла',
              'desc': '27 января<br>Вариант',
              'source': '<a href="https://catalog.shm.ru/x">https://catalog.shm.ru/x</a>',
            },
          },
        },
      );
      final p = (await PastVuClient(dio).fetch('5'))!;
      expect(p.author, 'В.Булла');
      expect(p.description, contains('27 января\nВариант'));
      expect(p.links, ['https://catalog.shm.ru/x']);
      expect(p.yearLabel, '1900 — 1905');
    });

    test('fetch with non-numeric id returns null without a request', () async {
      final dio = fakeDio((o) => fail('should not be called'));
      expect(await PastVuClient(dio).fetch('abc'), isNull);
    });
  });

  group('WikipediaClient', () {
    final page = {
      'pageid': 42,
      'title': 'Казанский собор',
      'coordinates': [
        {'lat': 59.934, 'lon': 30.324},
      ],
      'thumbnail': {'source': 'https://upload/img.jpg'},
      'extract': 'Один из крупнейших храмов. Построен в 1811 году.',
      'fullurl': 'https://ru.wikipedia.org/wiki/K',
      'description': 'собор в Санкт-Петербурге',
    };

    test('nearby', () async {
      final dio = fakeDio((o) {
        expect(o.uri.host, 'ru.wikipedia.org');
        expect(o.queryParameters['ggscoord'], '59.9343|30.3351');
        return {
          'query': {
            'pages': [page],
          },
        };
      });
      final p = (await WikipediaClient(dio).nearby(q)).single;
      expect(p.id, 'wikipedia:ru:42');
      expect(p.category, PlaceCategory.religious);
      expect(p.imageUrl, 'https://upload/img.jpg');
      expect(p.summary, startsWith('Один из'));
    });

    test('fetch by title uses titles= and returns detailed', () async {
      final dio = fakeDio((o) {
        expect(o.queryParameters['titles'], 'Казанский собор');
        return {
          'query': {
            'pages': [page],
          },
        };
      });
      final p = (await WikipediaClient(dio).fetch('ru:Казанский собор'))!;
      expect(p.description, contains('1811'));
      expect(p.summary, 'собор в Санкт-Петербурге');
    });

    test('missing page returns null', () async {
      final dio = fakeDio(
        (o) => {
          'query': {
            'pages': [
              {'title': 'X', 'missing': true},
            ],
          },
        },
      );
      expect(await WikipediaClient(dio).fetch('ru:X'), isNull);
    });
  });

  group('WikidataClient', () {
    test('nearby query contains heritage filter and point', () {
      final s = WikidataClient(fakeDio((_) => null)).buildNearbyQuery(q);
      expect(s, contains('wdt:P1483'));
      expect(s, contains('Point(30.3351 59.9343)'));
      expect(s, contains('"1.00"'));
    });

    test('parses and de-duplicates bindings, keeps richest', () async {
      Map<String, Object> b({String? image}) => {
        'item': {'value': 'http://www.wikidata.org/entity/Q1'},
        'itemLabel': {'value': 'Здание городской думы'},
        'coord': {'value': 'Point(30.329 59.934)'},
        'heritage': {'value': '7810520000'},
        'inception': {'value': '1804-01-01T00:00:00Z'},
        if (image != null) 'image': {'value': image},
      };
      final dio = fakeDio(
        (_) => {
          'results': {
            'bindings': [b(), b(image: 'http://commons.wikimedia.org/wiki/Special:FilePath/a.jpg')],
          },
        },
      );
      final p = (await WikidataClient(dio).nearby(q)).single;
      expect(p.id, 'wikidata:Q1');
      expect(p.lat, 59.934);
      expect(p.lon, 30.329);
      expect(p.yearStart, 1804);
      expect(p.imageUrl, 'https://commons.wikimedia.org/wiki/Special:FilePath/a.jpg?width=800');
      expect(p.description, contains('7810520000'));
      expect(p.category, PlaceCategory.building);
    });

    test('fetch rejects malformed ids', () async {
      expect(await WikidataClient(fakeDio((_) => fail('no call'))).fetch('X1'), isNull);
    });
  });

  group('OverpassClient', () {
    final element = {
      'type': 'node',
      'id': 477027518,
      'lat': 59.9372,
      'lon': 30.3316,
      'tags': {
        'historic': 'memorial',
        'memorial': 'statue',
        'name': 'А. С. Пушкину',
        'memorial:subject': 'Александр Сергеевич Пушкин',
        'start_date': '1884',
        'wikipedia': 'ru:Памятник Пушкину',
      },
    };

    test('parses tags into a place', () {
      final p = OverpassClient(fakeDio((_) => null)).parseElement(element)!;
      expect(p.id, 'osm:node/477027518');
      expect(p.category, PlaceCategory.monument);
      expect(p.yearStart, 1884);
      expect(p.description, contains('Пушкин'));
      expect(p.links.first, startsWith('https://ru.wikipedia.org/wiki/'));
    });

    test('ways use center coordinates; unnamed elements are skipped', () {
      final c = OverpassClient(fakeDio((_) => null));
      final way = c.parseElement({
        'type': 'way',
        'id': 1,
        'center': {'lat': 1.0, 'lon': 2.0},
        'tags': {'historic': 'castle', 'name': 'Замок'},
      })!;
      expect(way.lat, 1.0);
      expect(way.category, PlaceCategory.fortification);
      expect(
        c.parseElement({
          'type': 'node',
          'id': 2,
          'lat': 1,
          'lon': 1,
          'tags': {'historic': 'yes'},
        }),
        isNull,
      );
    });

    test('falls back to the next mirror and remembers it', () async {
      final dio = fakeDio(
        (o) => o.uri.host == 'a.test'
            ? 503
            : {
                'elements': [element],
              },
      );
      final client = OverpassClient(dio, mirrors: ['https://a.test/api', 'https://b.test/api']);
      expect(await client.nearby(q), hasLength(1));
      final adapter = dio.httpClientAdapter as FakeAdapter;
      expect(adapter.requests.map((r) => r.uri.host), ['a.test', 'b.test']);
      await client.nearby(q);
      expect(adapter.requests.last.uri.host, 'b.test');
    });

    test('throws when all mirrors fail', () async {
      final client = OverpassClient(fakeDio((_) => 500), mirrors: ['https://a.test', 'https://b.test']);
      await expectLater(client.nearby(q), throwsA(anything));
    });
  });

  test('every remote source has a client', () {
    final dio = fakeDio((_) => null);
    final sources = [
      PastVuClient(dio),
      WikipediaClient(dio),
      WikidataClient(dio),
      OverpassClient(dio),
    ].map((c) => c.source).toSet();
    expect(sources, PlaceSource.remote.toSet());
  });
}
