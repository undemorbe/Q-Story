import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/util/dio_failure.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/entities/marker_submission_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/completed_markers_local_data_source.dart';
import '../models/map_marker_model.dart';

class MapRepositoryImpl implements MapRepository {
  final ApiClient _apiClient;
  final CompletedMarkersLocalDataSource _localDataSource;

  MapRepositoryImpl(this._apiClient, this._localDataSource);

  @override
  Future<Result<List<MapMarkerEntity>>> getMarkers() async {
    try {
      final response = await _apiClient.client.get('/get-markers');
      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return Err(ServerFailure('Ошибка загрузки: $code', statusCode: code));
      }
      final data = response.data as Map<String, dynamic>;
      final markersList = data['markers'] as List<dynamic>;
      final completedIds = await _localDataSource.getCompletedMarkerIds();
      final markers = markersList.map((json) {
        final model = MapMarkerModel.fromJson(json as Map<String, dynamic>);
        return model.copyWith(isCompleted: completedIds.contains(model.id));
      }).toList();
      return Ok(markers);
    } on DioException catch (e) {
      return Err(dioToFailure(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString(), e));
    }
  }

  @override
  Future<void> markAsCompleted(String markerId) async {
    await _localDataSource.markAsCompleted(markerId);
  }

  @override
  Future<Result<void>> submitMarker(MarkerSubmissionEntity payload) async {
    try {
      final response = await _apiClient.client.post(
        '/post-info',
        data: payload.toJson(),
      );
      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return Err(ServerFailure('Не удалось создать метку: $code',
            statusCode: code));
      }
      return const Ok(null);
    } on DioException catch (e) {
      return Err(dioToFailure(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString(), e));
    }
  }
}
