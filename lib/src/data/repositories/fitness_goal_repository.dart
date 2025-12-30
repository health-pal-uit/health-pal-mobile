import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/fitness_goal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class FitnessGoalRepository {
  Future<Either<Failure, Map<String, dynamic>>> createFitnessGoal(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Map<String, dynamic>>> getFitnessGoal();
  Future<Either<Failure, Map<String, dynamic>>> updateFitnessGoal(
    Map<String, dynamic> data,
  );
}

class FitnessGoalRepositoryImpl implements FitnessGoalRepository {
  final FitnessGoalRemoteDataSource remoteDataSource;

  FitnessGoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> createFitnessGoal(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createFitnessGoal(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFitnessGoal() async {
    try {
      final result = await remoteDataSource.getFitnessGoal();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateFitnessGoal(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateFitnessGoal(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
