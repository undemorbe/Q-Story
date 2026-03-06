import '../entities/qr_entity.dart';
import '../repositories/qr_repository.dart';

class ProcessQrUseCase {
  final QrRepository _repository;

  ProcessQrUseCase(this._repository);

  Future<QrEntity> call(String data) {
    return _repository.processScannedData(data);
  }
}
