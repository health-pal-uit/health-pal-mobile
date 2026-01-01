import 'package:da1/src/domain/entities/challenge.dart';
import 'package:dio/dio.dart';

abstract class ChallengeRemoteDataSource {
  Future<List<Challenge>> getChallenges();
  Future<void> finishChallenge(String challengeId);
}

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  final Dio dio;

  ChallengeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Challenge>> getChallenges() async {
    try {
      final response = await dio.get('/challenges/with-progress');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load challenges');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load challenges',
      );
    }
  }

  @override
  Future<void> finishChallenge(String challengeId) async {
    try {
      final response = await dio.post('/challenges-users/$challengeId/finish');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to finish challenge');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to finish challenge',
      );
    }
  }
}
