import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/meal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class MealRepository {
  Future<Either<Failure, List<dynamic>>> searchMeals(String name);
  Future<Either<Failure, List<dynamic>>> getFavoriteMeals({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, bool>> checkIfFavorited(String mealId);
  Future<Either<Failure, void>> toggleFavorite(String mealId);
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
  Future<Either<Failure, List<dynamic>>> getFavoriteMeals({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final meals = await remoteDataSource.getFavoriteMeals(
        page: page,
        limit: limit,
      );
      return Right(meals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkIfFavorited(String mealId) async {
    try {
      final isFavorited = await remoteDataSource.checkIfFavorited(mealId);
      return Right(isFavorited);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String mealId) async {
    try {
      await remoteDataSource.toggleFavorite(mealId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
