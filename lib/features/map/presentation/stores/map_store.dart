// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/entities/marker_submission_entity.dart';
import '../../domain/repositories/map_repository.dart';

part 'map_store.g.dart';

enum MarkerStatusFilter { all, completed, notCompleted }

class MapStore = _MapStore with _$MapStore;

abstract class _MapStore with Store {
  final MapRepository _repository;

  _MapStore(this._repository);

  @observable
  ObservableList<MapMarkerEntity> markers = ObservableList<MapMarkerEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isSubmitting = false;

  @observable
  String? submitError;

  // ─── Filters ────────────────────────────────────────────────────────────────

  @observable
  MarkerStatusFilter statusFilter = MarkerStatusFilter.all;

  @observable
  String? typeFilter;

  @computed
  List<String> get availableTypes {
    final set = <String>{};
    for (final m in markers) {
      set.add(m.type);
    }
    final list = set.toList()..sort();
    return list;
  }

  @computed
  List<MapMarkerEntity> get filteredMarkers {
    return markers.where((m) {
      if (typeFilter != null && m.type != typeFilter) return false;
      switch (statusFilter) {
        case MarkerStatusFilter.completed:
          return m.isCompleted;
        case MarkerStatusFilter.notCompleted:
          return !m.isCompleted;
        case MarkerStatusFilter.all:
          return true;
      }
    }).toList();
  }

  @action
  void setStatusFilter(MarkerStatusFilter f) => statusFilter = f;

  @action
  void setTypeFilter(String? type) => typeFilter = type;

  // ─── Actions ────────────────────────────────────────────────────────────────

  /// Returns `true` on success. On failure sets [submitError] and returns `false`.
  @action
  Future<bool> submitMarker(MarkerSubmissionEntity payload) async {
    isSubmitting = true;
    submitError = null;
    final result = await _repository.submitMarker(payload);
    isSubmitting = false;
    switch (result) {
      case Ok<void>():
        await loadMarkers();
        return true;
      case Err<void>(failure: final f):
        submitError = _humanize(f);
        return false;
    }
  }

  @action
  Future<void> loadMarkers() async {
    isLoading = true;
    errorMessage = null;
    final result = await _repository.getMarkers();
    isLoading = false;
    switch (result) {
      case Ok<List<MapMarkerEntity>>(value: final list):
        markers
          ..clear()
          ..addAll(list);
      case Err<List<MapMarkerEntity>>(failure: final f):
        errorMessage = _humanize(f);
    }
  }

  @action
  Future<void> markAsCompleted(String markerId) async {
    try {
      await _repository.markAsCompleted(markerId);
      final index = markers.indexWhere((m) => m.id == markerId);
      if (index != -1) {
        await loadMarkers();
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  String _humanize(Failure f) => switch (f) {
        NetworkFailure() => 'Нет соединения с сервером',
        NotFoundFailure() => 'Маркеры не найдены',
        ValidationFailure(message: final m) => m,
        ServerFailure(message: final m) => m,
        CacheFailure(message: final m) => m,
        UnknownFailure(message: final m) => m,
      };
}
