import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/conversation_entity.dart';

part 'conversation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ConversationModel {
  final String id;
  final String? taskId;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    this.taskId,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  ConversationEntity toEntity() {
    return ConversationEntity(id: id, taskId: taskId, createdAt: createdAt);
  }
}
