// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'].toString(),
      taskId: json['task_id']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'created_at': instance.createdAt.toIso8601String(),
    };
