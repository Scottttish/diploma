import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Contract for the chat data source, keeping the BLoC decoupled
/// from the specific polling or WebSocket strategy used underneath.
abstract interface class ChatRepository {
  Future<ConversationEntity> fetchConversation(String taskId);

  Future<ConversationEntity> getSupportConversation();

  Future<List<MessageEntity>> fetchMessages(String conversationId);

  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String messageText,
  });
}
