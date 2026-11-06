import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/stats/presentation/widgets/stats_widgets.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('StatTile shows label and value, hint as tooltip', (t) async {
    await t.pumpApp(const StatTile(label: 'Steps', value: '12 345', icon: Icons.directions_walk, hint: 'Lifetime'));
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('12 345'), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('StatTile without hint has no tooltip', (t) async {
    await t.pumpApp(const StatTile(label: 'A', value: '1'));
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('StatsSection renders title and children', (t) async {
    await t.pumpApp(const SingleChildScrollView(
      child: StatsSection(title: 'Movement', icon: Icons.directions_walk, children: [Text('child')]),
    ));
    expect(find.textContaining(RegExp('movement', caseSensitive: false)), findsWidgets);
    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('StatGrid lays out every tile', (t) async {
    await t.pumpApp(SingleChildScrollView(
      child: StatGrid(tiles: [for (var i = 0; i < 7; i++) StatTile(label: 'L$i', value: '$i')]),
    ));
    for (var i = 0; i < 7; i++) {
      expect(find.text('L$i'), findsOneWidget);
    }
    // Tiles in one row share the same top edge.
    expect(t.getTopLeft(find.text('L0')).dy, t.getTopLeft(find.text('L1')).dy);
  });

  testWidgets('BreakdownBars shows values with shares', (t) async {
    await t.pumpApp(const BreakdownBars(items: [
      BreakdownItem(label: 'Wikipedia', value: 3, icon: Icons.menu_book),
      BreakdownItem(label: 'OSM', value: 1, icon: Icons.map),
    ]));
    expect(find.text('Wikipedia'), findsOneWidget);
    expect(find.text('3 · 75%'), findsOneWidget);
    expect(find.text('1 · 25%'), findsOneWidget);
  });

  testWidgets('BreakdownBars with no items renders nothing', (t) async {
    await t.pumpApp(const BreakdownBars(items: []));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('GoalRing shows the number and caption, ring animates to ratio', (t) async {
    await t.pumpApp(const GoalRing(ratio: 0.5, center: '4 000', caption: '50% of goal'));
    await t.pumpAndSettle();
    expect(find.text('4 000'), findsOneWidget);
    expect(find.text('50% of goal'), findsOneWidget);
    final ring = t.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(ring.value, closeTo(0.5, 1e-6));
  });

  testWidgets('SimpleBarChart renders in light and dark themes', (t) async {
    for (final dark in [false, true]) {
      await t.pumpApp(
        SimpleBarChart(
          values: const [0, 3, 10, 4],
          bottomLabel: (i) => 'd$i',
          tooltip: (i) => 'v$i',
          referenceLine: 5,
          highlightIndex: 2,
        ),
        dark: dark,
      );
      await t.pumpAndSettle();
      expect(find.byType(SimpleBarChart), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });
}
