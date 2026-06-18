// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderType: json['sender_type'] as String,
      messageText: json['message_text'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_type': instance.senderType,
      'message_text': instance.messageText,
      'sent_at': instance.sentAt.toIso8601String(),
    };
