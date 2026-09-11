import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_assistant/presentation/providers/chat_provider.dart';
import '../../../study_planner/presentation/providers/study_planner_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

final aiSuggestionProvider = FutureProvider<String>((ref) async {
  final upcomingTasks = ref.watch(upcomingDeadlinesProvider);
  final weakTopics = upcomingTasks.map((t) => t.title).toList();

  final aiRepository = ref.watch(aiRepositoryProvider);
  final result = await aiRepository.studyRecommendation(weakTopics: weakTopics);

  return result.fold(
        (failure) => 'Stay consistent — even 25 focused minutes today keeps you on track!',
        (suggestion) => suggestion,
  );
});

/// Real dashboard stats computed from live Firestore data — replaces the
/// hard-coded placeholder numbers that used to sit directly in the UI.
class DashboardStats {
  final int completedTasksCount;
  final double totalStudyHours;
  final int streakDays;

  const DashboardStats({
    required this.completedTasksCount,
    required this.totalStudyHours,
    required this.streakDays,
  });

  String get formattedStudyHours {
    final rounded = (totalStudyHours * 10).round() / 10;
    final text = rounded.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}h';
  }

  String get formattedStreak => streakDays == 1 ? '1 day' : '$streakDays days';
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final sessions = ref.watch(studySessionsStreamProvider).value ?? [];

  final completedTasksCount = tasks.where((t) => t.isCompleted).length;

  final completedSessions = sessions.where((s) => s.isCompleted).toList();
  final totalMinutes = completedSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  final totalStudyHours = totalMinutes / 60.0;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  final activeDays = completedSessions.map((s) => normalize(s.date)).toSet();

  int streak = 0;
  var cursor = normalize(DateTime.now());
  while (activeDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return DashboardStats(
    completedTasksCount: completedTasksCount,
    totalStudyHours: totalStudyHours,
    streakDays: streak,
  );
});