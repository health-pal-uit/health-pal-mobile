import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/activity_remote_data_source.dart';
import 'package:da1/src/domain/entities/activity.dart';
import 'package:dartz/dartz.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Activity>>> getActivities();
}

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Activity>>> getActivities() async {
    try {
      final data = await remoteDataSource.getActivities();
      final activities = data.map((json) => Activity.fromJson(json)).toList();
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
