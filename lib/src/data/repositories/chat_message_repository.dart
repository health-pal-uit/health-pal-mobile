import 'package:da1/src/data/datasources/chat_message_remote_data_source.dart';
import 'package:da1/src/domain/entities/user_chat_message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatMessageRepository {
  Future<Either<Exception, Map<String, dynamic>>> getRecentMessages({
    required String sessionId,
    int limit = 50,
  });

  Future<Either<Exception, List<UserChatMessage>>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Exception, UserChatMessage>> sendMessage({
    required String sessionId,
    required String content,
  });

  Future<Either<Exception, UserChatMessage>> sendImageMessage({
    required String sessionId,
    required String imagePath,
    String? caption,
  });

  Future<Either<Exception, void>> deleteMessage({
    required String sessionId,
    required String messageId,
  });
}

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageRemoteDataSource remoteDataSource;

  ChatMessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, Map<String, dynamic>>> getRecentMessages({
    required String sessionId,
    int limit = 50,
  }) async {
    try {
      final result = await remoteDataSource.getRecentMessages(
        sessionId: sessionId,
        limit: limit,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<UserChatMessage>>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final messages = await remoteDataSource.getMessages(
        sessionId: sessionId,
        page: page,
        limit: limit,
      );
      return Right(messages);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, UserChatMessage>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        sessionId: sessionId,
        content: content,
      );
      return Right(message);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, UserChatMessage>> sendImageMessage({
    required String sessionId,
    required String imagePath,
    String? caption,
  }) async {
    try {
      final message = await remoteDataSource.sendImageMessage(
        sessionId: sessionId,
        imagePath: imagePath,
        caption: caption,
      );
      return Right(message);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteMessage({
    required String sessionId,
    required String messageId,
  }) async {
    try {
      await remoteDataSource.deleteMessage(
        sessionId: sessionId,
        messageId: messageId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
