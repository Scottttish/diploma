import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';
import '../../../core/utils/priority_ui_helper.dart';
import '../../../domain/entities/task_priority.dart';

/// Color-coded priority chip displayed on every work order card.
/// The monospaced all-caps treatment signals severity at a glance.
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = PriorityUiHelper.colorForPriority(priority);
    final label = PriorityUiHelper.labelForPriority(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
          fontFamily: 'IBMPlexSans',
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
          fontFamily: 'IBMPlexSans',
        ),
      ),
    );
  }
}

/// Thin left-edge accent bar — a structural design cue borrowed from
/// physical inspection forms to show where a section begins.
class PriorityAccentBar extends StatelessWidget {
  final TaskPriority priority;
  final double height;
  final Color? overrideColor;

  const PriorityAccentBar({
    super.key,
    required this.priority,
    this.height = double.infinity,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: overrideColor ?? PriorityUiHelper.colorForPriority(priority),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
    );
  }
}

// class _OperationalSummaryBanner extends StatelessWidget {
//   final int activeCount;
//   final int criticalCount;

//   const _OperationalSummaryBanner({
//     required this.activeCount,
//     required this.criticalCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       color: AppColors.operationalBlue,
//       child: Row(
//         children: [
//           const Icon(Icons.work_outline_rounded,
//               color: Colors.white54, size: 18),
//           const SizedBox(width: 10),
//           Text(
//             '$activeCount Active Job${activeCount != 1 ? 's' : ''}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'IBMPlexSans',
//             ),
//           ),
//           if (criticalCount > 0) ...[
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               width: 1,
//               height: 14,
//               color: Colors.white24,
//             ),
//             Icon(Icons.warning_amber_rounded,
//                 color: AppColors.priorityCritical, size: 16),
//             const SizedBox(width: 4),
//             Text(
//               '$criticalCount Critical',
//               style: const TextStyle(
//                 color: AppColors.priorityCritical,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'IBMPlexSans',
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
