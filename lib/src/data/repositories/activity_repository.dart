import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/activity_remote_data_source.dart';
import 'package:da1/src/domain/entities/activity.dart';
import 'package:dartz/dartz.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Activity>>> getActivities({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, List<Activity>>> searchActivities({
    required String name,
    int page = 1,
    int limit = 20,
  });
}

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Activity>>> getActivities({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await remoteDataSource.getActivities(
        page: page,
        limit: limit,
      );
      final activities = data.map((json) => Activity.fromJson(json)).toList();
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> searchActivities({
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await remoteDataSource.searchActivities(
        name: name,
        page: page,
        limit: limit,
      );
      final activities = data.map((json) => Activity.fromJson(json)).toList();
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
