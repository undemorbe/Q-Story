import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/places/domain/services/place_share.dart';

void main() {
  test('includes title, years, summary, link and QStory code', () {
    const p = Place(
      source: PlaceSource.pastvu,
      sourceId: '5',
      title: 'Невский проспект',
      lat: 59.93,
      lon: 30.33,
      summary: 'Вид на Казанский собор',
      url: 'https://pastvu.com/p/5',
      yearStart: 1900,
      yearEnd: 1905,
    );
    expect(
      PlaceShare.text(p).split('\n'),
      [
        'Невский проспект',
        '1900 — 1905',
        'Вид на Казанский собор',
        'https://pastvu.com/p/5',
        'QStory: qstory:pastvu:5'
      ],
    );
  });

  test('falls back to an OpenStreetMap link when there is no URL', () {
    const p = Place(source: PlaceSource.osm, sourceId: 'node/1', title: 'Памятник', lat: 59.9, lon: 30.3);
    final text = PlaceShare.text(p);
    expect(text, contains(PlaceShare.osmLink(59.9, 30.3)));
    expect(text, contains('qstory:osm:node/1'));
  });

  test('user places carry no lookup code', () {
    const p = Place(source: PlaceSource.user, sourceId: 'u1', title: 'Мой двор', lat: 1, lon: 2);
    expect(PlaceShare.text(p), isNot(contains('qstory:')));
  });

  test('places without location and URL get only title', () {
    const p = Place(source: PlaceSource.user, sourceId: 'u1', title: 'X', lat: 0, lon: 0);
    expect(PlaceShare.text(p), 'X');
  });

  test('long summaries are clipped with an ellipsis', () {
    final p = Place(source: PlaceSource.osm, sourceId: '1', title: 'T', lat: 1, lon: 1, summary: 'а' * 1000);
    final line = PlaceShare.text(p).split('\n')[1];
    expect(line.length, PlaceShare.maxSummaryLength);
    expect(line, endsWith('…'));
  });

  test('osmLink uses 6 decimals and zoom 18', () {
    expect(PlaceShare.osmLink(1.5, -2.25),
        'https://www.openstreetmap.org/?mlat=1.500000&mlon=-2.250000#map=18/1.500000/-2.250000');
  });
}
