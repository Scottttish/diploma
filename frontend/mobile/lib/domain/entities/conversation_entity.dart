import 'package:equatable/equatable.dart';

/// Ties a chat thread to a task or a support session.
/// task_id is null for worker ↔ dispatcher support conversations.
final class ConversationEntity extends Equatable {
  final String id;
  final String? taskId;
  final DateTime createdAt;

  const ConversationEntity({
    required this.id,
    this.taskId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, taskId];
}
