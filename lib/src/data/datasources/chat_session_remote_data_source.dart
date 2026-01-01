import 'package:da1/src/domain/entities/chat_session.dart';
import 'package:dio/dio.dart';

abstract class ChatSessionRemoteDataSource {
  /// Get all chat sessions for current user
  Future<List<ChatSession>> getSessions({int page = 1, int limit = 20});

  /// Get a specific chat session by ID
  Future<ChatSession> getSession(String sessionId);

  /// Create a new 1-1 chat session with another user
  Future<ChatSession> createSession({
    required String otherUserId,
    required String title,
  });

  /// Create a new group chat session
  Future<ChatSession> createGroupSession({
    required String title,
    required List<String> userIds,
  });

  /// Leave a chat session
  Future<void> leaveSession(String sessionId);

  /// Delete a chat session (admin only for groups)
  Future<void> deleteSession(String sessionId);
}

class ChatSessionRemoteDataSourceImpl implements ChatSessionRemoteDataSource {
  final Dio dio;

  ChatSessionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChatSession>> getSessions({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/chat-sessions',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load chat sessions');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load chat sessions',
      );
    }
  }

  @override
  Future<ChatSession> getSession(String sessionId) async {
    try {
      final response = await dio.get('/chat-sessions/$sessionId');

      if (response.statusCode == 200) {
        return ChatSession.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to load chat session');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load chat session',
      );
    }
  }

  @override
  Future<ChatSession> createSession({
    required String otherUserId,
    required String title,
  }) async {
    try {
      final response = await dio.post(
        '/chat-sessions',
        data: {
          'title': title,
          'is_group': false,
          'participant_ids': [otherUserId],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatSession.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to create chat session');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create chat session',
      );
    }
  }

  @override
  Future<ChatSession> createGroupSession({
    required String title,
    required List<String> userIds,
  }) async {
    try {
      final response = await dio.post(
        '/chat-sessions/groups',
        data: {'title': title, 'user_ids': userIds},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatSession.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to create group chat');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create group chat',
      );
    }
  }

  @override
  Future<void> leaveSession(String sessionId) async {
    try {
      final response = await dio.delete('/chat-sessions/$sessionId/leave');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to leave chat session');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to leave chat session',
      );
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await dio.delete('/chat-sessions/$sessionId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete chat session');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete chat session',
      );
    }
  }
}
