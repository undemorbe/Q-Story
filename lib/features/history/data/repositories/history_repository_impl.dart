import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../models/history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<HistoryEntity>> getHistory() async {
    try {
      return await localDataSource.getHistory();
    } catch (e) {
      // Fallback or rethrow
      return [];
    }
  }

  @override
  Future<void> addHistoryItem(HistoryEntity item) async {
    final model = HistoryModel(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      description: item.description,
      imageUrl: item.imageUrl,
      yearRange: item.yearRange,
    );
    await localDataSource.addHistoryItem(model);
  }
}
