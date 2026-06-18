import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_status.dart';
import '../../../domain/repositories/task_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

final class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final TaskRepository _taskRepository;

  ScheduleBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const ScheduleInitial()) {
    on<ScheduleLoadRequested>(_onLoad);
    on<ScheduleRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoad(
    ScheduleLoadRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    await _loadTasks(emit);
  }

  Future<void> _onRefresh(
    ScheduleRefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await _loadTasks(emit);
  }

  Future<void> _loadTasks(Emitter<ScheduleState> emit) async {
    try {
      final tasks = await _taskRepository.fetchTodaySchedule();

      final activeStatuses = {TaskStatus.assigned, TaskStatus.inProgress};
      final activeCount =
          tasks.where((t) => activeStatuses.contains(t.status)).length;
      final criticalCount = tasks
          .where((t) =>
              activeStatuses.contains(t.status) &&
              t.priority.value == 'critical')
          .length;

      emit(ScheduleLoaded(
        tasks: tasks,
        activeCount: activeCount,
        criticalCount: criticalCount,
      ));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
