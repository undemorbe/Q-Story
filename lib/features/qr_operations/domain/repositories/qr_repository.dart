import '../entities/qr_entity.dart';
import '../../data/models/qr_data_model.dart';

abstract class QrRepository {
  Future<QrEntity> processScannedData(String data);
  
  /// Fetches place information from the API using QR code
  Future<QrDataModel> getPlaceInfo(String qrCode);
}
