import '../../domain/entities/daily_fact_entity.dart';
import '../../domain/repositories/daily_fact_repository.dart';
import '../datasources/daily_fact_remote_data_source.dart';

class DailyFactRepositoryImpl implements DailyFactRepository {
  final DailyFactRemoteDataSource remote;

  DailyFactRepositoryImpl({required this.remote});

  @override
  Future<List<DailyFactEntity>> getFactsForDate(int month, int day) {
    return remote.fetchEventsForDate(month, day);
  }
}
