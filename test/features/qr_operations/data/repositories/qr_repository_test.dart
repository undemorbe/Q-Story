import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/core/network/api_client.dart';
import 'package:qstory/features/qr_operations/data/repositories/qr_repository_impl.dart';

void main() {
  late QrRepositoryImpl repository;
  late ApiClient apiClient;

  setUp(() {
    apiClient = ApiClient();
    repository = QrRepositoryImpl(apiClient);
  });

  group('QrRepositoryImpl', () {
    test('processScannedData returns QrEntity with correct content', () async {
      const data = 'test data';
      
      final result = await repository.processScannedData(data);

      expect(result.content, data);
      expect(result.timestamp, isNotNull);
    });
  });
}
