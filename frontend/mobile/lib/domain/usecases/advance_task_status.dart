import '../entities/task_entity.dart';
import '../entities/task_status.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/app_exception.dart';

/// Wraps the status transition with a guard that enforces the lifecycle rules
/// before any network call is made — keeps validation out of the BLoC.
final class AdvanceTaskStatus {
  final TaskRepository _repository;

  const AdvanceTaskStatus(this._repository);

  Future<TaskEntity> call(TaskEntity task, TaskStatus targetStatus) async {
    if (!task.status.canTransitionTo(targetStatus)) {
      throw StateTransitionException(
        'Cannot move task ${task.orderNumber} from '
        '${task.status.value} to ${targetStatus.value}.',
      );
    }
    return _repository.updateTaskStatus(task.id, targetStatus);
  }
}
