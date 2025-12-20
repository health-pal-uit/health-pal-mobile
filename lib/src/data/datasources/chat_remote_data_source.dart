import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/chat_model.dart';
import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<ChatResponse> sendMessage({
    required String message,
    List<ChatHistoryItem>? history,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<ChatResponse> sendMessage({
    required String message,
    List<ChatHistoryItem>? history,
  }) async {
    final request = ChatRequest(message: message, history: history);

    final response = await dio.post(ApiConfig.chatAI, data: request.toJson());

    return ChatResponse.fromJson(response.data);
  }
}
