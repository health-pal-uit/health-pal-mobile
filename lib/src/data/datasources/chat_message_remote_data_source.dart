import 'package:da1/src/domain/entities/user_chat_message.dart';
import 'package:dio/dio.dart';

abstract class ChatMessageRemoteDataSource {
  /// Get recent messages for a chat session
  Future<Map<String, dynamic>> getRecentMessages({
    required String sessionId,
    int limit = 50,
  });

  /// Get messages for a chat session with pagination
  Future<List<UserChatMessage>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  });

  /// Send a text message
  Future<UserChatMessage> sendMessage({
    required String sessionId,
    required String content,
  });

  /// Send an image message
  Future<UserChatMessage> sendImageMessage({
    required String sessionId,
    required String imagePath,
    String? caption,
  });

  /// Delete a message
  Future<void> deleteMessage({
    required String sessionId,
    required String messageId,
  });
}

class ChatMessageRemoteDataSourceImpl implements ChatMessageRemoteDataSource {
  final Dio dio;

  ChatMessageRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getRecentMessages({
    required String sessionId,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/chat-messages/session/$sessionId/recent',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final innerData = responseData['data'] as Map<String, dynamic>;
        final data = innerData['data'] as List<dynamic>;
        final total = innerData['total'] as int;

        return {
          'messages':
              data
                  .map(
                    (json) =>
                        UserChatMessage.fromJson(json as Map<String, dynamic>),
                  )
                  .toList(),
          'total': total,
        };
      }

      throw Exception('Failed to load recent messages');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load recent messages',
      );
    }
  }

  @override
  Future<List<UserChatMessage>> getMessages({
    required String sessionId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/chat-messages/session/$sessionId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map(
              (json) => UserChatMessage.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load messages');
    }
  }

  @override
  Future<UserChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final response = await dio.post(
        '/chat-sessions/$sessionId/messages',
        data: {'content': content, 'message_type': 'text'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserChatMessage.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to send message');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send message');
    }
  }

  @override
  Future<UserChatMessage> sendImageMessage({
    required String sessionId,
    required String imagePath,
    String? caption,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'message_type': 'image',
        if (caption != null && caption.isNotEmpty) 'content': caption,
      });

      final response = await dio.post(
        '/chat-sessions/$sessionId/messages',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserChatMessage.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to send image');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send image');
    }
  }

  @override
  Future<void> deleteMessage({
    required String sessionId,
    required String messageId,
  }) async {
    try {
      final response = await dio.delete(
        '/chat-sessions/$sessionId/messages/$messageId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete message');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete message',
      );
    }
  }
}
