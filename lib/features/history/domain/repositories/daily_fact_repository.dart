import '../../../../core/util/result.dart';
import '../entities/daily_fact_entity.dart';

abstract class DailyFactRepository {
  /// Returns historical facts for given month/day filtered to Russia/USSR years.
  Future<Result<List<DailyFactEntity>>> getFactsForDate(int month, int day);
}
