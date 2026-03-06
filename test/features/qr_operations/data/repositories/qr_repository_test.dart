import 'package:flutter_test/flutter_test.dart';
import 'package:qstory/features/qr_operations/data/repositories/qr_repository_impl.dart';

void main() {
  late QrRepositoryImpl repository;

  setUp(() {
    repository = QrRepositoryImpl();
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
