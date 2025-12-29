import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/daily_log_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class DailyLogRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDailyLog(String date);
}

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogRemoteDataSource remoteDataSource;

  DailyLogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDailyLog(String date) async {
    try {
      final result = await remoteDataSource.getDailyLog(date);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
