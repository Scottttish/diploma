import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

/// Bridges the domain contract to the remote data source.
/// This is where you would add a local cache layer later if needed.
final class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;

  const TaskRepositoryImpl({required TaskRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<List<TaskEntity>> fetchTodaySchedule() async {
    final models = await _remote.fetchTodaySchedule();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TaskEntity> fetchTaskById(String taskId) async {
    final model = await _remote.fetchTaskById(taskId);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> updateTaskStatus(
      String taskId, TaskStatus newStatus) async {
    final model = await _remote.updateTaskStatus(taskId, newStatus);
    return model.toEntity();
  }

  @override
  Future<List<String>> uploadVerificationPhotos(
      String taskId, List<String> localFilePaths) {
    return _remote.uploadVerificationPhotos(taskId, localFilePaths);
  }

  @override
  Future<List<TaskEntity>> fetchCompletedJobs({int page = 1}) async {
    final models = await _remote.fetchCompletedJobs(page: page);
    return models.map((m) => m.toEntity()).toList();
  }
}
