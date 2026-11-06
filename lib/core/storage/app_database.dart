import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

/// Single local NoSQL database (sembast) for everything that must survive
/// restarts: cached places, user places, favourites, visits, hunts, daily
/// activity and the activity event log. Nothing here ever leaves the device.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const int _version = 1;

  // Stores. Keys are strings unless noted otherwise.
  static final placesCache = stringMapStoreFactory.store('places_cache');
  static final nearbyCache = stringMapStoreFactory.store('nearby_cache');
  static final userPlaces = stringMapStoreFactory.store('user_places');
  static final favorites = stringMapStoreFactory.store('favorites');
  static final visits = stringMapStoreFactory.store('visits');
  static final hunts = stringMapStoreFactory.store('hunts');
  static final days = stringMapStoreFactory.store('activity_days');
  static final cells = stringMapStoreFactory.store('explored_cells');
  static final events = intMapStoreFactory.store('events');
  static final track = intMapStoreFactory.store('track_points');

  /// Opens the on-disk database in the app documents directory.
  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await databaseFactoryIo.openDatabase(
      p.join(dir.path, 'qstory.db'),
      version: _version,
    );
    return AppDatabase._(db);
  }

  /// In-memory database for tests.
  static Future<AppDatabase> inMemory() async {
    final db = await newDatabaseFactoryMemory().openDatabase(
      'qstory_test.db',
      version: _version,
    );
    return AppDatabase._(db);
  }

  /// Wipes all personal statistics (keeps cached places and favourites).
  Future<void> clearStatistics() async {
    await db.transaction((txn) async {
      for (final s in [visits, hunts, days, cells]) {
        await s.delete(txn);
      }
      await events.delete(txn);
      await track.delete(txn);
    });
  }

  Future<void> close() => db.close();
}
