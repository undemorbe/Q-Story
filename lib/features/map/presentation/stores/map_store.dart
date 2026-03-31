import 'package:mobx/mobx.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/map_repository.dart';

part 'map_store.g.dart';

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

  @action
  Future<void> loadMarkers() async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _repository.getMarkers();
      markers.clear();
      markers.addAll(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> markAsCompleted(String markerId) async {
    try {
      await _repository.markAsCompleted(markerId);
      // Update local state
      final index = markers.indexWhere((m) => m.id == markerId);
      if (index != -1) {
        // We need to replace the item to trigger reactivity if the list was just a List, 
        // but with ObservableList we can just update. 
        // However, entities are immutable, so we replace.
        // Ideally we should refactor to use a mutable model or fetch again, 
        // but fetching again is safer for sync.
        await loadMarkers(); 
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
