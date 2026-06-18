import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/map_launcher.dart';
import '../../../core/utils/priority_ui_helper.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_status.dart';
import '../../blocs/work_order/work_order_bloc.dart';
import '../../widgets/sla_countdown_timer.dart';
import '../../widgets/timeline/task_timeline.dart';
import '../chat/chat_screen.dart';

class WorkOrderScreen extends StatefulWidget {
  final String taskId;

  const WorkOrderScreen({super.key, required this.taskId});

  @override
  State<WorkOrderScreen> createState() => _WorkOrderScreenState();
}

class _WorkOrderScreenState extends State<WorkOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<WorkOrderBloc>().add(WorkOrderLoadRequested(widget.taskId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkOrderBloc, WorkOrderState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(state),
          body: switch (state) {
            WorkOrderInitial() ||
            WorkOrderLoading() =>
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.operationalBlue,
                ),
              ),
            WorkOrderLoaded() ||
            WorkOrderTransitioning() ||
            WorkOrderTransitioned() =>
              _buildBody(context, _extractTask(state)!, state),
            WorkOrderError(task: null) => _buildError(state),
            WorkOrderError(task: final t) =>
              _buildBody(context, t!, state),
          },
          bottomNavigationBar: _buildActionBar(state),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, WorkOrderState state) {
    if (state is WorkOrderError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.priorityCritical,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  TaskEntity? _extractTask(WorkOrderState state) {
    return switch (state) {
      WorkOrderLoaded(task: final t) => t,
      WorkOrderTransitioning(task: final t) => t,
      WorkOrderTransitioned(task: final t) => t,
      WorkOrderError(task: final t) => t,
      _ => null,
    };
  }

  PreferredSizeWidget _buildAppBar(WorkOrderState state) {
    final task = _extractTask(state);
    return AppBar(
      backgroundColor: AppColors.operationalBlue,
      foregroundColor: Colors.white,
      title: Text(
        task != null
            ? 'WO #${task.orderNumber}'
            : AppLocalizations.of(context)!.workOrderTitle,
        style: const TextStyle(fontFamily: 'IBMPlexSans', fontWeight: FontWeight.w600),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: AppColors.safetyOrange,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.tabDetails),
          Tab(text: AppLocalizations.of(context)!.tabChat),
          Tab(text: AppLocalizations.of(context)!.tabActivity),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TaskEntity task,
    WorkOrderState state,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _DetailsTab(task: task),
        ChatScreen(taskId: task.id),
        _ActivityTab(task: task),
      ],
    );
  }

  Widget _buildError(WorkOrderError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.onSurfaceMuted),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(
              color: AppColors.onSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context
                .read<WorkOrderBloc>()
                .add(WorkOrderLoadRequested(widget.taskId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionBar(WorkOrderState state) {
    final task = _extractTask(state);
    if (task == null) return null;
    final isTransitioning = state is WorkOrderTransitioning;

    final l = AppLocalizations.of(context)!;

    if (task.status == TaskStatus.assigned) {
      return _SingleActionBar(
        label: l.acceptJob,
        icon: Icons.check_circle_outline_rounded,
        isLoading: isTransitioning,
        onPressed: isTransitioning
            ? null
            : () => context
                .read<WorkOrderBloc>()
                .add(const WorkOrderAccepted()),
      );
    }

    if (task.status == TaskStatus.inProgress) {
      return _DualActionBar(
        secondaryLabel: l.navigate,
        secondaryIcon: Icons.navigation_rounded,
        onSecondaryPressed: task.latitude != null && task.longitude != null
            ? () => MapLauncher.showPicker(context, task.latitude!, task.longitude!)
            : null,
        primaryLabel: l.complete,
        primaryIcon: Icons.camera_alt_outlined,
        isLoading: isTransitioning,
        onPrimaryPressed: isTransitioning
            ? null
            : () => _onCompletePressed(task),
      );
    }

    if (task.status == TaskStatus.completed) {
      return _SingleActionBar(
        label: l.completedStatus,
        icon: Icons.check_circle_rounded,
        color: AppColors.priorityCompleted,
        isLoading: false,
        onPressed: null,
      );
    }

    return null;
  }

  Future<void> _onCompletePressed(TaskEntity task) async {
    final picked = await _imagePicker.pickMultiImage();
    if (!mounted) return;

    final l = AppLocalizations.of(context)!;
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.photoRequired),
          backgroundColor: AppColors.priorityCritical,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (picked.length > AppConstants.maxVerificationPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.maxPhotos(AppConstants.maxVerificationPhotos)),
          backgroundColor: AppColors.priorityCritical,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<WorkOrderBloc>().add(
          WorkOrderCompleted(picked.map((f) => f.path).toList()),
        );
  }
}

// ---------------------------------------------------------------------------
// Details Tab
// ---------------------------------------------------------------------------

class _DetailsTab extends StatelessWidget {
  final TaskEntity task;

  const _DetailsTab({required this.task});

  // Use scheduledAt + 4h as the operational SLA deadline if no explicit
  // deadline field exists on the entity.
  DateTime get _slaDeadline => task.scheduledAt.add(const Duration(hours: 4));

  bool get _showSla =>
      task.status == TaskStatus.inProgress ||
      task.status == TaskStatus.assigned;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _DataBlock(
              title: l.sectionOverview,
              children: [
                _DataRow(
                  label: l.fieldStatus,
                  value: PriorityUiHelper.labelForStatus(task.status),
                  valueColor: PriorityUiHelper.colorForStatus(task.status),
                ),
                _DataRow(
                  label: l.fieldPriority,
                  value: task.priority.value.toUpperCase(),
                ),
                _DataRow(label: l.fieldServiceType, value: task.serviceType),
                _DataRow(label: l.fieldClient, value: task.clientName),
                if (task.clientPhone != null)
                  _DataRow(label: l.fieldPhone, value: task.clientPhone!),
              ],
            );
          }),
          if (_showSla) ...[
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final l = AppLocalizations.of(context)!;
              return _DataBlock(
                title: l.sectionSlaDeadline,
                children: [
                  _DataRow(
                    label: l.fieldDeadline,
                    value: DateFormat('dd.MM.yyyy HH:mm').format(_slaDeadline),
                  ),
                  const SizedBox(height: 8),
                  SlaCountdownTimer(deadline: _slaDeadline),
                ],
              );
            }),
          ],
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _DataBlock(
              title: l.sectionDescription,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 14,
                      height: 1.55,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _DataBlock(
              title: l.sectionLocation,
              children: [
                _DataRow(label: l.fieldAddress, value: task.address),
                if (task.latitude != null && task.longitude != null) ...[
                  _DataRow(
                    label: l.fieldCoordinates,
                    value:
                        '${task.latitude!.toStringAsFixed(5)}, ${task.longitude!.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 8),
                  MapLaunchButtons(lat: task.latitude!, lng: task.longitude!),
                ],
              ],
            );
          }),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _DataBlock(
              title: l.sectionTimeline,
              children: [
                const SizedBox(height: 8),
                TaskTimeline(task: task),
              ],
            );
          }),
          if (task.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DataBlock(
              title: 'WORK EVIDENCE (${task.attachmentUrls.length})',
              children: [
                _AttachmentGrid(urls: task.attachmentUrls),
              ],
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity Tab
// ---------------------------------------------------------------------------

class _ActivityTab extends StatelessWidget {
  final TaskEntity task;

  const _ActivityTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents(AppLocalizations.of(context)!);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (ctx, i) {
        final isLast = i == events.length - 1;
        return _ActivityEvent(
          event: events[i],
          isLast: isLast,
        );
      },
    );
  }

  List<_ActivityEventData> _buildEvents(AppLocalizations l) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    final events = <_ActivityEventData>[];

    events.add(_ActivityEventData(
      icon: Icons.add_circle_outline,
      color: AppColors.operationalBlue,
      title: l.eventCreated,
      time: fmt.format(task.scheduledAt.subtract(const Duration(minutes: 5))),
    ),);

    events.add(_ActivityEventData(
      icon: Icons.assignment_outlined,
      color: AppColors.priorityNormal,
      title: l.eventAssigned,
      time: fmt.format(task.scheduledAt),
    ),);

    if (task.acceptedAt != null) {
      events.add(_ActivityEventData(
        icon: Icons.check_outlined,
        color: AppColors.safetyOrange,
        title: l.eventAccepted,
        time: fmt.format(task.acceptedAt!),
      ),);
    }

    if (task.startedAt != null) {
      events.add(_ActivityEventData(
        icon: Icons.play_circle_outline,
        color: AppColors.safetyOrange,
        title: l.eventStarted,
        time: fmt.format(task.startedAt!),
      ),);
    }

    if (task.completedAt != null) {
      final dur = task.activeDuration;
      final label = dur != null
          ? '${l.eventCompleted} · ${DurationFormatter.format(dur)}'
          : l.eventCompleted;
      events.add(_ActivityEventData(
        icon: Icons.check_circle_outline,
        color: AppColors.priorityCompleted,
        title: label,
        time: fmt.format(task.completedAt!),
      ),);
    }

    return events;
  }
}

