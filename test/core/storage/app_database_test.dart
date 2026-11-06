import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:sembast/sembast.dart';

void main() {
  late AppDatabase db;
  setUp(() async => db = await AppDatabase.inMemory());
  tearDown(() => db.close());

  test('clearStatistics wipes activity but keeps places and favourites', () async {
    await AppDatabase.visits.record('v').put(db.db, {'a': 1});
    await AppDatabase.hunts.record('h').put(db.db, {'a': 1});
    await AppDatabase.days.record('2026-01-01').put(db.db, {'a': 1});
    await AppDatabase.cells.record('1:1').put(db.db, {'a': 1});
    await AppDatabase.events.add(db.db, {'a': 1});
    await AppDatabase.track.add(db.db, {'a': 1});
    await AppDatabase.favorites.record('osm:node/1').put(db.db, {'a': 1});
    await AppDatabase.userPlaces.record('u1').put(db.db, {'a': 1});
    await AppDatabase.placesCache.record('osm:node/1').put(db.db, {'a': 1});

    await db.clearStatistics();

    for (final s in [AppDatabase.visits, AppDatabase.hunts, AppDatabase.days, AppDatabase.cells]) {
      expect(await s.count(db.db), 0);
    }
    expect(await AppDatabase.events.count(db.db), 0);
    expect(await AppDatabase.track.count(db.db), 0);
    expect(await AppDatabase.favorites.count(db.db), 1);
    expect(await AppDatabase.userPlaces.count(db.db), 1);
    expect(await AppDatabase.placesCache.count(db.db), 1);
  });

  test('in-memory databases are isolated from each other', () async {
    final other = await AppDatabase.inMemory();
    await AppDatabase.favorites.record('x').put(db.db, {'a': 1});
    expect(await AppDatabase.favorites.count(other.db), 0);
    await other.close();
  });
}
