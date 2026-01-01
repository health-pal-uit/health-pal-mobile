import 'package:da1/src/data/datasources/challenge_remote_data_source.dart';
import 'package:da1/src/domain/entities/challenge.dart';
import 'package:dartz/dartz.dart';

abstract class ChallengeRepository {
  Future<Either<Exception, List<Challenge>>> getChallenges();
}

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource remoteDataSource;

  ChallengeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<Challenge>>> getChallenges() async {
    try {
      final challenges = await remoteDataSource.getChallenges();
      return Right(challenges);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
