import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/util/dio_failure.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/daily_fact_entity.dart';
import '../../domain/repositories/daily_fact_repository.dart';
import '../datasources/daily_fact_remote_data_source.dart';

class DailyFactRepositoryImpl implements DailyFactRepository {
  final DailyFactRemoteDataSource remote;

  DailyFactRepositoryImpl({required this.remote});

  @override
  Future<Result<List<DailyFactEntity>>> getFactsForDate(
      int month, int day) async {
    try {
      final list = await remote.fetchEventsForDate(month, day);
      return Ok(list);
    } on DioException catch (e) {
      return Err(dioToFailure(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString(), e));
    }
  }
}
