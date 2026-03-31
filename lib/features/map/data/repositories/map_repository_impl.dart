import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../models/map_marker_model.dart';

class MapRepositoryImpl implements MapRepository {
  // Hardcoded markers for now
  final List<MapMarkerModel> _markers = [
    const MapMarkerModel(
      id: '1',
      latitude: 59.9398,
      longitude: 30.3146,
      title: 'Зимний дворец',
      description: 'Бывшая императорская резиденция, ныне Эрмитаж.',
      isCompleted: false,
    ),
    const MapMarkerModel(
      id: '2',
      latitude: 59.9502,
      longitude: 30.3166,
      title: 'Петропавловская крепость',
      description: 'Старейший архитектурный памятник Санкт-Петербурга.',
      isCompleted: false,
    ),
    const MapMarkerModel(
      id: '3',
      latitude: 59.9341,
      longitude: 30.3062,
      title: 'Исаакиевский собор',
      description: 'Крупнейший православный храм Санкт-Петербурга.',
      isCompleted: false,
    ),
  ];

  @override
  Future<List<MapMarkerEntity>> getMarkers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _markers;
  }

  @override
  Future<void> markAsCompleted(String markerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _markers.indexWhere((m) => m.id == markerId);
    if (index != -1) {
      // In a real app we would send this to the backend
      // Since _markers is now final (to fix linter warning about immutable field), 
      // we can't replace the list item in place if we want to keep the list final.
      // But since we are mocking, we can cheat a bit or make the list not final if we want to mutate it.
      // Actually, List content is mutable even if the variable is final.
      _markers[index] = _markers[index].copyWith(isCompleted: true);
    }
  }
}
