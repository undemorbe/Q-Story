import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/presentation/widgets/place_card.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  Widget card(Place p, {bool visited = false, VoidCallback? onTap}) => SizedBox(
    width: 200,
    height: 260,
    child: PlaceCard(place: p, visited: visited, onTap: onTap ?? () {}),
  );

  testWidgets('shows title, category and year', (t) async {
    await t.pumpApp(card(place('1', title: 'Medny Vsadnik', year: 1782)));
    expect(find.text('Medny Vsadnik'), findsOneWidget);
    expect(find.textContaining('1782'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('visited places get a check mark', (t) async {
    await t.pumpApp(card(place('1'), visited: true));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('tap calls back', (t) async {
    var taps = 0;
    await t.pumpApp(card(place('1', title: 'Tap me'), onTap: () => taps++));
    await t.tap(find.text('Tap me'));
    expect(taps, 1);
  });

  testWidgets('without an image shows the category icon placeholder', (t) async {
    await t.pumpApp(card(place('1', category: PlaceCategory.museum)));
    expect(find.byType(Icon), findsWidgets);
  });
}
