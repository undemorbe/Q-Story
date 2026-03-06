import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/qr_operations/domain/entities/qr_entity.dart';
import 'package:qstory/features/qr_operations/domain/usecases/process_qr_usecase.dart';
import 'package:qstory/features/qr_operations/presentation/stores/qr_store.dart';

@GenerateNiceMocks([MockSpec<ProcessQrUseCase>()])
import 'qr_store_test.mocks.dart';

void main() {
  late QrStore store;
  late MockProcessQrUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockProcessQrUseCase();
    store = QrStore(mockUseCase);
  });

  group('QrStore', () {
    test('initial values are correct', () {
      expect(store.generatedData, isNull);
      expect(store.lastScannedData, isNull);
      expect(store.isLoading, isFalse);
      expect(store.errorMessage, isNull);
    });

    test('setGeneratedData updates generatedData', () {
      const data = 'test data';
      store.setGeneratedData(data);
      expect(store.generatedData, data);
    });

    test('onScan updates lastScannedData on success', () async {
      const data = 'scanned data';
      final entity = QrEntity(content: data, timestamp: DateTime.now());
      
      when(mockUseCase(data))
          .thenAnswer((_) async => entity);

      await store.onScan(data);

      expect(store.isLoading, isFalse);
      expect(store.lastScannedData, data);
      expect(store.errorMessage, isNull);
      verify(mockUseCase(data)).called(1);
    });

    test('onScan updates errorMessage on failure', () async {
      const data = 'scanned data';
      const error = 'error message';
      
      when(mockUseCase(data))
          .thenThrow(Exception(error));

      await store.onScan(data);

      expect(store.isLoading, isFalse);
      expect(store.lastScannedData, isNull);
      expect(store.errorMessage, contains(error));
      verify(mockUseCase(data)).called(1);
    });
  });
}
