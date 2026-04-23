import 'dart:io';
import 'package:dio/dio.dart';

abstract class ExpertRemoteDataSource {
  Future<List<Map<String, dynamic>>> getExpertRoles();
  Future<void> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  });
}

class ExpertRemoteDataSourceImpl implements ExpertRemoteDataSource {
  final Dio dio;

  ExpertRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getExpertRoles() async {
    final response = await dio.get('/expert-roles');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  @override
  Future<void> registerExpert({
    required String roleId,
    required String licenseId,
    required String bio,
    required int fee,
    required File licensePhoto,
  }) async {
    final fileName = licensePhoto.path.split('/').last;

    final formData = FormData.fromMap({
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
  }
}
