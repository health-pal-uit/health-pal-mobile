import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/diet_type_remote_data_source.dart';
import 'package:da1/src/domain/entities/diet_type.dart';
import 'package:dartz/dartz.dart';

abstract class DietTypeRepository {
  Future<Either<Failure, List<DietType>>> getDietTypes();
}

class DietTypeRepositoryImpl implements DietTypeRepository {
  final DietTypeRemoteDataSource remoteDataSource;

  DietTypeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DietType>>> getDietTypes() async {
    try {
      final data = await remoteDataSource.getDietTypes();
      final dietTypes = data.map((json) => DietType.fromJson(json)).toList();
      return Right(dietTypes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
