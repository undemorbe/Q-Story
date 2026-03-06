import '../entities/qr_entity.dart';

abstract class QrRepository {
  Future<QrEntity> processScannedData(String data);
}
