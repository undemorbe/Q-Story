// Renders Google Play screenshots with real fonts and demo data.
//
// Skipped in normal runs. Generate with:
//   flutter test test/screenshots --dart-define=SCREENSHOTS=true
// Output: fastlane/metadata/android/<locale>/images/phoneScreenshots/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/navigation/app_router.dart';
import 'package:qstory/core/services/motion_sensors.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/core/theme/app_theme.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/activity/domain/repositories/activity_repository.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/features/activity/presentation/stores/tracking_store.dart';
import 'package:qstory/features/favorites/presentation/stores/favorites_store.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';
import 'package:qstory/features/places/domain/repositories/places_repository.dart';
import 'package:qstory/features/places/presentation/widgets/nearby_list.dart';
import 'package:qstory/features/stats/presentation/stores/milestone_service.dart';
import 'package:qstory/features/stats/presentation/stores/stats_store.dart';
import 'package:qstory/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_http.dart';
import '../helpers/fakes.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');

// 1080 × 1920 px, a common 9:16 phone.
const _size = Size(1080, 1920);
const _dpr = 2.625;

final _sdkFonts = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('$_sdkFonts/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Demo places in central St Petersburg, named in the screenshot language.
late List<Place> _places;

const _titles = {
  'ru': [
    'Ростральные колонны',
    'Медный всадник',
    'Дворцовая площадь, 1913',
    'Кунсткамера',
    'Петропавловская крепость',
    'Исаакиевский собор',
  ],
  'en': [
    'Rostral Columns',
    'Bronze Horseman',
    'Palace Square, 1913',
    'Kunstkamera',
    'Peter and Paul Fortress',
    "Saint Isaac's Cathedral",
  ],
};

List<Place> _demo(String locale) {
  final t = _titles[locale]!;
  return [
    place('$locale:1', source: PlaceSource.wikipedia, title: t[0], lat: 59.9440, lon: 30.3060, year: 1810),
    place('o2', title: t[1], lat: 59.9364, lon: 30.3022, year: 1782),
    place(
      'p3',
      source: PlaceSource.pastvu,
      title: t[2],
      lat: 59.9390,
      lon: 30.3158,
      year: 1913,
      category: PlaceCategory.photo,
    ),
    place(
      'd4',
      source: PlaceSource.wikidata,
      title: t[3],
      lat: 59.9415,
      lon: 30.3046,
      year: 1727,
      category: PlaceCategory.museum,
    ),
    place('o5', title: t[4], lat: 59.9500, lon: 30.3165, year: 1703, category: PlaceCategory.fortification),
    place(
      'w6',
      source: PlaceSource.wikipedia,
      title: t[5],
      lat: 59.9341,
      lon: 30.3061,
      year: 1858,
      category: PlaceCategory.religious,
    ),
  ];
}

const _extracts = {
  'ru':
      'Ростральные колонны — две маячные колонны на стрелке Васильевского острова. '
      'Их построили в 1805–1810 годах по проекту архитектора Тома де Томона, когда здесь '
      'находился торговый порт Петербурга.\n\n'
      'Колонны украшены рострами — носовыми частями кораблей, а у подножий стоят '
      'аллегорические фигуры. По традиции их считают олицетворением русских рек.\n\n'
      'Изначально на вершинах зажигали масляные светильники, позже — газовые факелы, '
      'которые и сегодня горят по праздникам.',
  'en':
      'The Rostral Columns are two lighthouse columns on the spit of Vasilyevsky Island. '
      'They were built in 1805–1810 to a design by Thomas de Thomon, when the port of '
      'St Petersburg was located here.\n\n'
      'The columns are decorated with rostra, the prows of ships, and allegorical figures '
      'stand at their feet, traditionally said to represent Russian rivers.\n\n'
      'Oil lamps once burned at the top; today gas torches are lit on holidays.',
};

Future<void> _boot(String locale) async {
  _places = _demo(locale);
  SharedPreferences.setMockInitialValues({
    'has_seen_onboarding': true,
    'auto_tracking': false,
    'locale': locale,
    'theme_mode': 'dark',
    'daily_step_goal': 8000,
    'seen_achievements': <String>[],
  });
  await setupServiceLocator(
    database: await AppDatabase.inMemory(),
    preferences: await SharedPreferences.getInstance(),
    sensors: FakeSensors()
      ..access = LocationAccess.granted
      ..stepAccess = true
      ..oneShot = GeoFix(lat: 59.9386, lon: 30.3141, time: DateTime.now()),
    dio: fakeDio(
      (o) => {
        'elements': [],
        'result': {'photos': []},
        'results': {'bindings': []},
        'query': {
          'pages': [
            {
              'pageid': 1,
              'title': _places.first.title,
              'coordinates': [
                {'lat': _places.first.lat, 'lon': _places.first.lon},
              ],
              'description': locale == 'ru' ? 'памятник архитектуры' : 'architectural monument',
              'extract': _extracts[locale],
            },
          ],
        },
      },
    ),
    share: FakeShare(),
    mail: FakeMail(),
  );
  await _seed();
}

/// Six weeks of plausible walking, a dozen finds and a few hunts.
Future<void> _seed() async {
  final repo = getIt<ActivityRepository>();
  final places = getIt<PlacesRepository>();
  final now = DateTime.now();
  for (var i = 41; i >= 0; i--) {
    final d = DateTime(now.year, now.month, now.day - i);
    final weekend = d.weekday >= 6;
    final steps = i == 0 ? 6420 : (weekend ? 11000 : 6500) + (i * 1373) % 4200;
    final hours = List<int>.filled(24, 0);
    for (final (h, share) in [(8, .12), (12, .18), (13, .1), (18, .25), (19, .2), (20, .15)]) {
      hours[h] = (steps * share).round();
    }
    await repo.saveDay(
      DayActivity(
        day: DayActivity.keyOf(d),
        steps: steps,
        distanceM: steps * 0.72,
        activeSeconds: steps ~/ 2,
        maxSpeedMps: 1.9,
        hourSteps: hours,
      ),
    );
  }
  for (var c = 0; c < 64; c++) {
    await repo.addExploredCell('c$c');
  }
  for (var i = 0; i < _places.length; i++) {
    final p = _places[i];
    await places.remember(p);
    if (i == 0) continue; // the featured place is still to be found
    final at = now.subtract(Duration(days: 30 - i * 5, hours: 3));
    await repo.addVisit(Visit.fromPlace(p, i.isEven ? VisitMethod.geofence : VisitMethod.qr, at));
    await repo.saveHunt(
      Hunt(
        id: 'h$i',
        placeId: p.id,
        placeTitle: p.title,
        targetLat: p.lat,
        targetLon: p.lon,
        startedAt: at.subtract(Duration(minutes: 12 + i * 3)),
        endedAt: at,
        status: HuntStatus.found,
        steps: 1100 + i * 260,
        distanceM: 800.0 + i * 190,
        startDistanceM: 650.0 + i * 120,
      ),
    );
  }
  await getIt<JournalStore>().init();
  await getIt<TrackingStore>().init();
  await getIt<FavoritesStore>().toggle(_places[0]);
  await getIt<FavoritesStore>().toggle(_places[4]);
  await getIt<StatsStore>().refresh();
}

void main() {
  late Directory tmp;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('qstory_shots');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
    if (!_enabled) return;
    await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
    await _loadFont('Roboto', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']);
  });

  tearDownAll(() => tmp.deleteSync(recursive: true));

  Future<void> shoot(WidgetTester t, String locale, String name) async {
    // Several frames so transitions and implicit animations finish.
    for (var i = 0; i < 12; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    final boundary = t.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    final bytes = await t.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: _dpr);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    final dir = Directory('fastlane/metadata/android/${locale == 'ru' ? 'ru-RU' : 'en-US'}/images/phoneScreenshots')
      ..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!);
  }

  for (final locale in ['ru', 'en']) {
    group(locale, () {
      setUp(() {
        final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
        view.physicalSize = _size;
        view.devicePixelRatio = _dpr;
      });

      tearDown(() async {
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
        if (getIt.isRegistered<MilestoneService>()) {
          getIt<MilestoneService>().dispose();
          await getIt<TrackingStore>().stop();
        }
        await getIt.reset();
      });

      testWidgets('app screens', skip: !_enabled, (t) async {
        await t.runAsync(() => _boot(locale));
        final router = buildRouter();
        await t.pumpWidget(QStoryApp(router: router));
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await t.pump(const Duration(seconds: 1));

        router.go('/stats');
        await t.runAsync(() => getIt<StatsStore>().refresh());
        await t.pump(const Duration(seconds: 1));
        await shoot(t, locale, '1_stats');

        await t.drag(find.byType(Scrollable).last, const Offset(0, -1300));
        await t.pump(const Duration(seconds: 1));
        await shoot(t, locale, '2_stats_charts');

        await t.drag(find.byType(Scrollable).last, const Offset(0, -2600));
        await t.pump(const Duration(seconds: 1));
        await shoot(t, locale, '3_achievements');

        router.push('/place', extra: _places.first);
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await t.pump(const Duration(seconds: 1));
        await shoot(t, locale, '4_place');
        router.pop();
        await t.pump(const Duration(seconds: 1));

        router.go('/profile');
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await t.pump(const Duration(seconds: 1));
        await shoot(t, locale, '6_profile');
      });

      testWidgets('nearby list', skip: !_enabled, (t) async {
        _places = _demo(locale);
        final items = NearbyItem.build(_places, 59.9386, 30.3141);
        await t.pumpWidget(
          RepaintBoundary(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(locale),
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SafeArea(
                  child: NearbyList(items: items, visitedIds: {_places[2].id, _places[3].id}, onOpen: (_) {}),
                ),
              ),
            ),
          ),
        );
        await shoot(t, locale, '5_nearby');
      });
    });
  }

  test('screenshots are opt-in', () {
    // Keeps this file from being an empty suite in normal runs.
    expect(_enabled || !_enabled, isTrue);
    expect(AppTheme.darkTheme.brightness, Brightness.dark);
    expect(GoRouter, isNotNull);
  });
}
