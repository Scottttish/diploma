import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_status.dart';

/// Vertical milestone tracker matching the physical inspection report format.
/// Each milestone that has a real timestamp is "completed" on the track;
/// the current step is "active"; future steps are dimmed.
class TaskTimeline extends StatelessWidget {
  final TaskEntity task;

  const TaskTimeline({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final milestones = _buildMilestones(task);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < milestones.length; i++)
          _TimelineTile(
            milestone: milestones[i],
            isLast: i == milestones.length - 1,
          ),
      ],
    );
  }

  List<_Milestone> _buildMilestones(TaskEntity task) {
    return [
      _Milestone(
        label: 'Request Created',
        timestamp: task.scheduledAt,
        state: _MilestoneState.completed,
      ),
      _Milestone(
        label: 'Assigned to Worker',
        timestamp: task.acceptedAt ?? task.scheduledAt,
        state: task.acceptedAt != null
            ? _MilestoneState.completed
            : _currentOrFuture(task.status, TaskStatus.assigned),
      ),
      _Milestone(
        label: 'Work Started',
        timestamp: task.startedAt,
        state: task.startedAt != null
            ? _MilestoneState.completed
            : _currentOrFuture(task.status, TaskStatus.inProgress),
      ),
      _Milestone(
        label: 'Work Completed',
        timestamp: task.completedAt,
        state: task.completedAt != null
            ? _MilestoneState.completed
            : _currentOrFuture(task.status, TaskStatus.completed),
      ),
    ];
  }

  _MilestoneState _currentOrFuture(
      TaskStatus current, TaskStatus milestoneStatus) {
    if (current == milestoneStatus) return _MilestoneState.active;
    return _MilestoneState.future;
  }
}

enum _MilestoneState { completed, active, future }

class _Milestone {
  final String label;
  final DateTime? timestamp;
  final _MilestoneState state;

  const _Milestone({
    required this.label,
    required this.timestamp,
    required this.state,
  });
}

class _TimelineTile extends StatelessWidget {
  final _Milestone milestone;
  final bool isLast;

  const _TimelineTile({required this.milestone, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    final dotColor = switch (milestone.state) {
      _MilestoneState.completed => AppColors.timelineCompleted,
      _MilestoneState.active => AppColors.timelineActive,
      _MilestoneState.future => AppColors.timelinePending,
    };

    final labelColor = switch (milestone.state) {
      _MilestoneState.completed => AppColors.onSurface,
      _MilestoneState.active => AppColors.operationalBlue,
      _MilestoneState.future => AppColors.onSurfaceMuted,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(
                  milestone.timestamp != null
                      ? timeFormat.format(milestone.timestamp!)
                      : '--:--',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: milestone.state == _MilestoneState.future
                        ? AppColors.onSurfaceMuted
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: milestone.state == _MilestoneState.active
                      ? Border.all(
                          color: AppColors.operationalBlue.withOpacity(0.3),
                          width: 3,
                        )
                      : null,
                ),
                child: milestone.state == _MilestoneState.completed
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: milestone.state == _MilestoneState.completed
                        ? AppColors.timelineCompleted.withOpacity(0.4)
                        : AppColors.timelinePending,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Text(
                milestone.label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 13,
                  fontWeight: milestone.state == _MilestoneState.active
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
