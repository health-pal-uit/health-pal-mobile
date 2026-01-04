import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> updateAvatar(String imagePath);
  Future<Either<Exception, Map<String, dynamic>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile();
}
