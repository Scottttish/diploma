import 'package:flutter/material.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../theme/app_colors.dart';

/// Maps domain enum values to the correct display color and label.
/// Centralizing this prevents the same switch statement from being copied
/// across every widget that needs to color-code a priority or status.
abstract final class PriorityUiHelper {
  static Color colorForPriority(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.critical => AppColors.priorityCritical,
      TaskPriority.high => AppColors.priorityHigh,
      TaskPriority.normal => AppColors.priorityNormal,
    };
  }

  static String labelForPriority(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.critical => 'CRITICAL',
      TaskPriority.high => 'HIGH',
      TaskPriority.normal => 'NORMAL',
    };
  }

  static Color colorForStatus(TaskStatus status) {
    return switch (status) {
      TaskStatus.assigned => AppColors.priorityNormal,
      TaskStatus.inProgress => AppColors.safetyOrange,
      TaskStatus.completed => AppColors.priorityCompleted,
      TaskStatus.cancelled => AppColors.onSurfaceMuted,
      TaskStatus.pending => AppColors.onSurfaceMuted,
    };
  }

  static String labelForStatus(TaskStatus status) {
    return switch (status) {
      TaskStatus.assigned => 'Assigned',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
      TaskStatus.cancelled => 'Cancelled',
      TaskStatus.pending => 'Pending',
    };
  }
}

abstract final class DurationFormatter {
  static String format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
