import '../../domain/entities/map_marker_entity.dart';

abstract class MapRepository {
  Future<List<MapMarkerEntity>> getMarkers();
  Future<void> markAsCompleted(String markerId);
}
