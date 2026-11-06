// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';

import '../../../places/domain/entities/place.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';

part 'journal_store.g.dart';

typedef VisitListener = void Function(Visit visit);

/// Records discoveries and user actions into the local activity log and
/// exposes the set of visited places reactively.
class JournalStore = _JournalStore with _$JournalStore;

abstract class _JournalStore with Store {
  _JournalStore(this._repo, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final ActivityRepository _repo;
  final DateTime Function() _now;
  final List<VisitListener> _visitListeners = [];

  @observable
  ObservableSet<String> visitedIds = ObservableSet<String>();

  /// Incremented on every logged change so dependent views can refresh.
  @observable
  int revision = 0;

  void addVisitListener(VisitListener l) => _visitListeners.add(l);

  @action
  Future<void> init() async {
    visitedIds = ObservableSet.of(await _repo.visitedIds());
  }

  bool isVisited(String placeId) => visitedIds.contains(placeId);

  /// Returns true if this is a new discovery.
  @action
  Future<bool> recordVisit(Place place, VisitMethod method) async {
    final visit = Visit.fromPlace(place, method, _now());
    final isNew = await _repo.addVisit(visit);
    if (isNew) {
      visitedIds.add(place.id);
      await _repo
          .log(ActivityEvent(type: ActivityEventType.visit, at: visit.at, placeId: place.id, source: place.source));
      for (final l in _visitListeners) {
        l(visit);
      }
      revision++;
    }
    return isNew;
  }

  @action
  Future<void> log(ActivityEventType type, {Place? place, num? value}) async {
    await _repo.log(ActivityEvent(type: type, at: _now(), placeId: place?.id, source: place?.source, value: value));
    revision++;
  }
}
