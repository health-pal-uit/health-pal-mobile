import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class ExpertRepository {
  Future<Either<Exception, void>> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  });
}

class ExpertRepositoryImpl implements ExpertRepository {
  final Dio dio;

  ExpertRepositoryImpl({required this.dio});

  @override
  Future<Either<Exception, void>> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  }) async {
    try {
      String fileName = licensePhoto.path.split('/').last;

      FormData formData = FormData.fromMap({
        'expert_role_id': roleId,
        'license_id': licenseId,
        'bio': bio,
        'token_per_minute': fee,
        'license_photo': await MultipartFile.fromFile(
          licensePhoto.path,
          filename: fileName,
        ),
      });

      await dio.post('/experts/me', data: formData);

      return const Right(null);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Failed to submit application';
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception('An unexpected error occurred.'));
    }
  }
}
