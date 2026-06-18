import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

final class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;

  const ChatRepositoryImpl({required ChatRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<ConversationEntity> fetchConversation(String taskId) async {
    final model = await _remote.fetchConversation(taskId);
    return model.toEntity();
  }

  @override
  Future<ConversationEntity> getSupportConversation() async {
    final model = await _remote.getSupportConversation();
    return model.toEntity();
  }

  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    final models = await _remote.fetchMessages(conversationId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String messageText,
  }) async {
    final model = await _remote.sendMessage(
      conversationId: conversationId,
      messageText: messageText,
    );
    return model.toEntity();
  }
}
