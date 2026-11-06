import '../../../../core/network/http_client.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/daily_fact_entity.dart';
import '../../domain/repositories/daily_fact_repository.dart';
import '../datasources/daily_fact_remote_data_source.dart';

class DailyFactRepositoryImpl implements DailyFactRepository {
  final DailyFactRemoteDataSource remote;

  DailyFactRepositoryImpl({required this.remote});

  @override
  Future<Result<List<DailyFactEntity>>> getFactsForDate(int month, int day) async {
    try {
      final list = await remote.fetchEventsForDate(month, day);
      return Ok(list);
    } catch (e) {
      return Err(toFailure(e));
    }
  }
}
