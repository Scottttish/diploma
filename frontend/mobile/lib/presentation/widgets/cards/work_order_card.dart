import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_status.dart';
import 'priority_badge.dart';

/// The main list item on the schedule screen.
/// Structural design rule: every data field visible here answers one of
/// the four operational questions (what, where, when, how urgent).
class WorkOrderCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onOpen;

  const WorkOrderCard({
    super.key,
    required this.task,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final isCompleted = task.status == TaskStatus.completed;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.priorityCompleted.withOpacity(0.06)
            : cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted
              ? AppColors.priorityCompleted.withOpacity(0.4)
              : cs.outline,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PriorityAccentBar(
                priority: task.priority,
                overrideColor: isCompleted ? AppColors.priorityCompleted : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(task: task),
                      const SizedBox(height: 8),
                      _ServiceTypeRow(task: task),
                      const SizedBox(height: 6),
                      _AddressRow(address: task.address),
                      const SizedBox(height: 12),
                      _Footer(
                        scheduledAt: task.scheduledAt,
                        timeFormat: timeFormat,
                        onOpen: onOpen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TaskEntity task;
  const _Header({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'WORK ORDER #${task.orderNumber}',
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.operationalBlue,
              letterSpacing: 0.4,
            ),
          ),
        ),
        task.status == TaskStatus.completed
            ? const StatusBadge(
                label: 'COMPLETED',
                color: AppColors.priorityCompleted,
              )
            : PriorityBadge(priority: task.priority),
      ],
    );
  }
}

class _ServiceTypeRow extends StatelessWidget {
  final TaskEntity task;
  const _ServiceTypeRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.build_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            task.serviceType,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String address;
  const _AddressRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_outlined,
            size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            address,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final DateTime scheduledAt;
  final DateFormat timeFormat;
  final VoidCallback onOpen;

  const _Footer({
    required this.scheduledAt,
    required this.timeFormat,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule_outlined,
            size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
        const SizedBox(width: 5),
        Text(
          timeFormat.format(scheduledAt),
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: onOpen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.operationalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            child: const Text('OPEN'),
          ),
        ),
      ],
    );
  }
}
