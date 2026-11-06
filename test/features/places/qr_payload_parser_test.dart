import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/places/domain/services/qr_payload_parser.dart';

void main() {
  QrPlaceRef ref(String raw) => QrPayloadParser.parse(raw) as QrPlaceRef;

  group('QrPayloadParser', () {
    test('qstory scheme', () {
      expect(ref('qstory:wikipedia:ru:12345'), const QrPlaceRef(PlaceSource.wikipedia, 'ru:12345'));
      expect(ref('qstory:osm:node/1'), const QrPlaceRef(PlaceSource.osm, 'node/1'));
      expect(ref('qstory://place/pastvu/42'), const QrPlaceRef(PlaceSource.pastvu, '42'));
    });

    test('unknown source in scheme is not a place', () {
      expect(QrPayloadParser.parse('qstory:foo:1'), isA<QrUnknown>());
    });

    test('Wikipedia URLs (title, mobile, curid)', () {
      expect(ref('https://ru.wikipedia.org/wiki/%D0%AD%D1%80%D0%BC%D0%B8%D1%82%D0%B0%D0%B6'),
          const QrPlaceRef(PlaceSource.wikipedia, 'ru:Эрмитаж'));
      expect(ref('https://en.m.wikipedia.org/wiki/Winter_Palace'),
          const QrPlaceRef(PlaceSource.wikipedia, 'en:Winter Palace'));
      expect(ref('https://ru.wikipedia.org/?curid=777'), const QrPlaceRef(PlaceSource.wikipedia, 'ru:777'));
    });

    test('Wikidata, OSM, PastVu URLs', () {
      expect(ref('https://www.wikidata.org/wiki/Q382133'), const QrPlaceRef(PlaceSource.wikidata, 'Q382133'));
      expect(ref('https://www.openstreetmap.org/way/123#map=19/59/30'), const QrPlaceRef(PlaceSource.osm, 'way/123'));
      expect(ref('https://pastvu.com/p/1133902'), const QrPlaceRef(PlaceSource.pastvu, '1133902'));
    });

    test('other https links are external', () {
      final t = QrPayloadParser.parse('https://example.com/a');
      expect(t, isA<QrExternalLink>());
      expect((t as QrExternalLink).uri.host, 'example.com');
    });

    test('inline JSON place', () {
      final t =
          QrPayloadParser.parse('{"title":"Дом Павлова","lat":59.9,"lon":30.3,"description":"Тут жил","year":1890}');
      final p = (t as QrInlinePlace).place;
      expect(p.title, 'Дом Павлова');
      expect(p.source, PlaceSource.user);
      expect(p.yearStart, 1890);
      expect(p.hasLocation, isTrue);
    });

    test('garbage and legacy backend UUIDs are unknown', () {
      expect(QrPayloadParser.parse(''), isA<QrUnknown>());
      expect(QrPayloadParser.parse('865a965a-9068-42ec-bdac-22455bd35ff7'), isA<QrUnknown>());
      expect(QrPayloadParser.parse('{"no":"title"}'), isA<QrUnknown>());
    });

    test('encode round-trips', () {
      const remote = Place(source: PlaceSource.osm, sourceId: 'node/5', title: 'X', lat: 1, lon: 2);
      expect(ref(QrPayloadParser.encode(remote)).placeId, remote.id);
      const mine = Place(source: PlaceSource.user, sourceId: 'abc', title: 'Мой дом', lat: 1, lon: 2);
      expect((QrPayloadParser.parse(QrPayloadParser.encode(mine)) as QrInlinePlace).place.title, 'Мой дом');
    });
  });

  test('user place survives encode → parse with the same id (regression)', () {
    const mine = Place(
      source: PlaceSource.user,
      sourceId: 'abc123',
      title: 'Мемориальная доска',
      lat: 59.9,
      lon: 30.3,
      yearStart: 1890,
      yearEnd: 1917,
      author: 'Я',
    );
    final back = QrPayloadParser.parse(QrPayloadParser.encode(mine));
    expect(back, isA<QrInlinePlace>());
    final p = (back as QrInlinePlace).place;
    expect(p.id, mine.id);
    expect(p.yearStart, 1890);
    expect(p.yearEnd, 1917);
    expect(p.author, 'Я');
  });

  test('hand-written JSON plaque gets a stable qr- id', () {
    final a = QrPayloadParser.parse('{"title":"Дом купца","lat":1,"lon":2}') as QrInlinePlace;
    final b = QrPayloadParser.parse('{"title":"Дом купца","lat":1,"lon":2}') as QrInlinePlace;
    expect(a.place.sourceId, startsWith('qr-'));
    expect(a.place.id, b.place.id);
    final withId = QrPayloadParser.parse('{"id":"plate-7","title":"Дом"}') as QrInlinePlace;
    expect(withId.place.sourceId, 'qr-plate-7');
  });

  test('JSON from another source cannot spoof a user id', () {
    final p = QrPayloadParser.parse('{"source":"osm","sourceId":"node/1","title":"X"}') as QrInlinePlace;
    expect(p.place.source, PlaceSource.user);
    expect(p.place.sourceId, startsWith('qr-'));
  });
}
