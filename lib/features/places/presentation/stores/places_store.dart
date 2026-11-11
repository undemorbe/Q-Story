// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/util/geo.dart';
import '../../../../core/util/result.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/place_source.dart';
import '../../domain/repositories/places_repository.dart';

part 'places_store.g.dart';

enum VisitFilter { all, visited, notVisited }

class PlacesStore = _PlacesStore with _$PlacesStore;

abstract class _PlacesStore with Store {
  _PlacesStore(this._repo, this._journal, this._settings);

  final PlacesRepository _repo;
  final JournalStore _journal;
  final SettingsStore _settings;

  /// Re-query only when the map center moved further than this.
  static const double _reloadDistanceM = 400;

  @observable
  ObservableList<Place> places = ObservableList<Place>();

  @observable
  bool isLoading = false;

  @observable
  ObservableMap<PlaceSource, Failure> failures = ObservableMap<PlaceSource, Failure>();

  @observable
  bool fromCache = false;

  @observable
  double? lastLat;

  @observable
  double? lastLon;

  @observable
  VisitFilter visitFilter = VisitFilter.all;

  @observable
  ObservableSet<PlaceSource> sourceFilter = ObservableSet<PlaceSource>();

  @observable
  PlaceCategory? categoryFilter;

  @observable
  String searchQuery = '';

  @computed
  List<PlaceCategory> get availableCategories {
    final s = places.map((p) => p.category).toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
    return s;
  }

  @computed
  Map<PlaceSource, int> get countBySource {
    final m = <PlaceSource, int>{};
    for (final p in places) {
      m[p.source] = (m[p.source] ?? 0) + 1;
    }
    return m;
  }

  @computed
  List<Place> get filtered {
    final visited = _journal.visitedIds;
    final q = searchQuery.trim().toLowerCase();
    return places.where((p) {
      if (sourceFilter.isNotEmpty && !sourceFilter.contains(p.source)) return false;
      if (categoryFilter != null && p.category != categoryFilter) return false;
      final isVisited = visited.contains(p.id);
      if (visitFilter == VisitFilter.visited && !isVisited) return false;
      if (visitFilter == VisitFilter.notVisited && isVisited) return false;
      if (q.isNotEmpty && !p.title.toLowerCase().contains(q) && !p.summary.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @computed
  int get activeFilterCount =>
      (visitFilter != VisitFilter.all ? 1 : 0) +
      (sourceFilter.isNotEmpty ? 1 : 0) +
      (categoryFilter != null ? 1 : 0) +
      (searchQuery.trim().isNotEmpty ? 1 : 0);

  bool isVisited(String id) => _journal.isVisited(id);

  /// Nearest loaded place within [radiusM] of the point, if any.
  Place? nearestWithin(double lat, double lon, double radiusM) {
    Place? best;
    var bestD = radiusM;
    for (final p in places) {
      final d = Geo.distanceM(lat, lon, p.lat, p.lon);
      if (d <= bestD) {
        bestD = d;
        best = p;
      }
    }
    return best;
  }

  bool shouldReload(double lat, double lon) {
    if (lastLat == null || lastLon == null) return true;
    return Geo.distanceM(lat, lon, lastLat!, lastLon!) > _reloadDistanceM;
  }

  /// Id of the latest [loadAround] call; older responses are dropped so a
  /// slow request for a previous point never overwrites a newer one.
  int _requestSeq = 0;

  /// Loads places around the point. [force] ignores the "moved too little"
  /// check, [refresh] also bypasses the fresh network cache.
  @action
  Future<void> loadAround(double lat, double lon, {bool force = false, bool refresh = false}) async {
    if (!force && !refresh && !shouldReload(lat, lon) && places.isNotEmpty) return;
    final seq = ++_requestSeq;
    isLoading = true;
    lastLat = lat;
    lastLon = lon;
    final NearbyPlaces result;
    try {
      result = await _repo.nearby(
        PlaceQuery(lat: lat, lon: lon, radiusM: _settings.searchRadiusM, language: _settings.languageCode),
        sources: _settings.enabledSources.toSet(),
        forceRefresh: refresh,
      );
    } finally {
      if (seq == _requestSeq) isLoading = false;
    }
    if (seq != _requestSeq) return;
    _applyResult(result.places);
    failures = ObservableMap.of(result.failures);
    fromCache = result.fromCache;
    if (!result.fromCache && result.places.isNotEmpty) {
      await _journal.log(ActivityEventType.placesLoaded, value: result.places.length);
    }
  }

  void _applyResult(List<Place> loaded) {
    // A place created while the request was in flight is not in the result
    // yet (user places were read before it was saved) — keep it.
    final ids = loaded.map((p) => p.id).toSet();
    final pending = places.where((p) => p.source == PlaceSource.user && !ids.contains(p.id));
    places = ObservableList.of([...pending, ...loaded]);
  }

  Future<Result<Place>> details(Place place) =>
      _repo.details(place.source, place.sourceId, language: _settings.languageCode);

  Future<Result<Place>> resolve(PlaceSource source, String sourceId) =>
      _repo.details(source, sourceId, language: _settings.languageCode);

  Future<void> remember(Place place) => _repo.remember(place);

  @action
  Future<void> addUserPlace(Place place) async {
    await _repo.saveUserPlace(place);
    // Otherwise the new pin would vanish on the next reload / stay hidden.
    if (!_settings.enabledSources.contains(PlaceSource.user)) {
      await _settings.toggleSource(PlaceSource.user, true);
    }
    if (sourceFilter.isNotEmpty) sourceFilter.add(PlaceSource.user);
    places
      ..removeWhere((p) => p.id == place.id)
      ..insert(0, place);
    await _journal.log(ActivityEventType.userPlaceCreated, place: place);
  }

  @action
  Future<void> deleteUserPlace(Place place) async {
    await _repo.deleteUserPlace(place.sourceId);
    places.removeWhere((p) => p.id == place.id);
  }

  @action
  void setVisitFilter(VisitFilter f) => visitFilter = f;

  @action
  void toggleSourceFilter(PlaceSource s) {
    if (!sourceFilter.remove(s)) sourceFilter.add(s);
  }

  @action
  void setCategoryFilter(PlaceCategory? c) => categoryFilter = c;

  @action
  void setSearchQuery(String q) => searchQuery = q;

  @action
  void resetFilters() {
    visitFilter = VisitFilter.all;
    sourceFilter.clear();
    categoryFilter = null;
    searchQuery = '';
  }
}