class _ActivityEventData {
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  const _ActivityEventData({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });
}

class _ActivityEvent extends StatelessWidget {
  final _ActivityEventData event;
  final bool isLast;

  const _ActivityEvent({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: event.color.withValues(alpha: 0.3)),
                ),
                child: Icon(event.icon, size: 17, color: event.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Theme.of(context).colorScheme.outline,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'IBMPlexSans',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                      fontFamily: 'IBMPlexSans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared data-display widgets
// ---------------------------------------------------------------------------

class _DataBlock extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DataBlock({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.55),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.55),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentGrid extends StatelessWidget {
  final List<String> urls;

  const _AttachmentGrid({required this.urls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            urls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Action Bars
// ---------------------------------------------------------------------------

class _SingleActionBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SingleActionBar({
    required this.label,
    required this.icon,
    this.color = AppColors.operationalBlue,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: color,
          disabledForegroundColor: Colors.white,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          isLoading
              ? (AppLocalizations.of(context)?.pleaseWait ?? 'Please wait…')
              : label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _DualActionBar extends StatelessWidget {
  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback? onSecondaryPressed;
  final String primaryLabel;
  final IconData primaryIcon;
  final bool isLoading;
  final VoidCallback? onPrimaryPressed;

  const _DualActionBar({
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.isLoading,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: onSecondaryPressed,
              icon: Icon(secondaryIcon, size: 18),
              label: Text(
                secondaryLabel,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                foregroundColor: AppColors.operationalBlue,
                side: const BorderSide(color: AppColors.operationalBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.safetyOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(primaryIcon, size: 18),
              label: Text(
                isLoading
                    ? (AppLocalizations.of(context)?.saving ?? 'Saving…')
                    : primaryLabel,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
