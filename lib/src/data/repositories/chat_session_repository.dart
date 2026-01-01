import 'package:da1/src/data/datasources/chat_session_remote_data_source.dart';
import 'package:da1/src/domain/entities/chat_session.dart';
import 'package:dartz/dartz.dart';

abstract class ChatSessionRepository {
  Future<Either<Exception, List<ChatSession>>> getSessions({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Exception, ChatSession>> getSession(String sessionId);

  Future<Either<Exception, ChatSession>> createSession({
    required String otherUserId,
    required String title,
  });

  Future<Either<Exception, ChatSession>> createGroupSession({
    required String title,
    required List<String> userIds,
  });

  Future<Either<Exception, void>> leaveSession(String sessionId);

  Future<Either<Exception, void>> deleteSession(String sessionId);

  Future<Either<Exception, void>> addParticipant({
    required String chatSessionId,
    required String userId,
    bool isAdmin = false,
  });
}

class ChatSessionRepositoryImpl implements ChatSessionRepository {
  final ChatSessionRemoteDataSource remoteDataSource;

  ChatSessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<ChatSession>>> getSessions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final sessions = await remoteDataSource.getSessions(
        page: page,
        limit: limit,
      );
      return Right(sessions);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ChatSession>> getSession(String sessionId) async {
    try {
      final session = await remoteDataSource.getSession(sessionId);
      return Right(session);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ChatSession>> createSession({
    required String otherUserId,
    required String title,
  }) async {
    try {
      final session = await remoteDataSource.createSession(
        otherUserId: otherUserId,
        title: title,
      );
      return Right(session);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, ChatSession>> createGroupSession({
    required String title,
    required List<String> userIds,
  }) async {
    try {
      final session = await remoteDataSource.createGroupSession(
        title: title,
        userIds: userIds,
      );
      return Right(session);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> leaveSession(String sessionId) async {
    try {
      await remoteDataSource.leaveSession(sessionId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> addParticipant({
    required String chatSessionId,
    required String userId,
    bool isAdmin = false,
  }) async {
    try {
      await remoteDataSource.addParticipant(
        chatSessionId: chatSessionId,
        userId: userId,
        isAdmin: isAdmin,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
