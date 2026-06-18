import 'package:flutter/material.dart';
import '../../../../core/utils/priority_ui_helper.dart';
import '../../../../domain/entities/task_entity.dart';

/// Numbered task pin with priority-based color and animated selection state.
class TaskMarker extends StatelessWidget {
  final TaskEntity task;
  final int index;
  final bool isSelected;

  const TaskMarker({
    super.key,
    required this.task,
    required this.index,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = PriorityUiHelper.colorForPriority(task.priority);
    final pinSize = isSelected ? 52.0 : 44.0;
    final bubbleSize = isSelected ? 21.0 : 17.0;
    final bubbleTop = isSelected ? 6.0 : 4.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: pinSize,
      height: pinSize,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Selection glow ring
          if (isSelected)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          Icon(Icons.location_pin, color: color, size: pinSize),
          // Number bubble
          Positioned(
            top: bubbleTop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: bubbleSize,
              height: bubbleSize,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: isSelected ? 10 : 9,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : color,
                    fontFamily: 'IBMPlexSans',
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
