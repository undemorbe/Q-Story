import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_query.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

void main() {
  const full = Place(
    source: PlaceSource.wikipedia,
    sourceId: 'ru:42',
    title: 'Казанский собор',
    lat: 59.934,
    lon: 30.324,
    summary: 'Собор',
    description: 'Длинное описание',
    imageUrl: 'https://img',
    url: 'https://ru.wikipedia.org/wiki/K',
    category: PlaceCategory.religious,
    yearStart: 1801,
    yearEnd: 1811,
    author: 'Воронихин',
    links: ['https://a', 'https://b'],
  );

  group('Place', () {
    test('id combines source and source id', () {
      expect(full.id, 'wikipedia:ru:42');
    });

    test('JSON round-trip keeps every field', () {
      final back = Place.fromJson(full.toJson());
      expect(back.toJson(), full.toJson());
      expect(back.id, full.id);
    });

    test('fromJson tolerates missing fields and numeric ids', () {
      final p = Place.fromJson({'source': 'osm', 'sourceId': 12, 'lat': 1});
      expect(p.sourceId, '12');
      expect(p.title, '');
      expect(p.lon, 0);
      expect(p.category, PlaceCategory.other);
      expect(p.links, isEmpty);
    });

    test('unknown source falls back to user', () {
      expect(Place.fromJson({'source': 'geocaching', 'sourceId': 'x'}).source, PlaceSource.user);
    });

    test('yearLabel', () {
      expect(full.yearLabel, '1801 — 1811');
      expect(full.copyWith(yearEnd: 1801).yearLabel, '1801');
      expect(
        const Place(source: PlaceSource.osm, sourceId: '1', title: '', lat: 0, lon: 0, yearEnd: 1900).yearLabel,
        '1900',
      );
      expect(const Place(source: PlaceSource.osm, sourceId: '1', title: '', lat: 0, lon: 0).yearLabel, isNull);
    });

    test('hasLocation is false only for (0, 0)', () {
      expect(full.hasLocation, isTrue);
      expect(full.copyWith(lat: 0, lon: 0).hasLocation, isFalse);
      expect(full.copyWith(lat: 0, lon: 1).hasLocation, isTrue);
    });

    test('body prefers a non-blank description', () {
      expect(full.body, 'Длинное описание');
      expect(full.copyWith(description: '   ').body, 'Собор');
    });

    test('richness rewards images, text and dates', () {
      const bare = Place(source: PlaceSource.osm, sourceId: '1', title: 'x', lat: 1, lon: 1);
      expect(bare.richness, 0);
      expect(bare.copyWith(imageUrl: 'i').richness, 2);
      expect(bare.copyWith(summary: 's', yearStart: 1900).richness, 2);
      expect(bare.copyWith(description: 'x' * 201).richness, 2);
    });

    test('copyWith keeps identity', () {
      final c = full.copyWith(title: 'Другое');
      expect(c.id, full.id);
      expect(c.title, 'Другое');
      expect(c.lat, full.lat);
    });
  });

  group('PlaceCategory.parse', () {
    test('known and unknown names', () {
      expect(PlaceCategory.parse('museum'), PlaceCategory.museum);
      expect(PlaceCategory.parse(null), PlaceCategory.other);
      expect(PlaceCategory.parse('spaceport'), PlaceCategory.other);
    });
  });

  group('PlaceSource', () {
    test('remote excludes user places', () {
      expect(PlaceSource.remote, isNot(contains(PlaceSource.user)));
      expect(PlaceSource.remote, hasLength(PlaceSource.values.length - 1));
    });

    test('parse', () {
      for (final s in PlaceSource.values) {
        expect(PlaceSource.parse(s.name), s);
      }
    });

    test('every remote source has a homepage and a licence', () {
      for (final s in PlaceSource.remote) {
        expect(s.homepage, startsWith('https://'), reason: s.name);
        expect(s.license, isNotEmpty, reason: s.name);
      }
    });
  });

  test('NearbyPlaces.countBySource', () {
    final n = NearbyPlaces(
      places: [
        full,
        full.copyWith(title: 'b'),
        const Place(source: PlaceSource.osm, sourceId: '1', title: 'c', lat: 1, lon: 1),
      ],
    );
    expect(n.countBySource, {PlaceSource.wikipedia: 2, PlaceSource.osm: 1});
  });
}
