/// Lifecycle states of a work order, in the order they progress.
/// Only forward transitions are valid — a task cannot go back to assigned
/// once it's in_progress, for example.
enum TaskStatus {
  pending('pending'),
  assigned('assigned'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String raw) {
    return TaskStatus.values.firstWhere(
      (s) => s.value == raw.toLowerCase(),
      orElse: () => TaskStatus.pending,
    );
  }

  /// Returns true when transitioning to [next] is a valid forward move.
  bool canTransitionTo(TaskStatus next) {
    const transitions = {
      TaskStatus.assigned: {TaskStatus.inProgress},
      TaskStatus.inProgress: {TaskStatus.completed},
    };
    return transitions[this]?.contains(next) ?? false;
  }
}
