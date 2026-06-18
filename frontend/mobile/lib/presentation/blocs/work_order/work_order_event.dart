part of 'work_order_bloc.dart';

sealed class WorkOrderEvent extends Equatable {
  const WorkOrderEvent();

  @override
  List<Object?> get props => [];
}

final class WorkOrderLoadRequested extends WorkOrderEvent {
  final String taskId;
  const WorkOrderLoadRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Worker taps Accept Job — moves from assigned to in_progress.
final class WorkOrderAccepted extends WorkOrderEvent {
  const WorkOrderAccepted();
}

/// Worker taps Complete Job and provides mandatory verification photo paths.
final class WorkOrderCompleted extends WorkOrderEvent {
  final List<String> photoPaths;
  const WorkOrderCompleted(this.photoPaths);

  @override
  List<Object?> get props => [photoPaths];
}
