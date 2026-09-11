import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/campus_provider.dart';
import '../widgets/announcement_card.dart';

class CampusFeedScreen extends ConsumerWidget {
  const CampusFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Updates')),
      body: announcementsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Failed to load announcements: $e')),
        data: (announcements) {
          if (announcements.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No announcements yet',
              subtitle: 'Campus updates and event reminders will show up here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: announcements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => AnnouncementCard(announcement: announcements[index]),
          );
        },
      ),
    );
  }
}
