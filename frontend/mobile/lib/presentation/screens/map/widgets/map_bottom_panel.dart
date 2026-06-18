import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/priority_ui_helper.dart';
import '../../../../data/datasources/route_remote_datasource.dart';
import '../../../../data/models/task_model.dart';
import '../../../../l10n/app_localizations.dart';

/// Draggable bottom sheet showing today's stop list and route summary.
class MapBottomPanel extends StatelessWidget {
  final List<TaskModel> tasks;
  final RouteResult? routeResult;
  final bool routeLoading;
  final bool routeError;
  final ScrollController scrollController;

  /// Called when the user taps a stop row; receives the task and its 1-based index.
  final void Function(TaskModel task, int index) onTaskTap;
  final VoidCallback onRetryRoute;

  const MapBottomPanel({
    super.key,
    required this.tasks,
    required this.routeResult,
    required this.routeLoading,
    required this.routeError,
    required this.scrollController,
    required this.onTaskTap,
    required this.onRetryRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final withCoords = tasks
        .where((t) => t.latitude != null && t.longitude != null)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Section header
          Row(
            children: [
              Text(
                l.todaysRoute.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              if (routeLoading)
                const _LoadingChip()
              else if (routeResult != null && !routeError)
                Text(
                  '${withCoords.length} '
                  '${withCoords.length == 1 ? 'stop' : 'stops'} · '
                  '${routeResult!.distanceLabel} · ${routeResult!.durationLabel}',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Content states
          if (routeError)
            _ErrorBanner(onRetry: onRetryRoute)
          else if (withCoords.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.noTasksWithLocation,
                style: const TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontFamily: 'IBMPlexSans',
                  fontSize: 13,
                ),
              ),
            )
          else
            ...withCoords.asMap().entries.map(
                  (e) => _StopRow(
                    task: e.value,
                    index: e.key + 1,
                    onTap: () => onTaskTap(e.value, e.key + 1),
                  ),
                ),

          // Travel time footer
          if (routeResult != null && !routeError) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.onSurfaceMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  l.estTravelTime(routeResult!.durationLabel),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'IBMPlexSans',
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _StopRow extends StatelessWidget {
  final TaskModel task;
  final int index;
  final VoidCallback onTap;

  const _StopRow({
    required this.task,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entity = task.toEntity();
    final color = PriorityUiHelper.colorForPriority(entity.priority);
    final time = DateFormat('HH:mm').format(entity.scheduledAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            // Stop number circle
            Container(
              width: 26,
              height: 26,
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
            ),
            const SizedBox(width: 10),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceMuted,
                fontFamily: 'IBMPlexSans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.serviceType,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'IBMPlexSans',
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entity.address,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'IBMPlexSans',
                      color: AppColors.onSurfaceMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.onSurfaceMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingChip extends StatelessWidget {
  const _LoadingChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.onSurfaceMuted.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Loading…',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 11,
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.priorityCritical.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.priorityCritical.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.priorityCritical,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Route unavailable',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                color: AppColors.priorityCritical,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.operationalBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
