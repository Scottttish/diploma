part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleLoadRequested extends ScheduleEvent {
  const ScheduleLoadRequested();
}

final class ScheduleRefreshRequested extends ScheduleEvent {
  const ScheduleRefreshRequested();
}
