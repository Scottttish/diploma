import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/priority_ui_helper.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';

/// Completed Work Ledger — a permanent record of closed-out jobs.
/// Intentionally called "Completed Jobs", not "History", per domain spec.
class CompletedJobsScreen extends StatefulWidget {
  const CompletedJobsScreen({super.key});

  @override
  State<CompletedJobsScreen> createState() => _CompletedJobsScreenState();
}

class _CompletedJobsScreenState extends State<CompletedJobsScreen> {
  final List<TaskEntity> _jobs = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final repo = context.read<TaskRepository>();
      final results = await repo.fetchCompletedJobs(page: _currentPage);

      setState(() {
        _jobs.addAll(results);
        _currentPage++;
        _hasMore = results.isNotEmpty;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Jobs')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _jobs.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 40, color: scheme.onSurface.withOpacity(0.6),),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.6), fontFamily: 'IBMPlexSans'),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _loadPage, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.operationalBlue,
      onRefresh: () async {
        setState(() {
          _jobs.clear();
          _currentPage = 1;
          _hasMore = true;
        });
        await _loadPage();
      },
      child: _jobs.isEmpty && _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.operationalBlue))
          : _jobs.isEmpty
              ? const _EmptyLedgerView()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _jobs.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _jobs.length) {
                      _loadPage();
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.operationalBlue),
                        ),
                      );
                    }
                    return _CompletedJobCard(job: _jobs[index]);
                  },
                ),
    );
  }
}

class _CompletedJobCard extends StatelessWidget {
  final TaskEntity job;

  const _CompletedJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final duration = job.activeDuration;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'WO #${job.orderNumber}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.operationalBlue,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.priorityCompleted, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              job.serviceType,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              job.address,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                color: scheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 10),
            Row(
              children: [
                _LedgerStat(
                  icon: Icons.schedule_outlined,
                  label: duration != null
                      ? DurationFormatter.format(duration)
                      : 'N/A',
                  tooltip: 'Total active duration',
                ),
                const SizedBox(width: 20),
                _LedgerStat(
                  icon: Icons.photo_library_outlined,
                  label: '${job.attachmentUrls.length} photo${job.attachmentUrls.length != 1 ? 's' : ''}',
                  tooltip: 'Verification photos',
                ),
                const Spacer(),
                if (job.completedAt != null)
                  Text(
                    dateFormat.format(job.completedAt!),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withOpacity(0.6),
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

class _LedgerStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _LedgerStat({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLedgerView extends StatelessWidget {
  const _EmptyLedgerView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 52, color: AppColors.priorityCompleted.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'No completed jobs yet.',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
