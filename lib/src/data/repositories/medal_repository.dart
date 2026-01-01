import 'package:da1/src/data/datasources/medal_remote_data_source.dart';
import 'package:da1/src/domain/entities/medal.dart';
import 'package:dartz/dartz.dart';

abstract class MedalRepository {
  Future<Either<Exception, List<Medal>>> getMedals();
}

class MedalRepositoryImpl implements MedalRepository {
  final MedalRemoteDataSource remoteDataSource;

  MedalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<Medal>>> getMedals() async {
    try {
      final medals = await remoteDataSource.getMedals();
      return Right(medals);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
