// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `flutter pub run build_runner build` to regenerate.
// Manually patched to handle backend int ids and nullable string fields.

part of 'task_model.dart';

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'normal',
      clientName: json['client_name'] as String? ?? '',
      clientPhone: json['client_phone'] as String?,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : DateTime.now(),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      conversationId: json['conversation_id']?.toString(),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'service_type': instance.serviceType,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'priority': instance.priority,
      'client_name': instance.clientName,
      'client_phone': instance.clientPhone,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'attachment_urls': instance.attachmentUrls,
      'conversation_id': instance.conversationId,
    };
