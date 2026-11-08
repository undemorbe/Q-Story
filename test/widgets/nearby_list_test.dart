import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/presentation/widgets/nearby_list.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  final far = place('far', title: 'Far', lat: 59.01, lon: 30.0);
  final near = place('near', title: 'Near', lat: 59.001, lon: 30.0, year: 1884);
  final east = place('east', title: 'East', lat: 59.0, lon: 30.0015); // ~86 m

  group('NearbyItem.build', () {
    test('sorts by distance and computes bearings', () {
      final items = NearbyItem.build([far, near, east], 59.0, 30.0);
      expect(items.map((i) => i.place.title), ['East', 'Near', 'Far']);
      expect(items[1].distanceM, closeTo(111, 1));
      expect(items[1].bearingDeg, closeTo(0, 0.5));
      expect(items[0].bearingDeg, closeTo(90, 0.5));
    });

    test('keeps only the closest [limit]', () {
      final many = [for (var i = 0; i < 20; i++) place('$i', lat: 59 + i / 1000, lon: 30)];
      final items = NearbyItem.build(many, 59, 30, limit: 5);
      expect(items, hasLength(5));
      expect(items.last.place.sourceId, '4');
    });

    test('empty input', () {
      expect(NearbyItem.build(const <Place>[], 0, 0), isEmpty);
    });
  });

  testWidgets('lists places with distance, visited mark and opens on tap', (t) async {
    Place? opened;
    await t.pumpApp(
      NearbyList(items: NearbyItem.build([far, near], 59.0, 30.0), visitedIds: {near.id}, onOpen: (p) => opened = p),
    );
    expect(find.text('2 places nearby'), findsOneWidget);
    expect(find.text('Near'), findsOneWidget);
    expect(find.text('111 m'), findsOneWidget);
    expect(find.textContaining('1884'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Distances from the map centre — turn on location for distances from you.'), findsNothing);

    await t.tap(find.text('Far'));
    expect(opened?.id, far.id);
  });

  testWidgets('empty state and map-centre note', (t) async {
    await t.pumpApp(NearbyList(items: const [], visitedIds: const {}, onOpen: (_) {}, fromMyLocation: false));
    expect(find.text('No places nearby'), findsOneWidget);
    expect(find.textContaining('map centre'), findsOneWidget);
    expect(find.textContaining('Nothing found here yet'), findsOneWidget);
  });

  testWidgets('Russian plurals', (t) async {
    for (final (n, text) in [(1, '1 место рядом'), (3, '3 места рядом'), (5, '5 мест рядом')]) {
      final items = NearbyItem.build([for (var i = 0; i < n; i++) place('$i', lat: 59 + i / 1000)], 59, 30);
      await t.pumpApp(
        NearbyList(items: items, visitedIds: const {}, onOpen: (_) {}),
        locale: const Locale('ru'),
      );
      expect(find.text(text), findsOneWidget, reason: '$n');
    }
  });
}
