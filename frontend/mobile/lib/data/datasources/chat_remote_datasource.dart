import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

final class ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<ConversationModel> fetchConversation(String taskId) async {
    final response = await _dio.get<Map<String, dynamic>>('/conversations', queryParameters: {
      'task_id': taskId,
    });
    return ConversationModel.fromJson(response.data!);
  }

  Future<ConversationModel> getSupportConversation() async {
    final response = await _dio.get<Map<String, dynamic>>('/conversations/support');
    return ConversationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    final response =
        await _dio.get<List<dynamic>>('/conversations/$conversationId/messages');
    return response.data!
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String messageText,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {
        'message_text': messageText,
        'sender_type': 'worker',
      },
    );
    return MessageModel.fromJson(response.data!);
  }
}
