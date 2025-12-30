import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/meal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class MealRepository {
  Future<Either<Failure, List<dynamic>>> searchMeals(String name);
  Future<Either<Failure, List<dynamic>>> getFavoriteMeals({int page = 1, int limit = 10});
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

  @override
  Future<Either<Failure, List<dynamic>>> getFavoriteMeals({int page = 1, int limit = 10}) async {
    try {
      final meals = await remoteDataSource.getFavoriteMeals(page: page, limit: limit);
      return Right(meals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
