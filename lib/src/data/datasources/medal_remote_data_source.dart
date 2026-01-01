import 'package:da1/src/domain/entities/medal.dart';
import 'package:dio/dio.dart';

abstract class MedalRemoteDataSource {
  Future<List<Medal>> getMedals();
}

class MedalRemoteDataSourceImpl implements MedalRemoteDataSource {
  final Dio dio;

  MedalRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Medal>> getMedals() async {
    try {
      final response = await dio.get('/medals/with-progress');

      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List<dynamic>;
        return data
            .map((json) => Medal.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load medals');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load medals');
    }
  }
}
