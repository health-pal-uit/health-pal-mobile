import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/daily_meal_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class DailyMealRepository {
  Future<Either<Failure, Map<String, dynamic>>> addDailyMeal({
    required String mealId,
    required String mealType,
    required double quantityKg,
    required String loggedAt,
  });
}

class DailyMealRepositoryImpl implements DailyMealRepository {
  final DailyMealRemoteDataSource remoteDataSource;

  DailyMealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> addDailyMeal({
    required String mealId,
    required String mealType,
    required double quantityKg,
    required String loggedAt,
  }) async {
    try {
      final result = await remoteDataSource.addDailyMeal(
        mealId: mealId,
        mealType: mealType,
        quantityKg: quantityKg,
        loggedAt: loggedAt,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
