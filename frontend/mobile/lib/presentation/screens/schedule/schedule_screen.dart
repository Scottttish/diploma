import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../widgets/cards/work_order_card.dart';
import '../../widgets/sla_countdown_timer.dart';

class ScheduleScreen extends StatefulWidget {
  final void Function(String taskId) onOpenWorkOrder;

  const ScheduleScreen({super.key, required this.onOpenWorkOrder});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _workerName = '';

  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(const ScheduleLoadRequested());
    _loadName();
  }

  Future<void> _loadName() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: AppConstants.storageKeyWorkerName) ?? '';
    if (mounted) setState(() => _workerName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return switch (state) {
            ScheduleInitial() ||
            ScheduleLoading() =>
              _LoadingView(workerName: _workerName),
            ScheduleLoaded() => _LoadedView(
                state: state,
                workerName: _workerName,
                onOpenWorkOrder: widget.onOpenWorkOrder,
              ),
            ScheduleError() => _ErrorView(
                message: state.message,
                workerName: _workerName,
                onRetry: () => context
                    .read<ScheduleBloc>()
                    .add(const ScheduleLoadRequested()),
              ),
          };
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded View
// ---------------------------------------------------------------------------

class _LoadedView extends StatelessWidget {
  final ScheduleLoaded state;
  final String workerName;
  final void Function(String taskId) onOpenWorkOrder;

  const _LoadedView({
    required this.state,
    required this.workerName,
    required this.onOpenWorkOrder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.operationalBlue,
      onRefresh: () async {
        context.read<ScheduleBloc>().add(const ScheduleRefreshRequested());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _OperationalHeader(
            workerName: workerName,
            activeCount: state.activeCount,
            criticalCount: state.criticalCount,
          ),
          SliverToBoxAdapter(
            child: _QuickActionsRow(context: context),
          ),
          if (state.tasks.isEmpty)
            const SliverFillRemaining(child: _EmptyView())
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 4, bottom: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final task = state.tasks[index];
                    // Show SLA timer below the card when deadline is within 4h
                    final showSla = task.completedAt == null &&
                        task.startedAt != null;
                    final nearDeadline = showSla
                        ? task.scheduledAt
                            .add(const Duration(hours: 4))
                            .isBefore(DateTime.now().add(const Duration(hours: 4)))
                        : false;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WorkOrderCard(
                          task: task,
                          onOpen: () => onOpenWorkOrder(task.id),
                        ),
                        if (nearDeadline)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 0, 16, 4),
                            child: SlaCountdownTimer(
                              deadline: task.scheduledAt
                                  .add(const Duration(hours: 4)),
                              compact: true,
                            ),
                          ),
                      ],
                    );
                  },
                  childCount: state.tasks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Operational Header (SliverAppBar replacement)
// ---------------------------------------------------------------------------

class _OperationalHeader extends StatelessWidget {
  final String workerName;
  final int activeCount;
  final int criticalCount;

  const _OperationalHeader({
    required this.workerName,
    required this.activeCount,
    required this.criticalCount,
  });

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.greetingMorning;
    if (h < 17) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  String get _dateLabel {
    return DateFormat('EEE, d MMM').format(DateTime.now());
  }

  String get _firstName {
    if (workerName.isEmpty) return 'there';
    return workerName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 138,
      backgroundColor: AppColors.operationalBlue,
      foregroundColor: Colors.white,
      title: Text(
        _dateLabel,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'IBMPlexSans',
          color: Colors.white70,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: AppColors.operationalBlue,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting(l)}, $_firstName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBMPlexSans',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.work_outline_rounded,
                    label: l.activeTasks(activeCount),
                    color: Colors.white,
                  ),
                  if (criticalCount > 0) ...[
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.warning_amber_rounded,
                      label: l.criticalTasks(criticalCount),
                      color: AppColors.priorityCritical,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSans',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions Row
// ---------------------------------------------------------------------------

class _QuickActionsRow extends StatelessWidget {
  final BuildContext context;

  const _QuickActionsRow({required this.context});

  @override
  Widget build(BuildContext outerContext) {
    final l = AppLocalizations.of(outerContext)!;
    return Container(
      color: AppColors.operationalBlue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionChip(
              icon: Icons.map_outlined,
              label: l.todaysRoute,
              onTap: () => outerContext.push('/map'),
            ),
            const SizedBox(width: 8),
            _ActionChip(
              icon: Icons.camera_alt_outlined,
              label: l.uploadPhoto,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _ActionChip(
              icon: Icons.phone_outlined,
              label: l.callDispatch,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / Error / Empty views
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  final String workerName;
  const _LoadingView({required this.workerName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _OperationalHeader(
          workerName: workerName,
          activeCount: 0,
          criticalCount: 0,
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.operationalBlue),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 56,
            color: AppColors.priorityCompleted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noJobsToday,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String workerName;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.workerName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _OperationalHeader(
          workerName: workerName,
          activeCount: 0,
          criticalCount: 0,
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: AppColors.onSurfaceMuted,),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 14,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: OutlinedButton(
                      onPressed: onRetry,
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
