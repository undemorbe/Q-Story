import '../../domain/entities/history_entity.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntity>> getHistory();
  Future<void> addHistoryItem(HistoryEntity item);
}
