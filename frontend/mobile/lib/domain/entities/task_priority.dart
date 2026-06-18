/// Priority levels mirror exactly what the backend stores on the Task record.
/// The values here are the raw strings from the API response.
enum TaskPriority {
  critical('critical'),
  high('high'),
  normal('normal');

  const TaskPriority(this.value);
  final String value;

  static TaskPriority fromString(String raw) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == raw.toLowerCase(),
      orElse: () => TaskPriority.normal,
    );
  }
}
