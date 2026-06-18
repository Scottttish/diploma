import 'package:equatable/equatable.dart';
import 'task_priority.dart';
import 'task_status.dart';

/// The core domain representation of a work order / task.
/// This entity is technology-agnostic — no JSON annotations here.
/// Conversion to/from API payloads lives in the data layer model.
final class TaskEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String serviceType;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final TaskStatus status;
  final TaskPriority priority;
  final String clientName;
  final String? clientPhone;
  final DateTime scheduledAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<String> attachmentUrls;
  final String? conversationId;

  const TaskEntity({
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

  /// Total active duration is only meaningful for completed tasks.
  Duration? get activeDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  TaskEntity copyWith({
    TaskStatus? status,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    List<String>? attachmentUrls,
    String? conversationId,
  }) {
    return TaskEntity(
      id: id,
      orderNumber: orderNumber,
      serviceType: serviceType,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      priority: priority,
      clientName: clientName,
      clientPhone: clientPhone,
      scheduledAt: scheduledAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        priority,
        scheduledAt,
        attachmentUrls,
        conversationId,
      ];
}
