import 'package:qstory/features/activity/presentation/stores/tracking_store.dart';
import 'package:qstory/features/favorites/presentation/stores/favorites_store.dart';
import 'package:qstory/features/places/data/repositories/places_repository_impl.dart';
import 'package:qstory/features/stats/presentation/stores/stats_store.dart';

import '../../helpers/fakes.dart';

/// Full statistics object graph on an in-memory database.
class StatsFixture {
  StatsFixture._(this.env, this.sensors, this.tracking, this.favorites, this.places, this.stats);

  final TestEnv env;
  final FakeSensors sensors;
  final TrackingStore tracking;
  final FavoritesStore favorites;
  final PlacesRepositoryImpl places;
  final StatsStore stats;

  static Future<StatsFixture> create({Map<String, Object> prefs = const {}}) async {
    final env = await TestEnv.create(prefs: prefs);
    final sensors = FakeSensors();
    final tracking = TrackingStore(sensors, env.activity, env.journal, env.settings);
    await tracking.init();
    final favorites = FavoritesStore(env.db, env.journal);
    await favorites.load();
    final places = env.placesRepo([]);
    final stats = StatsStore(env.activity, places, favorites, tracking, env.journal, env.settings);
    return StatsFixture._(env, sensors, tracking, favorites, places, stats);
  }

  Future<void> dispose() async {
    await tracking.stop();
    await env.dispose();
  }
}
