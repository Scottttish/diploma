import 'package:equatable/equatable.dart';
import 'sender_type.dart';

/// A single chat message in a task conversation.
/// Matches the messages table: id, conversation_id, sender_type, message_text.
final class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final SenderType senderType;
  final String messageText;
  final DateTime sentAt;

  /// When true the message was created locally before the server confirmed it.
  /// We use this to show a "sending..." indicator without blocking the UI.
  final bool isPending;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.messageText,
    required this.sentAt,
    this.isPending = false,
  });

  MessageEntity copyWith({bool? isPending, String? id}) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId,
      senderType: senderType,
      messageText: messageText,
      sentAt: sentAt,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  List<Object?> get props => [id, conversationId, senderType, sentAt];
}
