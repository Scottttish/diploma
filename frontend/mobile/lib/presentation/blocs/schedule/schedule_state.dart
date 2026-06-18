part of 'schedule_bloc.dart';

sealed class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

final class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

final class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

final class ScheduleLoaded extends ScheduleState {
  final List<TaskEntity> tasks;
  final int activeCount;
  final int criticalCount;

  const ScheduleLoaded({
    required this.tasks,
    required this.activeCount,
    required this.criticalCount,
  });

  @override
  List<Object?> get props => [tasks, activeCount, criticalCount];
}

final class ScheduleError extends ScheduleState {
  final String message;
  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
