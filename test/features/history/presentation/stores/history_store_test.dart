import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/history/domain/entities/history_entity.dart';
import 'package:qstory/features/history/domain/repositories/history_repository.dart';
import 'package:qstory/features/history/presentation/stores/history_store.dart';

import 'history_store_test.mocks.dart';

@GenerateMocks([HistoryRepository])
void main() {
  late HistoryStore store;
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
    store = HistoryStore(mockRepository);
  });

  const tHistoryEntity = HistoryEntity(
    id: '1',
    title: 'Test Title',
    subtitle: 'Test Subtitle',
    description: 'Test Description',
    imageUrl: 'test.jpg',
    yearRange: '2023',
  );

  final tHistoryList = [tHistoryEntity];

  test('should load history from repository', () async {
    // arrange
    when(mockRepository.getHistory()).thenAnswer((_) async => tHistoryList);

    // act
    await store.loadHistory();

    // assert
    expect(store.historyList, tHistoryList);
    expect(store.filteredList, tHistoryList);
    expect(store.isLoading, false);
    expect(store.errorMessage, isNull);
    verify(mockRepository.getHistory());
  });

  test('should handle error when loading history fails', () async {
    // arrange
    when(mockRepository.getHistory()).thenThrow(Exception('Error'));

    // act
    await store.loadHistory();

    // assert
    expect(store.historyList, isEmpty);
    expect(store.isLoading, false);
    expect(store.errorMessage, 'Exception: Error');
  });

  test('should filter history correctly', () async {
    // arrange
    store.historyList = tHistoryList;
    store.filteredList = tHistoryList;

    // act
    store.filterHistory('Test');

    // assert
    expect(store.filteredList.length, 1);

    // act
    store.filterHistory('NonExistent');

    // assert
    expect(store.filteredList, isEmpty);
  });
}
