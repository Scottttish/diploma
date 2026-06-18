import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated marker for the worker's current GPS position.
/// Shows a pulsing ring to distinguish it from task pins.
class WorkerMarker extends StatefulWidget {
  const WorkerMarker({super.key});

  @override
  State<WorkerMarker> createState() => _WorkerMarkerState();
}

class _WorkerMarkerState extends State<WorkerMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding pulse ring
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = Curves.easeOut.transform(_ctrl.value);
              return Transform.scale(
                scale: 1.0 + t * 1.8,
                child: Opacity(
                  opacity: (1.0 - t) * 0.40,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.operationalBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // Core dot
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.operationalBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x44000000), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 13),
          ),
        ],
      ),
    );
  }
}
