import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/activity_record_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class ActivityRecordRepository {
  Future<Either<Failure, Map<String, dynamic>>> createActivityRecord(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, List<dynamic>>> getActivityRecordsByDailyLog(
    String dailyLogId,
  );
  Future<Either<Failure, Map<String, dynamic>>> updateActivityRecord({
    required String activityRecordId,
    required int durationMinutes,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteActivityRecord(
    String activityRecordId,
  );
}

class ActivityRecordRepositoryImpl implements ActivityRecordRepository {
  final ActivityRecordRemoteDataSource remoteDataSource;

  ActivityRecordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> createActivityRecord(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createActivityRecord(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getActivityRecordsByDailyLog(
    String dailyLogId,
  ) async {
    try {
      final result = await remoteDataSource.getActivityRecordsByDailyLog(
        dailyLogId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateActivityRecord({
    required String activityRecordId,
    required int durationMinutes,
  }) async {
    try {
      final result = await remoteDataSource.updateActivityRecord(
        activityRecordId: activityRecordId,
        durationMinutes: durationMinutes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteActivityRecord(
    String activityRecordId,
  ) async {
    try {
      final result = await remoteDataSource.deleteActivityRecord(
        activityRecordId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
