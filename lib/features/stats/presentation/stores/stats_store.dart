// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';

import '../../../../core/constants/app_info.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/domain/repositories/activity_repository.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../../favorites/presentation/stores/favorites_store.dart';
import '../../../places/domain/repositories/places_repository.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/data_export.dart';
import '../../domain/stats_calculator.dart';
import '../../domain/stats_snapshot.dart';

part 'stats_store.g.dart';

class StatsStore = _StatsStore with _$StatsStore;

abstract class _StatsStore with Store {
  _StatsStore(this._activity, this._places, this._favorites, this._tracking, this._journal, this._settings);

  final ActivityRepository _activity;
  final PlacesRepository _places;
  final FavoritesStore _favorites;
  final TrackingStore _tracking;
  final JournalStore _journal;
  final SettingsStore _settings;

  @observable
  StatsSnapshot? snapshot;

  @observable
  bool isLoading = false;

  @action
  Future<void> refresh() async {
    isLoading = true;
    await _tracking.flush();
    final results = await Future.wait([
      _activity.days(),
      _activity.hunts(),
      _activity.visits(),
      _activity.events(),
      _activity.exploredCellCount(),
      _places.userPlaces(),
    ]);
    final visits = results[2] as List<Visit>;
    final years = <String, int>{};
    for (final v in visits) {
      final p = await _places.cached(v.placeId);
      final y = p?.yearStart ?? p?.yearEnd;
      if (y != null) years[v.placeId] = y;
    }
    snapshot = StatsCalculator.compute(
      StatsInput(
        days: results[0] as List<DayActivity>,
        hunts: results[1] as List<Hunt>,
        visits: visits,
        events: results[3] as List<ActivityEvent>,
        exploredCells: results[4] as int,
        userPlaces: (results[5] as List).length,
        favorites: _favorites.items.length,
        visitedYears: years,
        dailyGoal: _settings.dailyStepGoal,
      ),
      DateTime.now(),
    );
    isLoading = false;
  }

  /// All local data as a pretty-printed JSON document (see [DataExport]).
  Future<String> exportJson({DateTime? now}) async {
    await _tracking.flush();
    final data = DataExport.build(
      now: now ?? DateTime.now(),
      appVersion: AppInfo.version,
      days: await _activity.days(),
      visits: await _activity.visits(),
      hunts: await _activity.hunts(),
      events: await _activity.events(),
      favorites: _favorites.items.toList(),
      userPlaces: await _places.userPlaces(),
    );
    return DataExport.encode(data);
  }

  @action
  Future<void> resetAll() async {
    await _tracking.stop();
    await _activity.clearAll();
    await _journal.init();
    await _tracking.init();
    await refresh();
  }
}
