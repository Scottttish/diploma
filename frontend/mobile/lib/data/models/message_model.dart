import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/sender_type.dart';

part 'message_model.g.dart';

/// API-facing representation of a chat message.
@JsonSerializable(fieldRename: FieldRename.snake)
final class MessageModel {
  final String id;
  final String conversationId;
  final String senderType;
  final String messageText;
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.messageText,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderType: SenderType.fromString(senderType),
      messageText: messageText,
      sentAt: sentAt,
    );
  }
}
