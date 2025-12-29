import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/fitness_profile_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class FitnessProfileRepository {
  Future<Either<Failure, bool>> hasFitnessProfile();
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
}
