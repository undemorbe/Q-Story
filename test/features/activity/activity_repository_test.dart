import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/places/domain/entities/place.dart';
import 'package:qstory/features/places/domain/entities/place_source.dart';

void main() {
  late AppDatabase db;
  late ActivityRepositoryImpl repo;
  final t0 = DateTime(2026, 11, 7, 10);

  setUp(() async {
    db = await AppDatabase.inMemory();
    repo = ActivityRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Visit visit(String id, DateTime at) =>
      Visit.fromPlace(Place(source: PlaceSource.osm, sourceId: id, title: id, lat: 1, lon: 1), VisitMethod.manual, at);

  test('a place is visited only once; newest first', () async {
    expect(await repo.addVisit(visit('a', t0)), isTrue);
    expect(await repo.addVisit(visit('a', t0.add(const Duration(days: 1)))), isFalse);
    expect(await repo.addVisit(visit('b', t0.add(const Duration(hours: 1)))), isTrue);
    expect((await repo.visits()).map((v) => v.title), ['b', 'a']);
    expect(await repo.visitedIds(), {'osm:a', 'osm:b'});
  });

  test('hunts: newest first, only one active', () async {
    final h1 = Hunt(
      id: '1',
      placeId: 'p',
      placeTitle: 'p',
      targetLat: 0,
      targetLon: 0,
      startedAt: t0,
      status: HuntStatus.found,
    );
    final h2 = Hunt(
      id: '2',
      placeId: 'q',
      placeTitle: 'q',
      targetLat: 0,
      targetLon: 0,
      startedAt: t0.add(const Duration(hours: 1)),
    );
    await repo.saveHunt(h1);
    await repo.saveHunt(h2);
    expect((await repo.hunts()).map((h) => h.id), ['2', '1']);
    expect((await repo.activeHunt())?.id, '2');
    await repo.saveHunt(h2.copyWith(status: HuntStatus.abandoned));
    expect(await repo.activeHunt(), isNull);
    expect(await repo.hunts(), hasLength(2));
  });

  test('days: empty default, upsert, sorted by date', () async {
    final empty = await repo.day('2026-11-07');
    expect(empty.steps, 0);
    await repo.saveDay(DayActivity(day: '2026-11-07', steps: 10));
    await repo.saveDay(DayActivity(day: '2026-11-05', steps: 5));
    await repo.saveDay(DayActivity(day: '2026-11-07', steps: 20));
    expect((await repo.day('2026-11-07')).steps, 20);
    expect((await repo.days()).map((d) => d.day), ['2026-11-05', '2026-11-07']);
  });

  test('explored cells are counted once', () async {
    expect(await repo.addExploredCell('1:1'), isTrue);
    expect(await repo.addExploredCell('1:1'), isFalse);
    expect(await repo.addExploredCell('1:2'), isTrue);
    expect(await repo.exploredCellCount(), 2);
  });

  test('events are appended in order', () async {
    await repo.log(ActivityEvent(type: ActivityEventType.scan, at: t0));
    await repo.log(ActivityEvent(type: ActivityEventType.view, at: t0.add(const Duration(minutes: 1))));
    expect((await repo.events()).map((e) => e.type), [ActivityEventType.scan, ActivityEventType.view]);
  });

  test('clearAll wipes everything', () async {
    await repo.addVisit(visit('a', t0));
    await repo.saveDay(DayActivity(day: '2026-11-07', steps: 1));
    await repo.addExploredCell('1:1');
    await repo.log(ActivityEvent(type: ActivityEventType.scan, at: t0));
    await repo.clearAll();
    expect(await repo.visits(), isEmpty);
    expect(await repo.days(), isEmpty);
    expect(await repo.exploredCellCount(), 0);
    expect(await repo.events(), isEmpty);
  });
}
