import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/fitness_profile_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class FitnessProfileRepository {
  Future<Either<Failure, bool>> hasFitnessProfile();
  Future<Either<Failure, Map<String, dynamic>>> createFitnessProfile(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, List<dynamic>>> getFitnessProfiles();
}

class FitnessProfileRepositoryImpl implements FitnessProfileRepository {
  final FitnessProfileRemoteDataSource remoteDataSource;

  FitnessProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> hasFitnessProfile() async {
    try {
      final profiles = await remoteDataSource.getFitnessProfiles();
      return Right(profiles.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createFitnessProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createFitnessProfile(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getFitnessProfiles() async {
    try {
      final profiles = await remoteDataSource.getFitnessProfiles();
      return Right(profiles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
