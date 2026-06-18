import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ticking countdown to a task deadline.
/// Color shifts: green → orange at 4h → red at 1h → flashes when overdue.
class SlaCountdownTimer extends StatefulWidget {
  final DateTime deadline;
  final bool compact;

  const SlaCountdownTimer({
    super.key,
    required this.deadline,
    this.compact = false,
  });

  @override
  State<SlaCountdownTimer> createState() => _SlaCountdownTimerState();
}

class _SlaCountdownTimerState extends State<SlaCountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remaining = widget.deadline.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color get _color {
    if (_remaining.isNegative) return AppColors.priorityCritical;
    if (_remaining.inHours < 1) return AppColors.priorityCritical;
    if (_remaining.inHours < 4) return AppColors.safetyOrange;
    return AppColors.priorityCompleted;
  }

  String get _label {
    if (_remaining.isNegative) {
      final overdue = _remaining.abs();
      if (overdue.inHours > 0) {
        return 'OVERDUE ${overdue.inHours}h ${overdue.inMinutes.remainder(60)}m';
      }
      return 'OVERDUE ${overdue.inMinutes}m';
    }
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m remaining';
    if (m > 0) return '${m}m ${s}s remaining';
    return '${s}s remaining';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isOverdue = _remaining.isNegative;

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_rounded : Icons.timer_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'IBMPlexSans',
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_rounded : Icons.timer_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'IBMPlexSans',
            ),
          ),
        ],
      ),
    );
  }
}
