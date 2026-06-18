import '../entities/task_entity.dart';
import '../entities/task_status.dart';

/// Contract that every task data source must implement.
/// The BLoC depends on this abstraction, not on any concrete HTTP class.
abstract interface class TaskRepository {
  /// Returns today's tasks assigned to the authenticated worker,
  /// sorted chronologically by scheduledAt.
  Future<List<TaskEntity>> fetchTodaySchedule();

  /// Returns the full detail of a single work order.
  Future<TaskEntity> fetchTaskById(String taskId);

  /// Advances the task lifecycle to [newStatus].
  /// Throws a [StateTransitionException] if the transition is illegal.
  Future<TaskEntity> updateTaskStatus(String taskId, TaskStatus newStatus);

  /// Uploads verification photos and returns the confirmed attachment URLs.
  Future<List<String>> uploadVerificationPhotos(
      String taskId, List<String> localFilePaths);

  /// Returns all tasks with status == completed for the authenticated worker.
  Future<List<TaskEntity>> fetchCompletedJobs({int page = 1});
}
