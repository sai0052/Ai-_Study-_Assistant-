import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/ai_suggestion_card.dart';
import '../widgets/deadline_card.dart';
import '../widgets/task_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final todaysTasks = ref.watch(todaysTasksProvider);
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final aiSuggestion = ref.watch(aiSuggestionProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Student'} 👋'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(aiSuggestionProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            aiSuggestion.when(
              data: (s) => AiSuggestionCard(suggestion: s),
              loading: () => const AiSuggestionCard(suggestion: '', isLoading: true),
              error: (_, __) => const AiSuggestionCard(suggestion: 'Keep going — consistency beats intensity!'),
            ),
            const SizedBox(height: AppSizes.lg),

            _SectionHeader(title: AppStrings.todaysTasks, onSeeAll: () => context.go('/tasks')),
            const SizedBox(height: 8),
            TaskSummaryCard(tasks: todaysTasks),
            const SizedBox(height: AppSizes.lg),

            _SectionHeader(title: AppStrings.upcomingDeadlines, onSeeAll: () => context.go('/tasks')),
            const SizedBox(height: 8),
            DeadlineCard(deadlines: deadlines),
            const SizedBox(height: AppSizes.lg),

            Text(AppStrings.studyProgress, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(label: 'Tasks Done', value: '${stats.completedTasksCount}'),
                    _StatColumn(label: 'Study Hours', value: stats.formattedStudyHours),
                    _StatColumn(label: 'Streak', value: stats.formattedStreak),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Text('Quick Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _QuickAction(icon: Icons.smart_toy_outlined, label: 'Ask AI', onTap: () => context.push('/ai-chat'))),
                const SizedBox(width: 10),
                Expanded(child: _QuickAction(icon: Icons.note_add_outlined, label: 'New Note', onTap: () => context.push('/notes/new'))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _QuickAction(icon: Icons.add_task_outlined, label: 'Add Task', onTap: () => context.push('/tasks/new'))),
                const SizedBox(width: 10),
                Expanded(child: _QuickAction(icon: Icons.calendar_month_outlined, label: 'Study Planner', onTap: () => context.push('/study-planner'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}