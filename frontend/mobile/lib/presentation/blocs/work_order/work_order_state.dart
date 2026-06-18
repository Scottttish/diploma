part of 'work_order_bloc.dart';

sealed class WorkOrderState extends Equatable {
  const WorkOrderState();

  @override
  List<Object?> get props => [];
}

final class WorkOrderInitial extends WorkOrderState {
  const WorkOrderInitial();
}

final class WorkOrderLoading extends WorkOrderState {
  const WorkOrderLoading();
}

final class WorkOrderLoaded extends WorkOrderState {
  final TaskEntity task;

  const WorkOrderLoaded(this.task);

  @override
  List<Object?> get props => [task];
}

/// A status transition is actively being sent to the server.
final class WorkOrderTransitioning extends WorkOrderState {
  final TaskEntity task;
  final String actionLabel;

  const WorkOrderTransitioning({required this.task, required this.actionLabel});

  @override
  List<Object?> get props => [task, actionLabel];
}

/// Transition completed successfully — the task has a new status.
final class WorkOrderTransitioned extends WorkOrderState {
  final TaskEntity task;

  const WorkOrderTransitioned(this.task);

  @override
  List<Object?> get props => [task];
}

final class WorkOrderError extends WorkOrderState {
  final String message;
  final TaskEntity? task;

  const WorkOrderError(this.message, {this.task});

  @override
  List<Object?> get props => [message];
}
