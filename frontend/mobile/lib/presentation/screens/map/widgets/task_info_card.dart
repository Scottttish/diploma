import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/priority_ui_helper.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../presentation/widgets/cards/priority_badge.dart';
import 'navigation_sheet.dart';

/// Floating overlay card shown when a task marker is tapped.
/// Displays key metadata and provides Navigate / Open Task actions.
class TaskInfoCard extends StatelessWidget {
  final TaskEntity task;
  final int taskIndex;
  final LatLng? workerLocation;

  const TaskInfoCard({
    super.key,
    required this.task,
    required this.taskIndex,
    this.workerLocation,
  });

  String _distanceLabel() {
    if (workerLocation == null ||
        task.latitude == null ||
        task.longitude == null) {
      return '—';
    }
    final meters = const Distance().as(
      LengthUnit.Meter,
      workerLocation!,
      LatLng(task.latitude!, task.longitude!),
    );
    return meters < 1000
        ? '${meters.round()} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final time = DateFormat('HH:mm').format(task.scheduledAt);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: stop number, order ID, priority badge
            Row(
              children: [
                _StopDot(
                  index: taskIndex,
                  color: PriorityUiHelper.colorForPriority(task.priority),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.orderNumber,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.operationalBlue,
                    ),
                  ),
                ),
                PriorityBadge(priority: task.priority),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.location_on_outlined, text: task.address),
            const SizedBox(height: 3),
            _InfoRow(icon: Icons.build_circle_outlined, text: task.serviceType),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(icon: Icons.schedule_outlined, text: time),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.near_me_outlined,
                    text: _distanceLabel(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/work-order/${task.id}'),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: Text(
                      l.workOrderTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'IBMPlexSans',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.latitude != null && task.longitude != null
                        ? () => showNavigationSheet(
                              context,
                              lat: task.latitude!,
                              lng: task.longitude!,
                            )
                        : null,
                    icon: const Icon(Icons.navigation_rounded, size: 14),
                    label: Text(
                      l.navigate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'IBMPlexSans',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StopDot extends StatelessWidget {
  final int index;
  final Color color;

  const _StopDot({required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'IBMPlexSans',
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.onSurfaceMuted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              color: AppColors.onSurfaceMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
