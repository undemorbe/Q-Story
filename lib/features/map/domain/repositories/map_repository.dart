import '../../domain/entities/map_marker_entity.dart';
import '../../domain/entities/marker_submission_entity.dart';

abstract class MapRepository {
  Future<List<MapMarkerEntity>> getMarkers();
  Future<void> markAsCompleted(String markerId);
  Future<void> submitMarker(MarkerSubmissionEntity payload);
}
