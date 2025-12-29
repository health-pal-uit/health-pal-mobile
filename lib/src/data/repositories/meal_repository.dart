import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/meal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class MealRepository {
  Future<Either<Failure, List<dynamic>>> searchMeals(String name);
}

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> searchMeals(String name) async {
    try {
      final meals = await remoteDataSource.searchMeals(name);
      return Right(meals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
