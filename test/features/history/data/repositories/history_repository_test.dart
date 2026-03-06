import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/history/data/datasources/history_local_data_source.dart';
import 'package:qstory/features/history/data/models/history_model.dart';
import 'package:qstory/features/history/data/repositories/history_repository_impl.dart';
import 'package:qstory/features/history/domain/entities/history_entity.dart';

import 'history_repository_test.mocks.dart';

@GenerateMocks([HistoryLocalDataSource])
void main() {
  late HistoryRepositoryImpl repository;
  late MockHistoryLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockHistoryLocalDataSource();
    repository = HistoryRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const tHistoryModel = HistoryModel(
    id: '1',
    title: 'Test Title',
    subtitle: 'Test Subtitle',
    description: 'Test Description',
    imageUrl: 'test.jpg',
    yearRange: '2023',
  );

  final List<HistoryModel> tHistoryList = [tHistoryModel];

  test('should return list of history entities when local data source is successful',
      () async {
    // arrange
    when(mockLocalDataSource.getHistory())
        .thenAnswer((_) async => tHistoryList);

    // act
    final result = await repository.getHistory();

    // assert
    expect(result, isA<List<HistoryEntity>>());
    expect(result.length, 1);
    expect(result.first.id, tHistoryModel.id);
    verify(mockLocalDataSource.getHistory());
    verifyNoMoreInteractions(mockLocalDataSource);
  });

  test('should return empty list when local data source fails', () async {
    // arrange
    when(mockLocalDataSource.getHistory()).thenThrow(Exception());

    // act
    final result = await repository.getHistory();

    // assert
    expect(result, isEmpty);
    verify(mockLocalDataSource.getHistory());
  });
}
