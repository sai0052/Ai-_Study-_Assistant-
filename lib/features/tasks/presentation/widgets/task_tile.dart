import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import 'priority_chip.dart';

class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback? onDelete;

  const TaskTile({super.key, required this.task, required this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = !task.isCompleted && task.deadline.isBefore(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
        child: Row(
          children: [
            Checkbox(value: task.isCompleted, onChanged: onToggle),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? theme.colorScheme.outline : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: isOverdue ? Colors.red : theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.relativeDay(task.deadline),
                        style: theme.textTheme.bodySmall?.copyWith(color: isOverdue ? Colors.red : theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PriorityChip(priority: task.priority),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
