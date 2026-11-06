// End-to-end "does the app start" test: the real object graph and router,
// with an in-memory database, fake sensors and a fake network.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/navigation/app_router.dart';
import 'package:qstory/core/services/motion_sensors.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/features/activity/presentation/stores/tracking_store.dart';
import 'package:qstory/features/places/presentation/stores/places_store.dart';
import 'package:qstory/features/stats/presentation/stores/milestone_service.dart';
import 'package:qstory/features/stats/presentation/stores/stats_store.dart';
import 'package:qstory/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_http.dart';
import 'helpers/fakes.dart';

Future<void> boot({bool onboarded = true}) async {
  SharedPreferences.setMockInitialValues({
    'has_seen_onboarding': onboarded,
    'auto_tracking': false,
    'locale': 'en',
  });
  await setupServiceLocator(
    database: await AppDatabase.inMemory(),
    preferences: await SharedPreferences.getInstance(),
    sensors: FakeSensors()..access = LocationAccess.denied,
    // Every open-data API answers "nothing here".
    dio: fakeDio((o) => {
          'result': {'photos': []},
          'query': {'pages': []},
          'results': {'bindings': []},
          'elements': [],
        }),
    share: FakeShare(),
    mail: FakeMail(),
  );
}

void main() {
  late Directory tmp;

  setUpAll(() {
    // flutter_map caches tiles via path_provider; give it a temp dir.
    tmp = Directory.systemTemp.createTempSync('qstory_smoke');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
  });

  tearDownAll(() => tmp.deleteSync(recursive: true));

  tearDown(() async {
    getIt<MilestoneService>().dispose();
    await getIt<TrackingStore>().stop();
    await getIt.reset();
  });

  testWidgets('first launch shows onboarding', (t) async {
    await t.runAsync(() => boot(onboarded: false));
    await t.pumpWidget(QStoryApp(router: buildRouter()));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('starts on the map and every main tab opens', (t) async {
    await t.runAsync(boot);
    await t.pumpWidget(QStoryApp(router: buildRouter()));
    await t.pump(const Duration(milliseconds: 300));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Map'), findsWidgets);

    // Places were requested from the (fake) open sources.
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump();
    expect(getIt<PlacesStore>().lastLat, isNotNull);

    for (final tab in ['Stats', 'Favorites', 'Profile', 'Map']) {
      await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull, reason: tab);
    }
    expect(getIt<StatsStore>().snapshot, isNotNull);
  });

  testWidgets('a recorded visit shows up on the statistics page', (t) async {
    await t.runAsync(boot);
    await t
        .runAsync(() => getIt<JournalStore>().recordVisit(place('node/1', title: 'Test monument'), VisitMethod.manual));
    await t.pumpWidget(QStoryApp(router: buildRouter()));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Stats')));
    await t.runAsync(() => getIt<StatsStore>().refresh());
    await t.pump(const Duration(milliseconds: 300));
    expect(getIt<StatsStore>().snapshot, isNotNull);
    await t.scrollUntilVisible(find.textContaining(RegExp('First.*Test monument')), 400,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Test monument'), findsWidgets);
  });
}
