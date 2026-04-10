import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/completed_markers_local_data_source.dart';
import '../models/map_marker_model.dart';

class MapRepositoryImpl implements MapRepository {
  final ApiClient _apiClient;
  final CompletedMarkersLocalDataSource _localDataSource;

  MapRepositoryImpl(this._apiClient, this._localDataSource);

  @override
  Future<List<MapMarkerEntity>> getMarkers() async {
    try {
      final response = await _apiClient.client.get('/get-markers');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final markersList = data['markers'] as List<dynamic>;
        final completedIds = await _localDataSource.getCompletedMarkerIds();
        
        return markersList.map((json) {
          final model = MapMarkerModel.fromJson(json as Map<String, dynamic>);
          // Merge with local completion status
          return model.copyWith(isCompleted: completedIds.contains(model.id));
        }).toList();
      } else {
        throw Exception('Failed to load markers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load markers: $e');
    }
  }

  @override
  Future<void> markAsCompleted(String markerId) async {
    await _localDataSource.markAsCompleted(markerId);
  }
}
