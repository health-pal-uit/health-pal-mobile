import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/meal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class MealRepository {
  Future<Either<Failure, List<dynamic>>> searchMeals(String name);
  Future<Either<Failure, List<dynamic>>> searchIngredients(String name);
  Future<Either<Failure, List<dynamic>>> getFavoriteMeals({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, bool>> checkIfFavorited(String mealId);
  Future<Either<Failure, void>> addFavorite(String userId, String mealId);
  Future<Either<Failure, void>> removeFavorite(String favId);
  Future<Either<Failure, Map<String, dynamic>>> getMealById(String mealId);
  Future<Either<Failure, List<dynamic>>> getUserContributions();
  Future<Either<Failure, Map<String, dynamic>>> createMealContribution(
    Map<String, dynamic> data,
    String? imagePath,
  );
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
  Future<Either<Failure, List<dynamic>>> searchIngredients(String name) async {
    try {
      final ingredients = await remoteDataSource.searchIngredients(name);
      return Right(ingredients);
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
  Future<Either<Failure, void>> addFavorite(
    String userId,
    String mealId,
  ) async {
    try {
      await remoteDataSource.addFavorite(userId, mealId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String favId) async {
    try {
      await remoteDataSource.removeFavorite(favId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMealById(
    String mealId,
  ) async {
    try {
      final meal = await remoteDataSource.getMealById(mealId);
      return Right(meal);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getUserContributions() async {
    try {
      final contributions = await remoteDataSource.getUserContributions();
      return Right(contributions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createMealContribution(
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    try {
      final result = await remoteDataSource.createMealContribution(
        data,
        imagePath,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
