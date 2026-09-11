import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/study_planner_provider.dart';
import '../widgets/productivity_stats_chart.dart';
import '../widgets/schedule_calendar.dart';

class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Future<void> _addSessionDialog() async {
    final subjectController = TextEditingController();
    int duration = 30;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Study Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject / Topic')),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Duration:'),
                  Expanded(
                    child: Slider(
                      value: duration.toDouble(),
                      min: 15,
                      max: 120,
                      divisions: 7,
                      label: '$duration min',
                      onChanged: (v) => setDialogState(() => duration = v.round()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty) return;
                await ref.read(studyPlannerControllerProvider).addSession(
                      subject: subjectController.text.trim(),
                      date: _selectedDay ?? DateTime.now(),
                      durationMinutes: duration,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(studySessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      floatingActionButton: FloatingActionButton(onPressed: _addSessionDialog, child: const Icon(Icons.add)),
      body: sessionsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Failed to load sessions: $e')),
        data: (sessions) {
          final sessionCountByDay = <DateTime, int>{};
          for (final s in sessions) {
            final key = DateTime(s.date.year, s.date.month, s.date.day);
            sessionCountByDay[key] = (sessionCountByDay[key] ?? 0) + 1;
          }

          // Rough weekly productivity: minutes studied per day for last 7 days
          final now = DateTime.now();
          final last7 = List.generate(7, (i) {
            final day = now.subtract(Duration(days: 6 - i));
            return sessions
                .where((s) => s.isCompleted && s.date.year == day.year && s.date.month == day.month && s.date.day == day.day)
                .fold<double>(0, (sum, s) => sum + s.durationMinutes);
          });

          final selectedDaySessions = sessions.where((s) {
            final target = _selectedDay ?? DateTime.now();
            return s.date.year == target.year && s.date.month == target.month && s.date.day == target.day;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              ScheduleCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                sessionCountByDay: sessionCountByDay,
                onDaySelected: (day) => setState(() {
                  _selectedDay = day;
                  _focusedDay = day;
                }),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('This Week\'s Productivity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ProductivityStatsChart(last7DaysMinutes: last7),
              const SizedBox(height: AppSizes.lg),
              Text('Sessions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (selectedDaySessions.isEmpty)
                const EmptyState(
                  icon: Icons.timer_outlined,
                  title: 'No sessions scheduled',
                  subtitle: 'Tap the + button to plan a focused study block.',
                )
              else
                ...selectedDaySessions.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: s.isCompleted,
                          onChanged: (v) => ref.read(studyPlannerRepositoryProvider).markComplete(s.id, v ?? false),
                        ),
                        title: Text(s.subject),
                        subtitle: Text('${s.durationMinutes} minutes'),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
