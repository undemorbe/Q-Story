import '../../../../core/util/result.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/entities/marker_submission_entity.dart';

abstract class MapRepository {
  Future<Result<List<MapMarkerEntity>>> getMarkers();
  Future<void> markAsCompleted(String markerId);
  Future<Result<void>> submitMarker(MarkerSubmissionEntity payload);
}
