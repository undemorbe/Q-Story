// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlacesStore on _PlacesStore, Store {
  Computed<List<PlaceCategory>>? _$availableCategoriesComputed;

  @override
  List<PlaceCategory> get availableCategories => (_$availableCategoriesComputed ??= Computed<List<PlaceCategory>>(
    () => super.availableCategories,
    name: '_PlacesStore.availableCategories',
  )).value;
  Computed<Map<PlaceSource, int>>? _$countBySourceComputed;

  @override
  Map<PlaceSource, int> get countBySource => (_$countBySourceComputed ??= Computed<Map<PlaceSource, int>>(
    () => super.countBySource,
    name: '_PlacesStore.countBySource',
  )).value;
  Computed<List<Place>>? _$filteredComputed;

  @override
  List<Place> get filtered =>
      (_$filteredComputed ??= Computed<List<Place>>(() => super.filtered, name: '_PlacesStore.filtered')).value;
  Computed<int>? _$activeFilterCountComputed;

  @override
  int get activeFilterCount => (_$activeFilterCountComputed ??= Computed<int>(
    () => super.activeFilterCount,
    name: '_PlacesStore.activeFilterCount',
  )).value;

  late final _$placesAtom = Atom(name: '_PlacesStore.places', context: context);

  @override
  ObservableList<Place> get places {
    _$placesAtom.reportRead();
    return super.places;
  }

  @override
  set places(ObservableList<Place> value) {
    _$placesAtom.reportWrite(value, super.places, () {
      super.places = value;
    });
  }

  late final _$isLoadingAtom = Atom(name: '_PlacesStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$failuresAtom = Atom(name: '_PlacesStore.failures', context: context);

  @override
  ObservableMap<PlaceSource, Failure> get failures {
    _$failuresAtom.reportRead();
    return super.failures;
  }

  @override
  set failures(ObservableMap<PlaceSource, Failure> value) {
    _$failuresAtom.reportWrite(value, super.failures, () {
      super.failures = value;
    });
  }

  late final _$fromCacheAtom = Atom(name: '_PlacesStore.fromCache', context: context);

  @override
  bool get fromCache {
    _$fromCacheAtom.reportRead();
    return super.fromCache;
  }

  @override
  set fromCache(bool value) {
    _$fromCacheAtom.reportWrite(value, super.fromCache, () {
      super.fromCache = value;
    });
  }

  late final _$lastLatAtom = Atom(name: '_PlacesStore.lastLat', context: context);

  @override
  double? get lastLat {
    _$lastLatAtom.reportRead();
    return super.lastLat;
  }

  @override
  set lastLat(double? value) {
    _$lastLatAtom.reportWrite(value, super.lastLat, () {
      super.lastLat = value;
    });
  }

  late final _$lastLonAtom = Atom(name: '_PlacesStore.lastLon', context: context);

  @override
  double? get lastLon {
    _$lastLonAtom.reportRead();
    return super.lastLon;
  }

  @override
  set lastLon(double? value) {
    _$lastLonAtom.reportWrite(value, super.lastLon, () {
      super.lastLon = value;
    });
  }

  late final _$visitFilterAtom = Atom(name: '_PlacesStore.visitFilter', context: context);

  @override
  VisitFilter get visitFilter {
    _$visitFilterAtom.reportRead();
    return super.visitFilter;
  }

  @override
  set visitFilter(VisitFilter value) {
    _$visitFilterAtom.reportWrite(value, super.visitFilter, () {
      super.visitFilter = value;
    });
  }

  late final _$sourceFilterAtom = Atom(name: '_PlacesStore.sourceFilter', context: context);

  @override
  ObservableSet<PlaceSource> get sourceFilter {
    _$sourceFilterAtom.reportRead();
    return super.sourceFilter;
  }

  @override
  set sourceFilter(ObservableSet<PlaceSource> value) {
    _$sourceFilterAtom.reportWrite(value, super.sourceFilter, () {
      super.sourceFilter = value;
    });
  }

  late final _$categoryFilterAtom = Atom(name: '_PlacesStore.categoryFilter', context: context);

  @override
  PlaceCategory? get categoryFilter {
    _$categoryFilterAtom.reportRead();
    return super.categoryFilter;
  }

  @override
  set categoryFilter(PlaceCategory? value) {
    _$categoryFilterAtom.reportWrite(value, super.categoryFilter, () {
      super.categoryFilter = value;
    });
  }

  late final _$searchQueryAtom = Atom(name: '_PlacesStore.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$loadAroundAsyncAction = AsyncAction('_PlacesStore.loadAround', context: context);

  @override
  Future<void> loadAround(double lat, double lon, {bool force = false, bool refresh = false}) {
    return _$loadAroundAsyncAction.run(() => super.loadAround(lat, lon, force: force, refresh: refresh));
  }

  late final _$addUserPlaceAsyncAction = AsyncAction('_PlacesStore.addUserPlace', context: context);

  @override
  Future<void> addUserPlace(Place place) {
    return _$addUserPlaceAsyncAction.run(() => super.addUserPlace(place));
  }

  late final _$deleteUserPlaceAsyncAction = AsyncAction('_PlacesStore.deleteUserPlace', context: context);

  @override
  Future<void> deleteUserPlace(Place place) {
    return _$deleteUserPlaceAsyncAction.run(() => super.deleteUserPlace(place));
  }

  late final _$_PlacesStoreActionController = ActionController(name: '_PlacesStore', context: context);

  @override
  void setVisitFilter(VisitFilter f) {
    final _$actionInfo = _$_PlacesStoreActionController.startAction(name: '_PlacesStore.setVisitFilter');
    try {
      return super.setVisitFilter(f);
    } finally {
      _$_PlacesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSourceFilter(PlaceSource s) {
    final _$actionInfo = _$_PlacesStoreActionController.startAction(name: '_PlacesStore.toggleSourceFilter');
    try {
      return super.toggleSourceFilter(s);
    } finally {
      _$_PlacesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategoryFilter(PlaceCategory? c) {
    final _$actionInfo = _$_PlacesStoreActionController.startAction(name: '_PlacesStore.setCategoryFilter');
    try {
      return super.setCategoryFilter(c);
    } finally {
      _$_PlacesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchQuery(String q) {
    final _$actionInfo = _$_PlacesStoreActionController.startAction(name: '_PlacesStore.setSearchQuery');
    try {
      return super.setSearchQuery(q);
    } finally {
      _$_PlacesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetFilters() {
    final _$actionInfo = _$_PlacesStoreActionController.startAction(name: '_PlacesStore.resetFilters');
    try {
      return super.resetFilters();
    } finally {
      _$_PlacesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
places: ${places},
isLoading: ${isLoading},
failures: ${failures},
fromCache: ${fromCache},
lastLat: ${lastLat},
lastLon: ${lastLon},
visitFilter: ${visitFilter},
sourceFilter: ${sourceFilter},
categoryFilter: ${categoryFilter},
searchQuery: ${searchQuery},
availableCategories: ${availableCategories},
countBySource: ${countBySource},
filtered: ${filtered},
activeFilterCount: ${activeFilterCount}
    ''';
  }
}
