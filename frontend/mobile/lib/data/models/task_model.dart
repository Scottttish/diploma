import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

part 'task_model.g.dart';

/// The API-facing representation of a Task.
/// Keeps JSON field naming and parsing logic strictly in the data layer.
@JsonSerializable(fieldRename: FieldRename.snake)
final class TaskModel {
  final String id;
  final String orderNumber;
  final String serviceType;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String status;
  final String priority;
  final String clientName;
  final String? clientPhone;
  final DateTime scheduledAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<String> attachmentUrls;
  final String? conversationId;

  const TaskModel({
    required this.id,
    required this.orderNumber,
    required this.serviceType,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.status,
    required this.priority,
    required this.clientName,
    this.clientPhone,
    required this.scheduledAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.attachmentUrls = const [],
    this.conversationId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      orderNumber: orderNumber,
      serviceType: serviceType,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      status: TaskStatus.fromString(status),
      priority: TaskPriority.fromString(priority),
      clientName: clientName,
      clientPhone: clientPhone,
      scheduledAt: scheduledAt,
      acceptedAt: acceptedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      attachmentUrls: attachmentUrls,
      conversationId: conversationId,
    );
  }
}
