import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_status.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/usecases/advance_task_status.dart';
import '../../../core/errors/app_exception.dart';

part 'work_order_event.dart';
part 'work_order_state.dart';

/// Manages the full lifecycle of a single work order on the detail screen.
///
/// The key design decision here: the BLoC validates the transition via the
/// AdvanceTaskStatus use case before any network call. This means the UI
/// never shows a loading spinner for a move we already know is illegal.
final class WorkOrderBloc extends Bloc<WorkOrderEvent, WorkOrderState> {
  final TaskRepository _taskRepository;
  final AdvanceTaskStatus _advanceTaskStatus;

  WorkOrderBloc({
    required TaskRepository taskRepository,
    required AdvanceTaskStatus advanceTaskStatus,
  })  : _taskRepository = taskRepository,
        _advanceTaskStatus = advanceTaskStatus,
        super(const WorkOrderInitial()) {
    on<WorkOrderLoadRequested>(_onLoad);
    on<WorkOrderAccepted>(_onAccepted);
    on<WorkOrderCompleted>(_onCompleted);
  }

  Future<void> _onLoad(
    WorkOrderLoadRequested event,
    Emitter<WorkOrderState> emit,
  ) async {
    emit(const WorkOrderLoading());
    try {
      final task = await _taskRepository.fetchTaskById(event.taskId);
      emit(WorkOrderLoaded(task));
    } catch (e) {
      emit(WorkOrderError(e.toString()));
    }
  }

  Future<void> _onAccepted(
    WorkOrderAccepted event,
    Emitter<WorkOrderState> emit,
  ) async {
    final current = state;
    if (current is! WorkOrderLoaded) return;

    emit(WorkOrderTransitioning(
      task: current.task,
      actionLabel: 'Accepting job...',
    ));

    try {
      final updated =
          await _advanceTaskStatus(current.task, TaskStatus.inProgress);
      emit(WorkOrderTransitioned(updated));
      emit(WorkOrderLoaded(updated));
    } on StateTransitionException catch (e) {
      emit(WorkOrderError(e.message, task: current.task));
      emit(WorkOrderLoaded(current.task));
    } catch (e) {
      emit(WorkOrderError(e.toString(), task: current.task));
      emit(WorkOrderLoaded(current.task));
    }
  }

  Future<void> _onCompleted(
    WorkOrderCompleted event,
    Emitter<WorkOrderState> emit,
  ) async {
    final current = state;
    if (current is! WorkOrderLoaded) return;

    emit(WorkOrderTransitioning(
      task: current.task,
      actionLabel: 'Uploading photos...',
    ));

    try {
      // Upload verification photos first — the backend requires at least one.
      await _taskRepository.uploadVerificationPhotos(
        current.task.id,
        event.photoPaths,
      );

      final updated =
          await _advanceTaskStatus(current.task, TaskStatus.completed);
      emit(WorkOrderTransitioned(updated));
      emit(WorkOrderLoaded(updated));
    } on StateTransitionException catch (e) {
      emit(WorkOrderError(e.message, task: current.task));
      emit(WorkOrderLoaded(current.task));
    } catch (e) {
      emit(WorkOrderError(e.toString(), task: current.task));
      emit(WorkOrderLoaded(current.task));
    }
  }
}
