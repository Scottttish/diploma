import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/task_status.dart';
import '../models/task_model.dart';

/// Makes the actual HTTP calls for task operations.
/// All JSON parsing is delegated to TaskModel.fromJson —
/// this class only cares about request construction and response extraction.
final class TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<List<TaskModel>> fetchTodaySchedule() async {
    final response = await _dio.get<List<dynamic>>('/tasks/today');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> fetchTaskById(String taskId) async {
    final response = await _dio.get<Map<String, dynamic>>('/tasks/$taskId');
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> updateTaskStatus(
      String taskId, TaskStatus newStatus) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/tasks/$taskId/status',
      data: {'status': newStatus.value},
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<List<String>> uploadVerificationPhotos(
    String taskId,
    List<String> localFilePaths,
  ) async {
    final formData = FormData();
    for (final path in localFilePaths) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(path),
      ));
    }

    final response = await _dio.post<List<dynamic>>(
      '/tasks/$taskId/attachments',
      data: formData,
    );

    return (response.data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<TaskModel>> fetchCompletedJobs({int page = 1}) async {
    final response = await _dio.get<List<dynamic>>(
      '/tasks',
      queryParameters: {'status': 'completed', 'page': page},
    );
    return response.data!
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
