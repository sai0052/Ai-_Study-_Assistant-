import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../tasks/domain/entities/task_entity.dart';

class DeadlineCard extends StatelessWidget {
  final List<TaskEntity> deadlines;
  const DeadlineCard({super.key, required this.deadlines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (deadlines.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text('No deadlines in the next 7 days.', style: theme.textTheme.bodyMedium),
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deadlines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final d = deadlines[index];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(DateFormatter.relativeDay(d.deadline), style: theme.textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
