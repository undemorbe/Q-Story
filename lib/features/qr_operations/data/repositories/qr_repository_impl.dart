import '../../domain/entities/qr_entity.dart';
import '../../domain/repositories/qr_repository.dart';

class QrRepositoryImpl implements QrRepository {
  @override
  Future<QrEntity> processScannedData(String data) async {
    // Simulate processing or API call
    await Future.delayed(const Duration(milliseconds: 500));
    return QrEntity(content: data, timestamp: DateTime.now());
  }
}
