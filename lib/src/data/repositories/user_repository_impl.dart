import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/user_remote_data_source.dart';
import 'package:da1/src/data/repositories/user_repository.dart';
import 'package:da1/src/domain/entities/user.dart';
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
}
