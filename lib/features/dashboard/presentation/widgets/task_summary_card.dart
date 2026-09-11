import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/widgets/priority_chip.dart';

class TaskSummaryCard extends StatelessWidget {
  final List<TaskEntity> tasks;
  const TaskSummaryCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Icon(Icons.celebration_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text('Nothing due today — enjoy the breathing room!')),
            ],
          ),
        ),
      );
    }
    return Column(
      children: tasks
          .take(3)
          .map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.circle_outlined),
                  title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: PriorityChip(priority: t.priority),
                ),
              ))
          .toList(),
    );
  }
}
