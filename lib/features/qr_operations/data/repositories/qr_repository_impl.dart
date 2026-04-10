import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/qr_entity.dart';
import '../../domain/repositories/qr_repository.dart';
import '../models/qr_data_model.dart';

class QrRepositoryImpl implements QrRepository {
  final ApiClient _apiClient;

  QrRepositoryImpl(this._apiClient);

  @override
  Future<QrEntity> processScannedData(String data) async {
    // Still simulate processing or could be used for local validation
    await Future.delayed(const Duration(milliseconds: 200));
    return QrEntity(content: data, timestamp: DateTime.now());
  }

  @override
  Future<QrDataModel> getPlaceInfo(String qrCode) async {
    try {
      final response = await _apiClient.client.get(
        '/get-info',
        queryParameters: {'qr_code': qrCode},
        );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return QrDataModel.fromJson(data);
      } else {
        throw Exception('Failed to get place info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get place info: $e');
    }
  }
}
