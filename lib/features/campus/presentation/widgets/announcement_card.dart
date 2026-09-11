import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  const AnnouncementCard({super.key, required this.announcement});

  Color _typeColor() {
    switch (announcement.type) {
      case AnnouncementType.urgent:
        return AppColors.error;
      case AnnouncementType.event:
        return AppColors.info;
      case AnnouncementType.general:
        return AppColors.success;
    }
  }

  IconData _typeIcon() {
    switch (announcement.type) {
      case AnnouncementType.urgent:
        return Icons.priority_high_rounded;
      case AnnouncementType.event:
        return Icons.event_outlined;
      case AnnouncementType.general:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(_typeIcon(), color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(announcement.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    announcement.eventDate != null
                        ? 'Event: ${DateFormatter.friendlyDate(announcement.eventDate!)}'
                        : DateFormatter.relativeDay(announcement.postedAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
