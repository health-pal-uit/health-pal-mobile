import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/features/user/home/data/datasources/user_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/user_repository.dart';
import 'package:da1/src/core/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> updateAvatar(String imagePath) async {
    try {
      final userModel = await remoteDataSource.updateAvatar(imagePath);
      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to update avatar'),
      );
    } catch (e) {
      return Left(ServerFailure('An error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Exception, Map<String, dynamic>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchUsers(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    try {
      final result = await remoteDataSource.getUserProfile();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
