import 'dart:io';
import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/features/expert/auth/data/datasources/expert_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class ExpertRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getExpertRoles();

  Future<Either<Exception, void>> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  });
}

class ExpertRepositoryImpl implements ExpertRepository {
  final ExpertRemoteDataSource remoteDataSource;

  ExpertRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, void>> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  }) async {
    try {
      await remoteDataSource.registerExpert(
        roleId: roleId,
        licenseId: licenseId,
        bio: bio,
        fee: fee,
        licensePhoto: licensePhoto,
      );

      return const Right(null);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Failed to submit application';
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getExpertRoles() async {
    try {
      final response = await remoteDataSource.getExpertRoles();
      final roles = List<Map<String, dynamic>>.from(response);
      return Right(roles);
    } catch (e) {
      return Left(ServerFailure('Failed to load expert roles: $e'));
    }
  }
}
